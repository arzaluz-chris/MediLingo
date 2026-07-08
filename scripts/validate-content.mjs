#!/usr/bin/env node
// ============================================================================
// MediLingo — content validator
//
// The DB does NOT validate exercises.metadata against the exercise JSON
// schemas (no trigger/CHECK); only the admin (Zod) and iOS decode it. So a
// migration/seed with malformed metadata loads fine but breaks the clients
// (exactly the seed.sql drift the audit found). This script closes that gap:
// it extracts every (exercise_type, metadata) pair from the given SQL files
// and validates each against shared/schemas/<type>.schema.json.
//
// Usage:
//   node scripts/validate-content.mjs [file ...]
// With no args it scans supabase/migrations, supabase/seed.sql, supabase/seed/.
// Exits non-zero on the first batch of failures. Zero deps (plain node).
// ============================================================================

import { readFileSync, readdirSync, existsSync } from "node:fs";
import { join, dirname, basename } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const SCHEMA_DIR = join(ROOT, "shared", "schemas");

// Exercise types that HAVE a JSON schema (MVP). The other declared types
// (role_playing, ai_conversation, clinical_case, patient_interview,
// memory_game) are not schematized yet — their metadata is skipped, not failed.
const SCHEMAS = {};
for (const f of readdirSync(SCHEMA_DIR)) {
  if (!f.endsWith(".schema.json")) continue;
  const type = f.replace(".schema.json", "");
  SCHEMAS[type] = JSON.parse(readFileSync(join(SCHEMA_DIR, f), "utf8"));
}
const KNOWN_TYPES = new Set([
  ...Object.keys(SCHEMAS),
  "role_playing", "ai_conversation", "clinical_case", "patient_interview", "memory_game",
]);

// ---- minimal JSON Schema validator (draft subset the schemas actually use) --
function typeOf(v) {
  if (v === null) return "null";
  if (Array.isArray(v)) return "array";
  if (Number.isInteger(v)) return "integer";
  return typeof v; // string | number | boolean | object
}
function matchesType(v, t) {
  const kinds = Array.isArray(t) ? t : [t];
  const actual = typeOf(v);
  return kinds.some((k) =>
    k === actual ||
    (k === "number" && (actual === "integer" || actual === "number")) ||
    (k === "integer" && actual === "integer"));
}
function validate(schema, value, path, errors) {
  if (schema.type && !matchesType(value, schema.type)) {
    errors.push(`${path}: expected ${JSON.stringify(schema.type)}, got ${typeOf(value)}`);
    return; // type wrong → downstream checks meaningless
  }
  if (schema.enum && !schema.enum.some((e) => JSON.stringify(e) === JSON.stringify(value)))
    errors.push(`${path}: ${JSON.stringify(value)} not in enum ${JSON.stringify(schema.enum)}`);
  if ("const" in schema && JSON.stringify(schema.const) !== JSON.stringify(value))
    errors.push(`${path}: must equal ${JSON.stringify(schema.const)}`);
  if (typeof value === "number") {
    if ("minimum" in schema && value < schema.minimum) errors.push(`${path}: < minimum ${schema.minimum}`);
    if ("maximum" in schema && value > schema.maximum) errors.push(`${path}: > maximum ${schema.maximum}`);
  }
  if (typeOf(value) === "array") {
    if ("minItems" in schema && value.length < schema.minItems)
      errors.push(`${path}: needs >= ${schema.minItems} items, got ${value.length}`);
    if (schema.items) value.forEach((it, i) => validate(schema.items, it, `${path}[${i}]`, errors));
  }
  if (typeOf(value) === "object") {
    for (const req of schema.required ?? [])
      if (!(req in value)) errors.push(`${path}: missing required "${req}"`);
    const props = schema.properties ?? {};
    if (schema.additionalProperties === false)
      for (const k of Object.keys(value))
        if (!(k in props)) errors.push(`${path}: unexpected property "${k}"`);
    for (const [k, v] of Object.entries(value))
      if (props[k]) validate(props[k], v, `${path}.${k}`, errors);
  }
}

// ---- SQL extraction ---------------------------------------------------------
// Pair each exercise row's type (two UUIDs then a quoted type) with the next
// '{...}'::jsonb literal that follows it. metadata is the only ::jsonb per row.
const UUID = "'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'";
const TYPE_RE = new RegExp(`${UUID}\\s*,\\s*${UUID}\\s*,\\s*'([a-z_]+)'`, "g");
const JSONB_RE = /'((?:[^']|'')*)'::jsonb/g;

function extractPairs(sql) {
  const types = [...sql.matchAll(TYPE_RE)].map((m) => ({ type: m[1], at: m.index }));
  const metas = [...sql.matchAll(JSONB_RE)].map((m) => ({ raw: m[1], at: m.index }));
  const pairs = [];
  for (let i = 0; i < types.length; i++) {
    const start = types[i].at;
    const end = i + 1 < types.length ? types[i + 1].at : Infinity;
    const meta = metas.find((m) => m.at > start && m.at < end);
    pairs.push({ type: types[i].type, meta, line: sql.slice(0, start).split("\n").length });
  }
  return pairs;
}

// ---- run --------------------------------------------------------------------
function targetFiles() {
  if (process.argv.length > 2) return process.argv.slice(2);
  const files = [];
  const mig = join(ROOT, "supabase", "migrations");
  if (existsSync(mig)) for (const f of readdirSync(mig)) if (f.endsWith(".sql")) files.push(join(mig, f));
  const seedRoot = join(ROOT, "supabase", "seed.sql");
  if (existsSync(seedRoot)) files.push(seedRoot);
  const seedDir = join(ROOT, "supabase", "seed");
  if (existsSync(seedDir)) for (const f of readdirSync(seedDir)) if (f.endsWith(".sql")) files.push(join(seedDir, f));
  return files;
}

let checked = 0, failed = 0, skipped = 0;
const failures = [];
for (const file of targetFiles()) {
  const sql = readFileSync(file, "utf8");
  for (const { type, meta, line } of extractPairs(sql)) {
    if (!KNOWN_TYPES.has(type)) continue; // not an exercise row we recognize
    if (!SCHEMAS[type]) { skipped++; continue; } // declared but not schematized
    if (!meta) { failed++; failures.push(`${basename(file)}:${line} [${type}] no metadata literal found`); continue; }
    let obj;
    try { obj = JSON.parse(meta.raw.replace(/''/g, "'")); }
    catch (e) { failed++; failures.push(`${basename(file)}:${line} [${type}] metadata is not valid JSON: ${e.message}`); continue; }
    const errors = [];
    validate(SCHEMAS[type], obj, "metadata", errors);
    checked++;
    if (errors.length) { failed++; errors.forEach((er) => failures.push(`${basename(file)}:${line} [${type}] ${er}`)); }
  }
}

if (failures.length) {
  console.error(`\n✗ content validation FAILED (${failed} problem(s)):\n`);
  for (const f of failures) console.error("  " + f);
  console.error(`\nchecked ${checked} exercises, ${skipped} skipped (unschematized types).`);
  process.exit(1);
}
console.log(`✓ content valid: ${checked} exercises checked, ${skipped} skipped (unschematized types).`);
