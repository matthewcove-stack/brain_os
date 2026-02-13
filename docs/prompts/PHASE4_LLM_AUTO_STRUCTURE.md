# Codex Phase 4 (Optional) — LLM Auto-Structure (Generate Packet)

## Phase goal
Allow one transcript to become multiple structured actions safely, with review before execution.

## Requirements
- Implement `POST /v1/generate-packet`
  - schema-first JSON output (validated against canonical contracts)
  - repair loop: if invalid JSON, retry with strict instructions
  - return `confidence` + `clarifying_questions` when needed
- UI:
  - Button: “Auto-structure”
  - Preview/editor of generated packet
  - Submit uses the same normaliser pipeline as Phase 1/2

## Safety constraints
- No autonomous execution without user review/confirm
- Never infer sensitive personal attributes; keep capture focused on tasks/notes/items

## Deliverables
- Service implementation + docs
- E2E demo: transcript -> packet -> create multiple Notion objects
