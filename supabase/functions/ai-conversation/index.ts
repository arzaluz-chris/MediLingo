// POST /functions/v1/ai-conversation
// Body: { conversationId?, message, conversationType?, scenario? }
// Returns envelope: { data: { response, scores, conversationId }, error, metadata }
//
// Persists the conversation: creates an ai_conversations row on first message,
// appends user + assistant turns to ai_messages, and replays prior turns so
// the patient stays in character across the session.

import { handleCorsPreflight, jsonHeaders } from "../_shared/cors.ts";
import { getUser, withinAIQuota } from "../_shared/auth.ts";
import { chatWithFallback } from "../_shared/ai-provider.ts";
import { fail, ok, type Message } from "../_shared/types.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

// Reject oversized turns before spending a provider call (cost/abuse guard).
const MAX_MESSAGE_CHARS = 4000;

const PATIENT_SYSTEM_PROMPT = `
You are a patient in a medical consultation simulation for MediLingo,
a medical English learning app. Respond ONLY in English, stay in character
as the patient described in the scenario, and adapt to the user's English level.
`.trim();

const MAX_HISTORY_TURNS = 20;

Deno.serve(async (req) => {
  const preflight = handleCorsPreflight(req);
  if (preflight) return preflight;

  const user = await getUser(req);
  if (!user) {
    return new Response(JSON.stringify(fail("UNAUTHORIZED", "Sign in required.")), {
      status: 401, headers: jsonHeaders,
    });
  }

  let body: {
    conversationId?: string;
    message?: string;
    conversationType?: string;
    scenario?: Record<string, unknown>;
  };
  try {
    body = await req.json();
  } catch {
    return new Response(JSON.stringify(fail("BAD_REQUEST", "Invalid JSON body.")), {
      status: 400, headers: jsonHeaders,
    });
  }

  if (!body.message || typeof body.message !== "string") {
    return new Response(JSON.stringify(fail("BAD_REQUEST", "`message` is required.")), {
      status: 400, headers: jsonHeaders,
    });
  }
  if (body.message.length > MAX_MESSAGE_CHARS) {
    return new Response(JSON.stringify(fail("BAD_REQUEST", `\`message\` exceeds ${MAX_MESSAGE_CHARS} characters.`)), {
      status: 400, headers: jsonHeaders,
    });
  }

  // Rate limit: 40 turns/hour free, 400 premium.
  if (!(await withinAIQuota(req, "ai_conversation", 40, 400, 3600))) {
    return new Response(JSON.stringify(fail("RATE_LIMITED", "AI conversation limit reached. Try again later.")), {
      status: 429, headers: jsonHeaders,
    });
  }

  // Service-role client: ai_messages writes are gated through this function.
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
  );

  // Resolve or create the conversation (ownership enforced explicitly).
  let conversationId = body.conversationId ?? null;
  if (conversationId) {
    const { data: convo } = await supabase
      .from("ai_conversations")
      .select("id, user_id, status")
      .eq("id", conversationId)
      .single();
    if (!convo || convo.user_id !== user.id) {
      return new Response(JSON.stringify(fail("NOT_FOUND", "Conversation not found.")), {
        status: 404, headers: jsonHeaders,
      });
    }
  } else {
    const { data: created, error: createError } = await supabase
      .from("ai_conversations")
      .insert({
        user_id: user.id,
        conversation_type: body.conversationType ?? "patient_consultation",
        scenario: body.scenario ?? {},
      })
      .select("id")
      .single();
    if (createError || !created) {
      return new Response(JSON.stringify(fail("INTERNAL", "Could not create conversation.")), {
        status: 500, headers: jsonHeaders,
      });
    }
    conversationId = created.id;
  }

  // Replay prior turns so the model keeps context.
  const { data: history } = await supabase
    .from("ai_messages")
    .select("role, content")
    .eq("conversation_id", conversationId)
    .order("created_at", { ascending: true })
    .limit(MAX_HISTORY_TURNS);

  const messages: Message[] = [
    { role: "system", content: PATIENT_SYSTEM_PROMPT },
    ...(history ?? []).filter((m) => m.role !== "system").map((m) => ({
      role: m.role as "user" | "assistant",
      content: m.content,
    })),
    { role: "user", content: body.message },
  ];

  try {
    const result = await chatWithFallback(messages, { responseFormat: "text" });

    await supabase.from("ai_messages").insert([
      { conversation_id: conversationId, role: "user", content: body.message },
      { conversation_id: conversationId, role: "assistant", content: result.content },
    ]);
    // Count from the source of truth so it stays correct past MAX_HISTORY_TURNS.
    const { count } = await supabase
      .from("ai_messages")
      .select("*", { count: "exact", head: true })
      .eq("conversation_id", conversationId);
    await supabase
      .from("ai_conversations")
      .update({ message_count: count ?? 0 })
      .eq("id", conversationId);

    return new Response(
      JSON.stringify(ok({ response: result.content, scores: null, conversationId, provider: result.provider })),
      { status: 200, headers: jsonHeaders },
    );
  } catch (_e) {
    return new Response(JSON.stringify(fail("NOT_IMPLEMENTED", "AI provider not configured yet.")), {
      status: 501, headers: jsonHeaders,
    });
  }
});
