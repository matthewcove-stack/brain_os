# BrainOS Deploy Runbook (Phase 3)

## Deployment model

Phase 3 uses a single VPS with Docker Compose:
- `intent_normaliser`
- `notion_gateway` (n8n + postgres)
- `voice_api`
- `voice_web`

Optional public ingress:
- Cloudflare Tunnel in front of `voice_web` and selected API routes.

## Required secrets

Do not commit these values:
- `OPENAI_API_KEY`
- `INTENT_SERVICE_TOKEN`
- `GATEWAY_BEARER_TOKEN`
- `NOTION_API_KEY`
- `API_BEARER_TOKEN`
- `BOOTSTRAP_BEARER_TOKEN`
- n8n auth and encryption values in `notion_gateway/.env`

## Local/prod env checklist

Set at minimum:
- `INTENT_SERVICE_TOKEN`
- `GATEWAY_BEARER_TOKEN`
- `OPENAI_API_KEY`
- `EXECUTE_ACTIONS=true`

Optional:
- `VOICE_API_RATE_LIMIT_RPM` (default `120`)
- `VOICE_API_CORS_ORIGINS`
- `TRANSCRIBE_MODEL`

## Bring-up

From `brain_os/`:

```bash
docker compose up --build -d
```

Services:
- Voice web: `http://localhost:8088`
- Voice API health: `http://localhost:8787/healthz`
- Intent normaliser health: `http://localhost:8000/health`
- n8n: `http://localhost:5678`

## Smoke test

Run:

```powershell
powershell -File scripts/phase3_smoke.ps1
```

## Monitoring checklist

- Health checks green for:
  - `voice_api`
  - `voice_web`
  - `intent_normaliser`
  - `notion_gateway`
- Logs include correlation metadata:
  - Voice API emits `x-correlation-id` and logs `correlation_id`
  - Intent normaliser logs include `trace_id` and `receipt_id`
- 429s are visible for abusive clients (rate-limit working)
- No secrets appear in application logs
