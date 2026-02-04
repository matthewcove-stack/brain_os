# MVP Capture Loop Specification

Status: draft (MVP)  
Owner: Brain OS (cross-repo)  
Last updated: 2026-02-03

## Goal
Define the single, boring, reliable capture loop for Brain OS:

ChatGPT (typed or voice) -> user copy/paste -> Shortcut (or equivalent) -> HTTP ingest -> persist -> normalise -> (optional) execute -> receipt.

This spec is the source of truth for "capture, reflect, externalise" in MVP.

## Non-goals (MVP)
- No autonomous agents.
- No background capture without explicit user paste/send.
- No vector search / embeddings.
- No multi-step clarification UI (clarifications may be recorded, but not required for MVP use).

## Assumed architecture (already chosen)
- ChatGPT produces a LIGHT intent packet (no execution plan).
- intent_normaliser performs deterministic normalisation and owns action execution policy.
- notion_gateway performs Notion API calls.
- action_relay is an operator convenience client (optional); the canonical ingest is HTTP.

This matches the current project direction and does NOT replace it.

## Canonical ingress
- HTTP: POST /v1/intents (intent_normaliser)

Clients may be:
- iOS Shortcut (preferred for phone capture)
- action_relay CLI (developer/operator convenience)
- curl (debug)

## Intent Packet (lightweight)
The payload MUST be a single JSON object.

Minimum required fields (v1):
- kind: "intent"
- natural_language: string

Recommended fields (MVP):
- schema_version: "v1" (or "v2" if/when introduced)
- source: "chatgpt"
- timestamp: ISO-8601 UTC timestamp
- conversation_id / message_id (if available)
- fields: object (optional, only if user explicitly supplied structured data)

Important: ChatGPT MUST NOT produce a Notion plan or tool instructions. It only produces the intent packet.

Compatibility note:
- Existing v1 schema already allows additionalProperties, so adding schema_version is additive.

## Server behavior (intent_normaliser) - MUSTs
### Persist-first
On receiving a valid intent packet:
1) Persist the incoming packet as an immutable record (inbox/audit row) BEFORE any downstream calls.
2) Return a receipt response even if downstream execution is async or fails later.

### Deterministic validation
- Validate JSON schema (at least v1).
- Reject malformed JSON with 400 and an error envelope.
- If schema_version is present and unsupported, return 400 with error.code = "unsupported_schema_version".

### Idempotency
- The server MUST compute an idempotency_key from the canonical JSON (server-side), for paste safety.
  - Recommended: sha256(canonical_json_bytes)
  - Canonicalization: stable key ordering, UTF-8, no whitespace significance.
- If a request with the same idempotency_key was processed before:
  - Return the original receipt and status (do NOT duplicate downstream actions).

### Normalisation (reflect + externalise)
- Normalisation produces a deterministic plan (internal artifact), stored alongside the intent.
- Execution is gated by configuration:
  - EXECUTE_ACTIONS (bool)
  - confidence threshold (if confidence is used)
- If execution is disabled, return status = "accepted" or "planned" (choose one and keep consistent).

### Failure handling
- If downstream execution fails:
  - The intent packet remains persisted.
  - The response MUST include status = "failed" and an error envelope with code/message/details.
  - The failure is replayable (manual replay tool is acceptable for MVP).

## Receipt (response contract)
Every ingest attempt returns a response envelope with:
- receipt_id (stable identifier)
- trace_id (for cross-service correlation)
- status: accepted | planned | executed | failed
- idempotency_key
- error (only when failed)

Minimum user trust guarantee:
- If the client gets a receipt_id, the input is not lost.

## Verification (MVP acceptance tests)
MVP is "usable" when ALL are true:
1) Copy/paste JSON from ChatGPT into Shortcut results in a 200 response with receipt_id.
2) Duplicate paste does not create duplicate Notion tasks (idempotent).
3) When Notion credentials are configured and EXECUTE_ACTIONS=true, at least one intent creates a Notion task.
4) When execution fails (bad token), the failure is returned clearly and the intent is still stored.
5) Logs include trace_id and receipt_id for the request.

## Operational notes
- Keep raw_text (natural_language) stored for MVP debugging.
- Provide a documented purge policy later (post-MVP).
