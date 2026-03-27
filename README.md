# Runvster

Runvster is our clean-slate community platform.

We are not rebuilding Lobsters. We are using it as historical reference and starting fresh with a sharper product, stronger moderation tools, better onboarding, and a Docker-first developer experience.

## Product Direction

Runvster is meant to be a curated community for builders. The first version should feel fast, opinionated, and trustworthy.

Core product bets:

- posts can be links or text, but they should feel structured and easy to scan
- moderation is first-class, not an afterthought
- onboarding and anti-spam controls exist from day one
- mobile and desktop both matter
- the app stays monolithic until complexity earns something else

## Visual Direction

The logo points us toward a bold brand:

- primary brand color: `#F01010`
- support red: `#E01010`
- deep red shadow: `#C00010`
- primary foreground: `#FFFFFF`
- inferred neutral text: `#141414`

Detailed brand tokens live in [docs/brand.md](docs/brand.md).

## Architecture Direction

We are starting with:

- Rails 8 monolith
- PostgreSQL for the main relational data model
- Redis for realtime/ephemeral concerns
- Solid Queue for async jobs
- Hotwire + Tailwind for the web UI
- Mailpit for local email testing
- Docker Compose as the default local runtime

More detail lives in [docs/architecture.md](docs/architecture.md).

## Repository Layout

```text
.
|- apps/
|  |- web/              # Rails monolith
|- assets/              # source brand assets
|- bin/                 # local helper scripts
|- docker/
|  |- web/              # Docker image for the Rails app
|- docs/                # product, brand, and architecture decisions
|- compose.yaml         # Docker Compose stack
```

## First Build Phases

1. Bootstrap the Rails app inside `apps/web`. Done.
2. Implement auth, profiles, posts, comments, votes, tags, moderation.
3. Add notifications, digests, anti-abuse tooling, and admin workflows.

## Local Workflow

The local stack now boots with Docker Compose.

Primary entry points:

- `docker compose up --build`
- `http://localhost:3000`
- `http://localhost:8025`

Bootstrap scripts still exist in case we ever need to regenerate the Rails app:

- `./bin/bootstrap.sh`
- `.\bin\bootstrap.ps1`
