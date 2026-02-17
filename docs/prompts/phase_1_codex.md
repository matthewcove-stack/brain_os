# Codex Phase Prompt — Phase 1 (Frictionless capture defaults)

You are implementing **Phase 1 only** as defined in `brain_os/docs/phase_plans/phase_1.md`.

## Goal
Remove destination dropdown friction by adding an Auto mode and implementing safe server-side intent inference, and ensure task default status is always Todo.

## Repos / edit map
- lambic_voice_client/apps/web/src (UI default + packet shape)
- intent_normaliser/app/normalization.py (auto inference + default status)
- notion_gateway/n8n/workflows/v1_tasks_create.json (default status enforcement)
- Any tests under intent_normaliser/tests

Do not refactor unrelated code.

## Implementation tasks
1) Client: add destination `auto` and make it default.
   - In Auto mode, send minimal packet: natural_language + fields, omit target/intent_type.
   - Keep manual overrides for task/note/shopping.

2) Normaliser: support Auto packets.
   - If intent_type missing AND target missing:
     - infer shopping/task/note per phase plan
     - assign an inferred confidence
     - if ambiguous: return needs_clarification with 3 choices

3) Default task status:
   - In normaliser create_task canonical fields: set status = "Todo" if absent.
   - In notion gateway create workflow: if Status missing, set Status="Todo".

4) Tests:
   - Add unit tests for: shopping inference, task inference, note fallback, low-confidence clarification.
   - Add test that create_task includes status default.

## Verification commands
From the repo root that contains these services:
- `cd intent_normaliser && pytest -q`
- Bring up stack (as applicable): `cd brain_os && docker compose up -d --build`
- Quick manual: submit three examples from phase plan and confirm Notion writes.

## Completion criteria
- Manual destination selection is no longer required for successful capture.
- Tasks always land with Status=Todo.
- Explicit destinations still behave as before.
- Tests pass and docs/current_state.md updated.

## Mandatory enforcement (Drift Guard MCP)
Before completion, call:
- repo_contract_validate()
- verify_run(profile="default")
- drift_check()
Include the JSON outputs in the final report.
