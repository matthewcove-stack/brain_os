# UC01 - Task Capture

Natural-language intent -> Notion Task (create or update).

## Goal
Demonstrate the Phase 1 vertical slice end-to-end:

1. Operator submits a request in natural language.
2. `intent_normaliser` normalises it into a deterministic plan.
3. When enabled, the plan is executed against Notion via `notion_gateway`.
4. The response is machine-readable and includes a stable Notion task identifier.
5. Retries do not create duplicates (idempotency).
6. Every step is written to an append-only audit trail (artifacts).

## Actors and services
- Operator (single user)
- `action_relay` (CLI client)
- `intent_normaliser` (API: ingest + normalise + optional execute)
- `notion_gateway` (API: task create/update webhooks)
- Notion (system of record)

## Inputs

### Intent packet (canonical)
A minimal intent packet that asks to create a task:

- `kind`: "intent"
- `intent_type`: "create_task" or "update_task"
- `natural_language`: free text
- Optional structured `fields` (may be empty)
- `request_id`: stable UUID for idempotency (recommended)

Example (create):

```json
{
  "kind": "intent",
  "intent_type": "create_task",
  "request_id": "2f4cf4c1-7b79-4d24-9bfa-1e2a4b4d6f3e",
  "natural_language": "Create a task: Order hinges tomorrow",
  "fields": {
    "title": "Order hinges",
    "due": "2026-02-04",
    "notes": "Blum full overlay"
  }
}
```

Example (update):

```json
{
  "kind": "intent",
  "intent_type": "update_task",
  "request_id": "bf1d2f9e-1b67-4b5a-8c9d-0c4c9b5f9f2d",
  "natural_language": "Mark the hinges task as done",
  "fields": {
    "task_id": "<notion_page_id>",
    "patch": { "status": "Done" }
  }
}
```

## Normalisation rules (Phase 1)
- Prefer explicit structured `fields` when present.
- If structured fields are missing, infer only safe fields:
  - `title`
  - optional `due` (in the configured user timezone)
  - optional `notes`
- When confidence is below threshold or required fields are missing, return `needs_clarification` (API-only is fine for Phase 1).

## Expected outputs

### Successful create/update
A successful Phase 1 response must include:

- `status`: "executed" (or "ready" if execution disabled)
- `intent_id`, `correlation_id`
- `details.request_id`
- `details.notion_task_id` (stable Notion page id)

### Error shape
Failures must be machine-readable:

- top-level `status`: "failed" (or "rejected")
- `error.code`, `error.message`
- optional `error.details.status_code` and gateway details

## Idempotency requirements
- If the same `request_id` is submitted twice, the second call MUST return the same `details.notion_task_id`.
- If a `request_id` is not provided, the system may fall back to a deterministic hash-based key, but Phase 1 smoke tests assume `request_id` is present.

## Audit trail (artifacts)
For each request, `intent_normaliser` must persist artifacts for:
- received intent
- normalised outcome (ready / needs_clarification / rejected)
- each executed action (success or failure)
- final outcome (executed / failed)

## Acceptance criteria
UC01 is done when all are true:

1. Create: a natural-language request results in a task in Notion.
2. Update: a natural-language request updates an existing task.
3. Idempotency: duplicate submissions with the same `request_id` do not create duplicates.
4. Response includes `details.notion_task_id` and `details.request_id`.
5. Errors surface cleanly using the standard error envelope.
6. Phase 1 smoke script passes: `brain_os/scripts/phase1_smoke.ps1`.

## How to run (local)
Use the repo-level instructions in `brain_os/docs/current_state.md`.

Quick run (from the Brain OS workspace):

1. `docker compose up -d --build`
2. `./scripts/phase1_smoke.ps1`
