# Deploy

## Target

Primary target domain:

- `runvster.runv.club`

## Current State

Production deployment is not finished yet.

The project runs locally in Docker, but it still needs production-specific files and environment wiring.

## Expected Production Shape

- reverse proxy with TLS
- Rails web container
- Rails worker container
- PostgreSQL
- Redis

Mailpit should stay local only.

## Minimum Production Inputs

- DNS for `runvster.runv.club`
- Linux host or VPS with Docker Compose
- `SECRET_KEY_BASE`
- production `DATABASE_URL`
- production `REDIS_URL`
- SMTP provider credentials
- persistent database volume

## Production Checklist

1. add production environment variables
2. set `APP_HOST=runvster.runv.club`
3. define production compose or deploy stack
4. wire reverse proxy and TLS
5. configure Active Storage target
6. create backups for PostgreSQL
7. add monitoring and error tracking
8. create first admin account

## Missing Artifacts

These files do not exist yet and still need to be created:

- `compose.production.yaml`
- reverse proxy config
- production secret management strategy
- deployment script or CI/CD pipeline
