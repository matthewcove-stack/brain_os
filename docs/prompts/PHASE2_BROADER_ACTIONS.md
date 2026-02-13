# Codex Phase 2 — Broader Daily-Useful Actions (Notion)

## Phase goal
Expand the supported action set so the MVP is useful day-to-day:
- Add shopping/list item
- Capture a note/knowledge item
- Create generic DB rows (future-proof for materials/tools/expenses)

This phase updates both:
- `notion_gateway` (new endpoints + n8n flows + schemas)
- `intent_normaliser` (plan + execute new action types)
- `notion_assistant_contracts` (schema additions if needed)
- `lambic_voice_client` (UI destination picker + payload fields)

## Minimum action set (MVP+)
1) `notion.tasks.create` (already)
2) `notion.lists.add_item`
3) `notion.notes.capture`

## Proposed Notion Gateway endpoints (n8n)
Add the following POST webhooks (Authorization: Bearer token):
- `/v1/notion/lists/add_item`
- `/v1/notion/notes/capture`
- (Optional, for extensibility) `/v1/notion/db/rows/create`

Each endpoint must:
- accept `request_id`, `idempotency_key`, `actor`, and `payload`
- return the standard envelope + created Notion id + url where possible
- write to a request ledger (if configured) to support idempotency at the gateway layer too

## Registry additions
Extend OS registry mapping keys:
- `shopping_list` -> `shopping_list_db_id`
- `notes` -> `notes_db_id` (or re-use `knowledge_db_id` if you prefer)
Document this in `notion_gateway/docs/endpoints.md`.

## Normaliser changes
- Add new action types in the normalised plan model:
  - `notion.list.add_item`
  - `notion.note.capture`
- Determine action selection rules:
  - If packet contains `target.kind=list` and `target.key=shopping_list` -> list add
  - If packet contains `target.kind=notes` -> note capture
  - Else -> task create/update
- Ensure:
  - persist-first semantics remain
  - idempotency remains server-side

## Voice client changes
- Destination selector should offer:
  - Task
  - Shopping List Item
  - Note
- It should produce Light Intent Packets that include a `target` field sufficient for the normaliser to route deterministically.

## Verification commands
- Gateway: run n8n via brain_os compose; invoke new endpoints with curl; confirm Notion writes.
- Normaliser: unit tests for plan selection, plus integration test stubs.
- Voice UI: manual submit to shopping list + note capture.

## Deliverables
- n8n workflows + schemas committed
- Updated contracts and repo docs
- End-to-end demos for the three action types
