# Codex Phase 1 — MVP Vertical Slice (Voice -> Normaliser -> Notion)

## Phase goal
Make the existing vertical slice actually work end-to-end using the canonical contract repo:
- Voice app submits a Light Intent Packet to the normaliser
- Normaliser persists and executes Task create/update via notion_gateway
- UI renders executed / failed / needs_clarification
- Auth + CORS are correct

## Repos in scope
- `lambic_voice_client`
- `intent_normaliser`
- `notion_assistant_contracts`

Out of scope: adding new Notion action types (that is Phase 2).

## Non-goals
- No new UI flows besides confirmation + clarification
- No new LLM packet creation
- No deployment work (Phase 3)

## Current drift to fix (must resolve)
1) Voice UI calls `POST /v1/normalise` and uses `x-api-key`
   - Normaliser expects `POST /v1/intents`
   - Normaliser expects `Authorization: Bearer <INTENT_SERVICE_TOKEN>`
2) Voice UI parses a repo-local `NormaliserResponse` schema that does not match the canonical envelope.

## Required outcome (acceptance criteria)
- Running `brain_os` compose + voice client locally, a user can:
  1. record voice -> transcript -> submit as Task
  2. see a receipt (trace_id, receipt_id, idempotency_key)
  3. see executed outcome including Notion identifiers (task id + url if available)
  4. re-submit identical content -> idempotent, no duplicate created

## Edit map (expected files)
### lambic_voice_client
- `apps/web/src/lib/api.ts`
- `apps/web/src/lib/schemas.ts` and/or schema parsing utilities
- `apps/web/src/components/*` confirmation + clarification UI
- `contracts/*` (either remove or mark deprecated; prefer importing shared schemas)

### intent_normaliser (compat)
- (Optional) add `POST /v1/normalise` as an alias route that forwards to `/v1/intents`
  - Only if changing the web app endpoint is not desired.
  - If you add alias, it must share the same handler and auth dependency.

### notion_assistant_contracts
- Ensure the canonical envelope schema is the only one consumed by web for responses.

## Implementation steps
1) Update voice web submission:
   - Call `${BASE_URL}/v1/intents`
   - Set header `Authorization: Bearer ${VITE_NORMALISER_BEARER_TOKEN}`
   - Do NOT use `x-api-key`
2) Replace/align response parsing:
   - Parse the canonical receipt/outcome envelope
   - Render status:
     - `executed` -> show details
     - `failed` -> show error
     - `needs_clarification` -> show questions
3) Clarification answering:
   - Implement a minimal UI to send answers back to normaliser using the canonical endpoint
   - If the API uses `/v1/clarifications/{id}/answer`, wire to that.
4) Add/update local dev runbook:
   - in `lambic_voice_client/docs/current_state.md` document required env vars:
     - `VITE_NORMALISER_BASE_URL=http://localhost:8000`
     - `VITE_NORMALISER_BEARER_TOKEN=...`
   - include a manual test script

## Verification commands (must run and report)
- `docker compose -f brain_os/docker-compose.yml up --build`
- `pnpm -C lambic_voice_client install`
- `pnpm -C lambic_voice_client/apps/api dev` (or the repo's root dev command)
- `pnpm -C lambic_voice_client/apps/web dev`
- Manual: submit Task and confirm execution + idempotency

## Deliverables
- Code changes merged
- Updated docs:
  - `brain_os/docs/mvp_to_market.md` is authoritative
  - `lambic_voice_client/docs/current_state.md` includes the new env vars and the submission/confirmation flow
