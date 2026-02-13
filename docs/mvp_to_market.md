# BrainOS — MVP to Market Plan (Authoritative)

This document defines the smallest set of phases needed to ship a **voice-first capture app** that reliably creates useful artifacts in Notion (tasks, list items, notes) using the BrainOS pipeline:

`lambic_voice_client (web+api) -> intent_normaliser (FastAPI) -> notion_gateway (n8n -> Notion)`

## MVP definition (what “in market” means)

A user can:
1. Record voice (or paste text) and get a transcript.
2. Choose a destination action (Task, Shopping/List item, Note/Knowledge).
3. Submit once and receive a **receipt** (trace_id + idempotency_key).
4. The system executes to Notion and returns a **confirmation** (Notion URL/ID) or **needs_clarification** with questions.
5. Re-submitting the same content is idempotent (no duplicate Notion objects).

## Canonical contracts

- Use `notion_assistant_contracts` as the source of truth for:
  - Light Intent Packet (input to normaliser)
  - Normalised Plan
  - Execution Outcome / Receipt envelope
  - Clarification envelope

Repo-local schemas must be removed or treated as deprecated compatibility only.

## Phases

### Phase 1 — Make the vertical slice work end-to-end (no new action types)
**Goal:** Voice app can successfully call the normaliser, and the UI can display executed / failed / needs_clarification.

Scope:
- Align endpoints:
  - Web app submits to `POST /v1/intents` (or normaliser provides alias `POST /v1/normalise`)
- Align response envelope:
  - Web parses the **shared** receipt/outcome schema
- Auth + CORS:
  - Bearer token pass-through to normaliser
- UX:
  - Show receipt (trace_id, receipt_id, idempotency_key)
  - Show executed details (Notion ID + URL if present)
  - Show failed details (error.code/message)
  - Show needs_clarification questions and allow answering them

Deliverables:
- Working dev runbook: `brain_os` compose + voice app running locally
- Manual test script + expected outputs

### Phase 2 — Broaden Notion actions to be “useful daily”
**Goal:** Support a wider, practical action set beyond tasks.

New action families (Notion):
- **Shopping/List item add** (append row to a designated “shopping” db or a list db)
- **Note capture** (append row to “knowledge” db, or create page + blocks)
- **Generic DB row create/update** (for future lists: tools, materials, expenses)
- (Optional) **Append blocks** to an existing page (for project notes)

This phase requires expanding both:
- `notion_gateway` endpoints + n8n flows
- `intent_normaliser` action planning/execution

### Phase 3 — Package for launch
**Goal:** A runnable, deployable “one command” stack + basic ops.

Scope:
- Containerize `lambic_voice_client` (web + api) OR document a robust non-Docker runbook.
- Add production-like config:
  - environment variables documented + sane defaults
  - health endpoints checked
- Observability:
  - structured logs + request/trace ids everywhere
- Security:
  - token storage guidance for the web app (dev vs prod)
  - rate limiting on public endpoints

### Phase 4 (Optional) — LLM-assisted packet creation (“Auto-structure”)
**Goal:** Turn one transcript into multiple structured actions safely.

Scope:
- Add `POST /v1/generate-packet` service (FastAPI “llm_proxy” or extend voice api).
- Schema-first JSON output with repair loop.
- UI: “Auto-structure” button, with review/edit before submit.

## What is explicitly NOT required for MVP
- Fully autonomous multi-step execution without user review
- Complex scheduling / calendar integration (can be modeled as tasks w/ due dates)
- Advanced retrieval / context augmentation (nice-to-have later)

## Verification checklist (MVP)
- [ ] Record voice -> transcript -> submit -> Notion task created
- [ ] Submit same transcript twice -> only one Notion object created (idempotent)
- [ ] Shopping item add works
- [ ] Note capture works
- [ ] Clarification flow works end-to-end (ask -> answer -> execute)
