# Jocus

Multiplayer game platform — real-time rooms with spectator mode, team play, and leaderboards.

This is the **orchestrator repo**. It pulls in the [client](https://github.com/DanielPenalozaB/jocus-client) and [server](https://github.com/DanielPenalozaB/jocus-server) as git submodules and wires everything together with Docker Compose.

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                    Traefik (:80)                     │
│         reverse proxy / path-based routing           │
├────────────┬────────────┬───────────┬───────────────┤
│  /         │  /api      │  /socket  │  /assets      │
│  Frontend  │  Backend   │  WebSocket│  MinIO         │
│  Next.js   │  Phoenix   │  Phoenix  │  Object Store  │
│  :3000     │  :4000     │  Channels │  :9000         │
└────────────┴─────┬──────┴───────────┴───────────────┘
                   │
          ┌────────┴────────┐
          │   PostgreSQL    │
          │   Redis         │
          └─────────────────┘
```

| Service    | Tech                 | Purpose                          |
|------------|----------------------|----------------------------------|
| Frontend   | Next.js 16 / React 19| Game UI, room management, PWA    |
| Backend    | Phoenix 1.7 / Elixir | REST API, WebSocket channels     |
| PostgreSQL | 16-alpine            | Player accounts, leaderboards    |
| Redis      | 7-alpine             | Cache, pub/sub                   |
| MinIO      | Latest               | Game assets (images, sounds)     |
| Traefik    | Latest               | Reverse proxy, path routing      |

## Quick Start

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and Docker Compose
- Git

### Clone

```bash
git clone --recurse-submodules https://github.com/DanielPenalozaB/jocus.git
cd jocus
```

If you already cloned without `--recurse-submodules`:

```bash
git submodule update --init --recursive
```

### Setup

```bash
cp .env.example .env    # Edit .env with your values
make setup              # Copies .env, sets up local DNS, starts containers
```

Or manually:

```bash
cp .env.example .env
docker compose up -d --build
```

### Access

| URL                      | Service          |
|--------------------------|------------------|
| `http://localhost`       | Frontend         |
| `http://localhost/api`   | Backend API      |
| `http://localhost/socket`| WebSocket        |
| `http://localhost:8080`  | Traefik dashboard|

### Makefile Commands

```bash
make up            # Start all services
make up-build      # Start with rebuild
make down          # Stop all services
make logs          # Follow all logs
make logs-backend  # Follow backend logs
make logs-frontend # Follow frontend logs
make build         # Build images
make setup         # First-time setup
make clean         # Reset everything (removes volumes)
make dev-frontend  # Run frontend outside Docker
make dev-backend   # Run backend outside Docker
```

## Development Workflow

Each submodule is its own repo. Work inside `client/` or `server/` and push changes from there:

```bash
# Work on the frontend
cd client
git checkout -b feature/my-feature
# ... make changes ...
git add -A && git commit -m "Add feature"
git push origin feature/my-feature

# Work on the backend
cd ../server
git checkout -b feature/my-feature
# ... make changes ...
git add -A && git commit -m "Add feature"
git push origin feature/my-feature
```

After submodule changes are merged to main, update the manager's pointers:

```bash
cd ..  # back to manager root
git submodule update --remote
git add client server
git commit -m "Update submodule refs"
git push
```

## Local Network Access

To play from other devices on your local network (phones, tablets):

```bash
sudo ./scripts/setup-local-dns.sh
```

This adds `jocus.local` entries to `/etc/hosts`. Other devices can connect via your machine's IP address directly.

For full network DNS resolution (so other devices resolve `jocus.local` automatically):

```bash
./scripts/setup-dns.sh
```

This installs and configures `dnsmasq` — other devices just need to point their DNS to your machine's IP.

## Environment Variables

See [`.env.example`](.env.example) for all required variables. Key ones:

| Variable              | Description                          |
|-----------------------|--------------------------------------|
| `DOMAIN`              | Local domain (default: `jocus.local`)|
| `POSTGRES_*`          | Database credentials                 |
| `DATABASE_URL`        | Ecto connection string               |
| `REDIS_URL`           | Redis connection string              |
| `MINIO_*`             | Object storage credentials           |
| `SECRET_KEY_BASE`     | Phoenix secret (generate with `mix phx.gen.secret`) |
| `NEXT_PUBLIC_API_URL` | API URL for the frontend             |
| `NEXT_PUBLIC_WS_URL`  | WebSocket URL for the frontend       |

## Repos

- **Manager (this repo)**: [github.com/DanielPenalozaB/jocus](https://github.com/DanielPenalozaB/jocus)
- **Client**: [github.com/DanielPenalozaB/jocus-client](https://github.com/DanielPenalozaB/jocus-client)
- **Server**: [github.com/DanielPenalozaB/jocus-server](https://github.com/DanielPenalozaB/jocus-server)
