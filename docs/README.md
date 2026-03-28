# Runvster Docs

This folder documents the system as it exists today.

## Index

- [system-overview.md](system-overview.md)
- [architecture.md](architecture.md)
- [domain-model.md](domain-model.md)
- [http-routes.md](http-routes.md)
- [local-development.md](local-development.md)
- [deploy.md](deploy.md)
- [api.md](api.md)
- [roadmap.md](roadmap.md)
- [brand.md](brand.md)

## Current Status

Implemented today:

- Docker-first local stack
- invitation-only account creation
- login via `/login`
- server-side sessions
- user profiles
- link posts
- text posts
- tags
- tag pages
- comments
- votes on posts
- notifications inbox
- JSON API v1 for session, feed, posts, comments, votes, tags and notifications
- moderation reports
- admin role management and moderation queue
- feed filters: `Recentes`, `Top`, `Links`, `Discussao`

Still missing:

- deeper moderation actions like suspensions and takedowns
- richer notification preferences or digests
- production reverse proxy config and CI/CD
