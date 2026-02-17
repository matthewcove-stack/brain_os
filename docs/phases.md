# Brain OS — Phases

This repo is a multi-service, single-operator "execution kernel" for capture → normalise → execute → store in Notion.

Truth: If docs conflict, `docs/current_state.md` is authoritative.

## Phase 0 (done)
- MVP capture loop deployed (voice_web → voice_api → intent_normaliser → notion_gateway → Notion)
- Cloudflare Tunnel deployment path documented
- Idempotency workflows in notion_gateway wired

## Phase 1 — Frictionless capture defaults (NOW)
Goal: remove UI friction and ensure safe defaults so capture can happen at speed.

Deliverables:
- **Auto intent inference** when the client does not specify destination:
  - Detect "shopping/list" vs "task" vs "note" from natural language.
  - Use a conservative confidence threshold; fall back to clarification when ambiguous.
- **Default task status = `Todo`** for newly created tasks (always).
- Client UX: make **Auto** the default; keep manual overrides (Task / Note / Shopping) as secondary.

Acceptance criteria:
- A user can record/submit without choosing a dropdown, and an appropriate entity is created in Notion.
- Newly created tasks always have `Status = Todo` (even if upstream omitted status).
- No regression to existing explicit destinations (task/note/shopping_list still work).

## Phase 2 — Task lifecycle from voice (NEXT)
Goal: make tasks operable from voice with minimal state machine.

Deliverables:
- Support voice commands that update task status:
  - "mark <task> done"
  - "start <task>" → In Progress
  - "pause <task>" → Todo
- Task resolution:
  - Use notion search to find candidate tasks.
  - Auto-select when confidence is high; otherwise ask clarification with candidate list.
- Notion views (documented, not automated):
  - Tasks Board (Kanban by Status)
  - Today (Due today or no due, not Done)
  - Backlog (Todo, no Due)

Acceptance criteria:
- From voice, a user can change a task status without manually opening Notion.
- When multiple tasks match, the system asks a clarification question with choices.

## Phase 3 — URL + file capture (THEN)
Goal: capture more than plain text/audio without breaking the simple pipeline.

Deliverables:
- **URL capture**:
  - Detect URL(s) in input.
  - Store as a Note with title + URL + optional excerpt.
  - Tag as `url` (and optionally `research` if inferred).
- **File capture (MVP)**:
  - Drag/drop or pick a file in the client.
  - For text-like files (txt/md/json/csv): include extracted text in a Note.
  - For binary files (pdf/images): store filename + hash + size and (MVP) attach as a placeholder link (no binary storage yet).
- Document the upgrade path for real binary storage (Phase 4+): object storage + signed URLs.

Acceptance criteria:
- A URL pasted into the voice app produces a Note with the URL recorded.
- A dropped `.txt` file produces a Note with the file content captured.
- Binary files do not crash; they produce a useful placeholder note.

---

See detailed phase plans in:
- `docs/phase_plans/phase_1.md`
- `docs/phase_plans/phase_2.md`
- `docs/phase_plans/phase_3.md`
