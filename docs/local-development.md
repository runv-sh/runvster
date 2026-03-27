# Local Development

## Requirements

- Docker Desktop
- Docker Compose

No Ruby or PostgreSQL installation is required on the host for normal local use.

## Start

```bash
docker compose up --build -d
```

## Stop

```bash
docker compose down
```

## Main URLs

- app: `http://localhost:3000`
- login: `http://localhost:3000/login`
- mail UI: `http://localhost:8025`

## Services

- `web`
- `worker`
- `db`
- `redis`
- `mailpit`

## Useful Commands

Show status:

```bash
docker compose ps
```

Follow logs:

```bash
docker compose logs -f web worker
```

Open Rails console:

```bash
docker compose exec web bin/rails console
```

Run migrations manually:

```bash
docker compose exec web bin/rails db:prepare
```

## Notes

- `db:prepare` already runs during container startup.
- the worker starts with `rails solid_queue:start`
- Mailpit is local-only
- if the browser shows stale UI after CSS changes, force refresh with `Ctrl+F5`

## Bootstrap Scripts

These scripts still exist if the Rails app ever needs to be regenerated:

- `bin/bootstrap.sh`
- `bin/bootstrap.ps1`
