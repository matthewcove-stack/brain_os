# Brain OS — Current State (Authoritative)

## What works
- Intent ingestion and normalisation
- Shared schema contracts
- Notion Gateway API surface
- Manual local execution

## What is incomplete
- Action execution partially stubbed
- Context sync is manual
- No clarification UI
- No automated end-to-end tests

## Phase 1 verification (planned)
A Phase 1 implementation is considered complete only when:
- A natural-language intent creates or updates a Notion task
- Duplicate submissions are idempotent
- Errors are surfaced clearly to the user
- All verification commands pass

## Phase 1 how to run (Windows)
Prereqs:
- Ensure `notion_gateway/.env` exists (copy from `notion_gateway/.env.example`) and set `NOTION_API_KEY` and `API_BEARER_TOKEN`.
- Ensure the n8n workflows in `notion_gateway/n8n/workflows/` are imported and activated.
- Keep `GATEWAY_BEARER_TOKEN` in `docker-compose.yml` aligned with `API_BEARER_TOKEN` in `notion_gateway/.env` (defaults to `change_me_api_token`).
- If you changed `INTENT_SERVICE_TOKEN`, set `$env:INTENT_SERVICE_TOKEN` before running the smoke script.

Start services (builds containers):
```
docker compose up -d --build
```

Run the Phase 1 smoke test:
```
.\scripts\phase1_smoke.ps1
```

Expected output:
- `Phase 1 smoke test succeeded. notion_task_id=<id>`

Success means:
- The same Notion task id is returned for both requests using the same `request_id`.

## Verification
Check container status:
```
docker compose ps
```

View logs for failures:
```
docker compose logs -f intent_normaliser
docker compose logs -f notion_gateway
```

## Constraints
- Single user
- Notion is the system of record
- Reliability over cleverness
