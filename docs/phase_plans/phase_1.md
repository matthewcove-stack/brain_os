# Phase 1 — Frictionless capture defaults

## Outcomes
1. The user can submit voice/text without choosing a destination dropdown.
2. The system infers intent type safely:
   - shopping/list item
   - task create
   - note capture
3. Newly created tasks always have `Status = Todo`.

## Scope
### In
- Add an **Auto** destination in the client (default).
- Normaliser: when no explicit target/intent_type is provided, infer intent from `natural_language`.
- Ensure the task create path sends/sets a default status.
- Notion gateway: enforce `Status = Todo` if missing.

### Out
- Task status updates (Phase 2).
- URL/file capture (Phase 3).
- Any multi-user auth; keep current bearer tokens.

## Proposed inference rules (MVP, deterministic)
Use a conservative rule set before any model-based inference.

### Shopping/list item
Trigger if:
- NL contains strong purchase verbs: "buy", "get", "pick up", "order"
- OR contains retailer keywords: "screwfix", "toolstation", "amazon"
- OR starts with "shopping" / "add to shopping".

Action:
- intent_type = add_list_item
- list_key = shopping_list
- item = natural_language (trim)

### Task create
Trigger if:
- NL starts with an imperative verb (simple heuristic) OR contains "to do" phrasing.
Examples:
- "Call Bob"
- "Book dentist"
- "Fix the hinge"

Action:
- intent_type = create_task
- title = natural_language (trim)
- status = Todo (default)
- optional due inference continues as-is (existing due parsing)

### Note capture (fallback)
If neither shopping nor task triggers, capture as note.

Action:
- intent_type = capture_note
- title = first 80 chars
- content = natural_language

## Confidence + clarification
- If the packet provides `confidence` and it is below existing policy threshold, keep current reject.
- For auto inference, compute a simple confidence:
  - strong match → 0.9
  - weak match → 0.7
  - fallback note → 0.8
- If inferred confidence < min_confidence_to_write, return needs_clarification with choices:
  - Task
  - Note
  - Shopping list item

## File-level changes (expected)
### lambic_voice_client
- Add `Destination = 'auto'`.
- Default selection to `auto`.
- `buildPacket` should emit minimal packet for auto:
  - kind/schema_version/source/natural_language/fields
  - omit target and intent_type unless user explicitly chose a destination.

### intent_normaliser
- In `normalize_intent`, handle auto packets:
  - when `target.kind` missing and `intent_type` missing, infer as above.
- For create_task, set default status field if missing.

### notion_gateway
- In `v1_tasks_create`, ensure Status defaults to Todo if not provided.

## Verification
- Unit tests in intent_normaliser for inference cases.
- Manual smoke:
  - submit text "Buy cable clips" → shopping list
  - "Call Bob tomorrow" → task with Due + Status Todo
  - "Thought: we should change the primer workflow" → note
