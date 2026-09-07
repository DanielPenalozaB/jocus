.PHONY: up down build logs setup clean

# Start all services
up:
	docker compose up -d

# Start with rebuild
up-build:
	docker compose up -d --build

# Stop all services
down:
	docker compose down

# View logs
logs:
	docker compose logs -f

logs-backend:
	docker compose logs -f backend

logs-frontend:
	docker compose logs -f frontend

# Build images
build:
	docker compose build

# First-time setup
setup:
	cp -n .env.example .env || true
	sudo ./scripts/setup-local-dns.sh
	docker compose up -d

# Reset everything (volumes included)
clean:
	docker compose down -v
	docker system prune -f

# Dev mode - run frontend and backend outside Docker
dev-frontend:
	cd client && yarn dev

dev-backend:
	cd server && mix phx.server
