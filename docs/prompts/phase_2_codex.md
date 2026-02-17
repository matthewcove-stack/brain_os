# Codex Phase Prompt — Phase 2 (Task lifecycle from voice)

You are implementing **Phase 2 only** as defined in `brain_os/docs/phase_plans/phase_2.md`.

## Goal
Allow changing task status from voice using deterministic parsing + Notion search + update, with clarification when ambiguous.

## Repos / edit map
- intent_normaliser/app (status intent detection, search, clarification, update plan)
- notion_gateway/n8n/workflows/v1_notion_search.json (ensure returns candidates with needed fields)
- notion_gateway/n8n/workflows/v1_tasks_update.json (status update supported)
- lambic_voice_client (no major UI changes; clarification modal should handle choices)
- tests under intent_normaliser/tests

## Implementation tasks
1) Detect status commands in natural language:
   - mark <task> done
   - start <task>  -> In Progress
   - pause <task>  -> Todo

2) Resolve task:
   - Call notion search webhook with query = extracted task phrase
   - If one clear match: plan = notion.task.update(page_id, status)
   - Else: return needs_clarification with candidate list (id + label + meta fields)

3) Clarification resume path:
   - When user selects a candidate, execute the update plan.

4) Tests:
   - Unit test: detection → search call → update plan generated.
   - Unit test: ambiguous candidates → clarification returned.

## Verification
- Create a task then say "start <title>" and confirm status changes in Notion.
- Ensure no regressions to Phase 1 auto capture.

## Mandatory enforcement (Drift Guard MCP)
Call:
- repo_contract_validate()
- verify_run(profile="default")
- drift_check()
Include JSON outputs in final report.
