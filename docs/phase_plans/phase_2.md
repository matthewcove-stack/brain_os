# Phase 2 — Task lifecycle from voice

## Outcomes
1. Change task status from voice:
   - Done / In Progress / Todo
2. Resolve target task by searching Notion:
   - auto-select when high confidence
   - ask clarification when ambiguous

## Scope
### In
- New normaliser intent patterns for status updates:
  - mark <task> done
  - start <task>
  - pause <task>
- Use notion search workflow to resolve task candidates.
- Use existing tasks update workflow to apply Status change.

### Out
- Creating new projects/lists.
- Scheduling/calendar events.
- Advanced prioritisation/recurrence.

## UX patterns
- Voice: "Mark call Bob done"
- Voice: "Start kitchen skirting" → In Progress
- Voice: "Pause kitchen skirting" → Todo

If multiple matches:
- Clarification modal shows top 5 matches (title + maybe due/status).
- User chooses one.

## Implementation notes
### intent_normaliser
- Add parsing for status verbs.
- When a status update intent is detected:
  1) call notion search endpoint with query extracted from utterance
  2) if single high-confidence candidate, build plan:
     - notion.task.update { page_id, status }
  3) else return needs_clarification with candidates.

- Clarification answer should contain chosen page/task id; on resume, execute update.

### notion_gateway
- Ensure the search workflow returns enough fields to disambiguate:
  - page_id
  - title
  - status
  - due
- Ensure tasks update workflow supports updating Status by name (Todo / In Progress / Done).

### lambic_voice_client
- No required UI changes beyond existing clarification modal.
- (Optional) add “Quick commands” help text.

## Verification
- Unit tests:
  - parse + plan generation for status intents
  - clarification returned for ambiguous match set
- Manual:
  - create task "Test lifecycle" then "start test lifecycle" and observe Notion status.
