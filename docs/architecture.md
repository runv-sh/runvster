# Architecture

## Shape

Runvster is a modular monolith.

There is one Rails application in `apps/web`, and the local runtime is orchestrated with Docker Compose.

## Services

The local stack has five services:

- `web`: Rails HTTP server
- `worker`: background job worker using Solid Queue
- `db`: PostgreSQL 16
- `redis`: Redis 7
- `mailpit`: local SMTP catcher and mail UI

## Runtime Layout

```text
compose.yaml
apps/
  web/
docker/
  web/
docs/
img/
```

## Request Flow

1. The browser reaches the Rails app on port `3000`.
2. Rails resolves routes from `config/routes.rb`.
3. Controllers load records through Active Record models.
4. Views render HTML server-side.
5. Session state is stored in the Rails session cookie.

## Background Work

The project already ships with a dedicated `worker` service.

Today there are no important product jobs yet, but the infrastructure is already in place for:

- notifications
- moderation jobs
- digests
- cleanup tasks

## Current Domain Core

The current core tables are:

- `users`
- `posts`
- `tags`
- `taggings`

## Design Direction

The interface currently favors:

- dense list reading
- light surfaces
- strong red brand accents
- minimal public navigation

## Planned Next Architecture Work

The next important product layers are:

- comments
- votes
- moderation entities
- tag pages
- feed ranking backed by real activity
