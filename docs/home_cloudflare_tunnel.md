# Home hosting with Cloudflare Tunnel (Option 1)

This enables the Lambic voice capture loop to work from your phone anywhere, while keeping your home router closed (no port forwarding).

## What this adds
- A `cloudflared` container (outbound-only) that connects your home stack to Cloudflare.
- Build-time env wiring for `voice_web` so the PWA calls your public hostnames (not localhost).

## Prereqs
- A Cloudflare account with your domain on Cloudflare DNS.
- Cloudflare Zero Trust enabled (free tier is fine for a single user).
- Docker + Docker Compose on your home server.

## Step 1 — Create the tunnel in Cloudflare
In Cloudflare Zero Trust:
1. **Networks → Connectors → Cloudflare Tunnels → Create a tunnel**
2. Choose **Cloudflared**
3. Name it (e.g. `brainos-home`)
4. Copy the **token** (you'll paste it into `brain_os/.env` as `CLOUDFLARE_TUNNEL_TOKEN`)

## Step 2 — Add Public Hostnames (three)
Inside the tunnel, add these hostname routes:

- `voice.<yourdomain>`  → `http://voice_web:8080`
- `voice-api.<yourdomain>` → `http://voice_api:8787`
- `intake.<yourdomain>` → `http://intent_normaliser:8000`

Do **not** expose `notion_gateway` unless you specifically need remote access to n8n.

## Step 3 — Configure env for your hostnames
Copy the example env file:

```bash
cp brain_os/.env.example brain_os/.env
```

Edit `brain_os/.env` and set:
- `CLOUDFLARE_TUNNEL_TOKEN`
- `OPENAI_API_KEY`
- `INTENT_SERVICE_TOKEN` (long random)
- `GATEWAY_BEARER_TOKEN` (must match `API_BEARER_TOKEN` used by notion_gateway)
- `VITE_*` URLs to match the hostnames you configured above
- `VOICE_API_CORS_ORIGINS` to `https://voice.<yourdomain>`

## Step 4 — Start the stack (with tunnel)
From `brain_os/`:

```bash
docker compose --env-file .env \
  -f docker-compose.yml \
  -f docker-compose.cloudflare-tunnel.yml \
  up --build -d
```

## Step 5 — Quick checks
On the home server:

```bash
curl -s http://localhost:8088/healthz
curl -s http://localhost:8787/healthz
curl -s http://localhost:8000/healthz
```

From your phone (once Cloudflare hostnames are active):
- Open `https://voice.<yourdomain>`
- Install to home screen (PWA)
- Record a note and confirm it lands in Notion

## Suggested hardening (fast)
- Put Cloudflare **Access** in front of `voice.<yourdomain>` so only you can open the UI.
- Leave `voice-api` + `intake` protected by bearer tokens + rate limiting (already in this stack), or also wrap them with Access if you want belt-and-braces.
