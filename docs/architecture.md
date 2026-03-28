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

Background work is still light today, but the infrastructure is already being used or prepared for:

- invitation email delivery
- recurring queue cleanup in production
- future digests or moderation automation

## Current Domain Core

The current core tables are:

- `users`
- `posts`
- `tags`
- `taggings`
- `comments`
- `votes`
- `notifications`
- `moderation_cases`
- `invitations`
- `admin_actions`

## Design Direction

The interface currently favors:

- dense list reading
- light surfaces
- strong red brand accents
- minimal public navigation

## Planned Next Architecture Work

The next important product layers are:

- moderator/admin actions beyond triage
- richer notification settings and digest delivery
- production hardening and deploy automation
- observability, backups and queue monitoring
