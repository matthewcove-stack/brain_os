# Codex Prompt - Phase 1 (UC01 Task Capture)

You are working in the Brain OS multi-repo workspace.

Implement Phase 1 for UC01 only: "Natural-language intent -> Notion Task create/update".

Do NOT implement Phase 2+ features (clarification UI, calendar, multi-user, background sync, new action types).

## Truth hierarchy
Follow the repo truth hierarchy. If any docs conflict:
1. `brain_os/docs/current_state.md`
2. `*/docs/current_state.md` in the repo you are editing
3. `INTENT.md`
4. `*/docs/phases.md`
5. `README.md`
6. Code

## Target behavior (acceptance criteria)
UC01 is complete when all are true:

1. A natural-language "create task" intent results in a Notion task.
2. A natural-language "update task" intent updates an existing Notion task.
3. Idempotency: duplicate submissions with the same `request_id` return the same `details.notion_task_id`.
4. Success response includes `details.request_id` and `details.notion_task_id`.
5. Failure response includes machine-readable `error.code`, `error.message`, and (when available) `error.details.status_code`.
6. Artifacts are written for received, outcome, action execution, and final outcome.
7. The Windows smoke test passes: `brain_os/scripts/phase1_smoke.ps1`.

## Scope of code changes
Make the smallest set of changes needed to ensure the acceptance criteria above.

Prefer working primarily in `intent_normaliser` (it is the orchestrator). Only change `notion_gateway` if the gateway response does not provide a stable Notion id or idempotency is broken.

Do not change public endpoint paths.
Do not change contract schemas unless strictly required; if you must, update `notion_assistant_contracts` and bump version.

## Implementation tasks

### A) intent_normaliser: ensure executed responses are stable and idempotent
1. Confirm `POST /v1/intents` returns a terminal outcome when the request is a duplicate:
   - If an intent already exists for the same `request_id`, return the stored executed outcome (including `details.notion_task_id`) without creating a second Notion task.
2. Ensure that on successful execution:
   - `IngestResponse.status` is `executed`
   - `details.notion_task_id` is set from the gateway response `data.notion_page_id` (or equivalent)
   - `details.request_id` equals the original request_id
3. Ensure errors from notion_gateway propagate to the response as:
   - `status=failed`
   - `error.code`, `error.message`, and `error.details.status_code` when known
4. Persist artifacts for:
   - received intent
   - normalised outcome
   - action execution request/response
   - final outcome

### B) notion_gateway: only if needed
If gateway does not reliably return a stable id in `data.notion_page_id`, or idempotency-by-request_id is not enforced, fix that with minimal workflow/code changes.

### C) Tests
1. Add or update tests in `intent_normaliser/tests`:
   - create task with request_id returns executed + notion_task_id
   - same request repeated returns same notion_task_id (idempotency)
   - gateway error returns failed + error envelope
2. Keep tests docker-runnable.

### D) Docs
Update only docs that changed due to your behavior changes:
- `intent_normaliser/docs/current_state.md` (What works today + verification)
- If you touched gateway behavior, update `notion_gateway/docs/current_state.md`

## Local verification commands
From the Brain OS workspace:

1. Start services:
   - `docker compose up -d --build`
2. Run the Phase 1 smoke test (Windows PowerShell):
   - `./scripts/phase1_smoke.ps1`
3. Repo tests (as needed):
   - `cd intent_normaliser && docker compose run --rm api pytest`
   - `cd notion_gateway && docker compose run --rm smoke all`

## Deliverables
- Code changes committed in the appropriate repo(s)
- Tests passing
- Docs updated where behavior changed

Stop when Phase 1 passes end-to-end.
