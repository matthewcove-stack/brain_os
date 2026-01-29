# AGENTS.md — Brain OS

## Truth hierarchy
If documents conflict, the order of authority is:
1. docs/current_state.md
2. docs/intent.md
3. docs/phases.md
4. README.md
5. Code

## Phase discipline
Only implement the explicitly requested phase.
Do not pre-empt future phases.

## Assumptions
Ask questions only if missing information affects:
- user-visible behaviour
- security or privacy
- data integrity

Otherwise make the smallest reasonable assumption and note it.

## Verification
A phase is complete only when:
- services start successfully
- declared verification commands pass
- docs/current_state.md is updated
