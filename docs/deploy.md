# Runvster Deploy Plan

## Target

Primary production target:

- `runvster.runv.club`

## Production Shape

Runvster should ship as a small Docker-based stack:

- `web`
- `worker`
- `postgres`
- `redis`
- reverse proxy with TLS

Mailpit is local-only and should not go to production.

## Minimum Production Requirements

- DNS for `runvster.runv.club`
- Linux host or VPS with Docker and Compose
- persistent volume for PostgreSQL
- persistent volume or managed storage for uploads
- TLS termination
- SMTP provider
- Rails secrets and environment variables

## Environment Variables We Will Need

- `RAILS_ENV=production`
- `APP_HOST=runvster.runv.club`
- `SECRET_KEY_BASE`
- `DATABASE_URL`
- `REDIS_URL`
- `RUNVSTER_DATABASE_PASSWORD`
- `SMTP_ADDRESS`
- `SMTP_PORT`
- `SMTP_USERNAME`
- `SMTP_PASSWORD`

## Production Tasks Before Launch

1. Set `config.hosts` for `runvster.runv.club`.
2. Replace placeholder mailer host values with the production domain.
3. Choose Active Storage target:
   - local volume for simple VPS setup
   - S3-compatible bucket for cleaner scaling
4. Add backups for PostgreSQL.
5. Add uptime and error monitoring.
6. Add deploy script or production Compose file.
7. Create first admin account and seed baseline data.

## Recommended Next Production File

When we start deploy work for real, the next infrastructure artifact should be:

- `compose.production.yaml`

That file should keep the same services we already use locally, but with:

- no dev-only bind mounts
- production env vars
- restart policies
- reverse proxy integration
- real SMTP and storage settings
