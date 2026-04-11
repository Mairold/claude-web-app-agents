# Docker Rules

## Ports
- Never expose ports to host (`0.0.0.0`) by default — use `127.0.0.1:PORT:PORT` for local-only access
- If a port must be exposed externally, ask the user first
- Test containers (`docker-compose.test.yml`) must never expose database ports to host — backend connects via docker network

## Compose
- Use `docker compose` (v2), not `docker-compose` (v1)
- Prefer named volumes over bind mounts for data persistence
- Use `tmpfs` for test databases (speed, no cleanup)
- Multi-arch images only — no `amd64/` prefixed base images (must work on ARM and x86)

## Security
- Never put secrets in Dockerfile or docker-compose.yml — use env vars or `.env` file
- `.env` must be in `.gitignore`
- Run containers as non-root when possible
