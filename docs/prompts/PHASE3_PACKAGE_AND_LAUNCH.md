# Codex Phase 3 — Package & Launch (Ops + Deployment)

## Phase goal
Make the stack deployable with minimal friction and safe defaults.

## Options (pick one and implement fully)
A) Single VPS (recommended for first launch)
- `brain_os` docker-compose runs:
  - intent_normaliser
  - notion_gateway (n8n)
  - postgres
  - voice api + web (containerised)
- Add Cloudflare Tunnel for HTTPS ingress

B) Split hosting
- Web: Vercel / Netlify
- APIs: VPS or managed container host
- Still keep a single local dev compose that mirrors prod config.

## Required work
- Containerize `lambic_voice_client` (web + api) with:
  - Dockerfiles
  - compose service definitions
  - health endpoints
- Add rate limiting at the public edge (or at voice api)
- Add structured logs with correlation_id everywhere
- Ensure secrets are documented (never committed):
  - OpenAI key
  - Notion token (n8n)
  - Bearer tokens between services

## Deliverables
- `brain_os/docs/deploy.md` with step-by-step runbook
- Minimal monitoring checklist
- Smoke test script (curl) for health + action endpoints
