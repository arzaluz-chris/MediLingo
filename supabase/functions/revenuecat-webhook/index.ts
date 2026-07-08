// POST /functions/v1/revenuecat-webhook
// RevenueCat server-to-server webhook (CLAUDE-backend.md § Subscriptions).
// Configure the same secret in the RevenueCat dashboard (Authorization header)
// and in Supabase secrets as REVENUECAT_WEBHOOK_SECRET.
//
// Keeps `subscriptions` and `profiles.is_premium` in sync with store events.
// StoreKit remains the on-device entitlement source; this mirror powers
// server-side premium checks (e.g. consume_heart) and analytics.

import { handleCorsPreflight, jsonHeaders } from "../_shared/cors.ts";
import { fail, ok } from "../_shared/types.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

interface RevenueCatEvent {
  type: string;
  id: string;
  app_user_id: string;
  product_id?: string;
  period_type?: string; // NORMAL | TRIAL | INTRO
  purchased_at_ms?: number;
  expiration_at_ms?: number | null;
  store?: string; // APP_STORE | PLAY_STORE | STRIPE | ...
  price?: number;
  currency?: string;
  original_transaction_id?: string;
}

const ACTIVE_EVENTS = new Set([
  "INITIAL_PURCHASE",
  "RENEWAL",
  "UNCANCELLATION",
  "PRODUCT_CHANGE",
  "NON_RENEWING_PURCHASE",
]);
const INACTIVE_EVENTS = new Set(["EXPIRATION"]);
// CANCELLATION = auto-renew turned off; access continues until expiration.
const CANCEL_EVENTS = new Set(["CANCELLATION"]);
const BILLING_EVENTS = new Set(["BILLING_ISSUE"]);

// Constant-time string comparison to avoid leaking the secret via timing.
function timingSafeEqual(a: string, b: string): boolean {
  const enc = new TextEncoder();
  const ba = enc.encode(a);
  const bb = enc.encode(b);
  if (ba.length !== bb.length) return false;
  let diff = 0;
  for (let i = 0; i < ba.length; i++) diff |= ba[i] ^ bb[i];
  return diff === 0;
}

function platformFrom(store?: string): string {
  switch (store) {
    case "APP_STORE": return "ios";
    case "PLAY_STORE": return "android";
    default: return "web";
  }
}

function planTypeFrom(productId?: string): string {
  if (!productId) return "monthly";
  if (productId.includes("annual") || productId.includes("yearly")) return "annual";
  if (productId.includes("lifetime")) return "lifetime";
  return "monthly";
}

Deno.serve(async (req) => {
  const preflight = handleCorsPreflight(req);
  if (preflight) return preflight;

  // Shared-secret check (constant string configured in the RevenueCat dashboard).
  const secret = Deno.env.get("REVENUECAT_WEBHOOK_SECRET") ?? "";
  const authHeader = req.headers.get("Authorization") ?? "";
  if (!secret || !timingSafeEqual(authHeader, `Bearer ${secret}`)) {
    return new Response(JSON.stringify(fail("UNAUTHORIZED", "Invalid webhook secret.")), {
      status: 401, headers: jsonHeaders,
    });
  }

  let event: RevenueCatEvent;
  try {
    const body = await req.json();
    event = body?.event;
    if (!event?.type || !event?.app_user_id) throw new Error("missing event fields");
  } catch {
    return new Response(JSON.stringify(fail("BAD_REQUEST", "Malformed webhook payload.")), {
      status: 400, headers: jsonHeaders,
    });
  }

  // app_user_id is set to the Supabase user UUID by the iOS client
  // (Purchases.logIn(supabaseUserID)). Ignore anonymous RevenueCat ids.
  const userId = event.app_user_id;
  if (userId.startsWith("$RCAnonymousID")) {
    return new Response(JSON.stringify(ok({ skipped: "anonymous user" })), {
      status: 200, headers: jsonHeaders,
    });
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );

  // Idempotency: RevenueCat retries deliver the same event.id. If we already
  // recorded it (stored in subscriptions.revenue_cat_id), acknowledge and skip.
  if (event.id) {
    const { data: seen } = await supabase
      .from("subscriptions")
      .select("id")
      .eq("revenue_cat_id", event.id)
      .maybeSingle();
    if (seen) {
      return new Response(JSON.stringify(ok({ skipped: "duplicate", eventId: event.id })), {
        status: 200, headers: jsonHeaders,
      });
    }
  }

  const expiresAt = event.expiration_at_ms ? new Date(event.expiration_at_ms).toISOString() : null;
  const startsAt = event.purchased_at_ms ? new Date(event.purchased_at_ms).toISOString() : new Date().toISOString();

  let status: string | null = null;
  let isPremium: boolean | null = null;

  if (ACTIVE_EVENTS.has(event.type)) {
    status = "active";
    isPremium = true;
  } else if (CANCEL_EVENTS.has(event.type)) {
    status = "cancelled"; // access continues until expires_at
    isPremium = true;
  } else if (BILLING_EVENTS.has(event.type)) {
    status = "billing_retry";
    isPremium = true; // grace period
  } else if (INACTIVE_EVENTS.has(event.type)) {
    status = "expired";
    isPremium = false;
  } else {
    // TRANSFER, SUBSCRIBER_ALIAS, TEST etc. — acknowledge without changes.
    return new Response(JSON.stringify(ok({ skipped: event.type })), {
      status: 200, headers: jsonHeaders,
    });
  }

  // Upsert the subscription row keyed on the RevenueCat original transaction.
  const row = {
    user_id: userId,
    platform: platformFrom(event.store),
    product_id: event.product_id ?? "unknown",
    original_transaction_id: event.original_transaction_id ?? null,
    status,
    plan_type: planTypeFrom(event.product_id),
    price_usd: event.price ?? null,
    currency: event.currency ?? "USD",
    starts_at: startsAt,
    expires_at: expiresAt,
    cancelled_at: CANCEL_EVENTS.has(event.type) ? new Date().toISOString() : null,
    is_trial: event.period_type === "TRIAL",
    trial_ends_at: event.period_type === "TRIAL" ? expiresAt : null,
    revenue_cat_id: event.id,
    updated_at: new Date().toISOString(),
  };

  // No natural unique constraint besides id — emulate upsert by original tx.
  const { data: existing } = await supabase
    .from("subscriptions")
    .select("id")
    .eq("user_id", userId)
    .eq("product_id", row.product_id)
    .order("created_at", { ascending: false })
    .limit(1)
    .maybeSingle();

  const write = existing
    ? supabase.from("subscriptions").update(row).eq("id", existing.id)
    : supabase.from("subscriptions").insert(row);
  const { error: subError } = await write;
  if (subError) {
    return new Response(JSON.stringify(fail("INTERNAL", subError.message)), {
      status: 500, headers: jsonHeaders,
    });
  }

  const { error: profileError } = await supabase
    .from("profiles")
    .update({ is_premium: isPremium })
    .eq("id", userId);
  if (profileError) {
    return new Response(JSON.stringify(fail("INTERNAL", profileError.message)), {
      status: 500, headers: jsonHeaders,
    });
  }

  return new Response(JSON.stringify(ok({ processed: event.type, userId, isPremium })), {
    status: 200, headers: jsonHeaders,
  });
});
