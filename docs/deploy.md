# Deploy

## Target

Primary target domain:

- `runvster.runv.club`

## Current State

The app now has a first-pass production artifact set:

- [compose.production.yaml](../compose.production.yaml)
- [.env.production.example](../.env.production.example)
- [docker/nginx/default.conf](../docker/nginx/default.conf)

It still needs environment-specific secrets, reverse proxy hardening, backup automation and monitoring credentials before real launch.

## Expected Production Shape

- reverse proxy with TLS
- Rails web container
- Rails worker container
- PostgreSQL
- Redis
- SMTP provider
- error tracking and uptime monitoring

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

1. copy `.env.production.example` to `.env.production`
2. set `APP_HOST=runvster.runv.club`
3. generate and store `SECRET_KEY_BASE`
4. provision managed SMTP credentials
5. wire reverse proxy and TLS certificates
6. configure PostgreSQL backups and restore drills
7. add observability: logs, uptime checks, exception tracking, queue health
8. define retention rules for invites, notifications and moderation history
9. create the first admin account through the invite/bootstrap flow
10. run `docker compose -f compose.production.yaml up --build -d`

## Hardening Notes

- keep `credentials.yml.enc` under controlled access
- never commit `.env.production`
- configure `config.force_ssl = true` in production before public exposure
- set mailer host/domain from environment
- prefer managed PostgreSQL snapshots plus offsite backup copy
- monitor `SolidQueue` latency and failed jobs
- add request, job and moderation dashboards to whatever monitoring stack is chosen
- document incident response for spam, abuse and admin credential rotation

## Missing Pieces

- CI/CD pipeline or deploy script
- Sentry or equivalent fully wired
- backup automation scripts
