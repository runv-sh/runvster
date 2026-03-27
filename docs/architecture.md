# Runvster Architecture

## Product Thesis

Runvster is a curated community platform for builders.

It should support thoughtful discussion around links, text posts, releases, requests for feedback, and operational knowledge sharing. It should feel more modern and more maintainable than the legacy codebase we archived.

## What "Better" Means

Better does not mean "more features everywhere". It means:

- cleaner domain model
- better anti-spam and onboarding
- stronger moderation tooling
- better mobile usability
- clearer content types
- easier deployment and local setup

## Recommended Shape

Start as a modular monolith.

Why:

- the product is fundamentally CRUD plus community rules
- moderation and trust logic are easier to keep consistent in one app
- we will move faster with one deployable unit
- Docker remains simple

## Initial Stack

- Ruby `3.3`
- Rails `8`
- PostgreSQL `16`
- Redis `7`
- Solid Queue for jobs
- Hotwire for server-driven interactivity
- Tailwind for rapid UI composition
- Mailpit for local email testing

## Docker Topology

The local stack is designed around these services:

- `web`: Rails app
- `worker`: async jobs
- `db`: PostgreSQL
- `redis`: background and ephemeral state
- `mailpit`: local SMTP and email viewer

This gives us a developer experience close to production without turning the project into a distributed system.

## Domain Modules

### Accounts

- email/password auth
- invitation support
- optional onboarding review
- profile, bio, links, avatar

### Publishing

- link posts
- text posts
- release/showcase/request tags as first-class content cues
- drafts later, not in MVP

### Discussion

- threaded comments
- votes
- saves
- follows
- mentions and notifications

### Taxonomy

- tags
- optional sections or categories
- curated featured tags

### Moderation

- reports
- moderation queue
- audit log
- user notes
- shadow/limited modes for abuse handling

### Trust and Safety

- account age gates
- domain cooldowns
- duplicate detection
- rate limiting
- reputation thresholds

### Discovery

- home feed
- newest
- trending
- saved
- per-tag and per-user views
- search

### Operations

- admin dashboard
- health checks
- background job dashboard
- environment-driven config

## Core Data Model

Initial entities:

- `users`
- `invitations`
- `profiles`
- `posts`
- `post_links`
- `comments`
- `votes`
- `tags`
- `post_taggings`
- `reports`
- `moderation_actions`
- `notifications`
- `saved_posts`
- `follows`

## MVP Scope

Version 1 should include:

- authentication
- user profiles
- link and text posts
- threaded comments
- voting
- tags
- moderation queue
- admin tools
- notifications
- Docker-based local runtime

Version 1 should not include:

- federated features
- chat
- organizations/teams
- plugin architecture
- microservices

## Suggested Repository Structure

```text
apps/
  web/
bin/
docker/
  web/
docs/
assets/
compose.yaml
```

Inside the Rails app later:

```text
apps/web/app/
  controllers/
  components/
  models/
  queries/
  policies/
  services/
  jobs/
  views/
```

## Build Sequence

1. Bootstrap Rails app in `apps/web`.
2. Add auth, profiles, and invitations.
3. Add posts, comments, votes, and tags.
4. Add moderation queue, audit log, and notifications.
5. Add ranking, search, and digest jobs.

## Decision Notes

- PostgreSQL over MariaDB because the new project should lean into better indexing, JSON support, and modern query ergonomics.
- Redis stays optional in the long run, but it is useful enough for jobs, throttling, and realtime primitives to justify day-one inclusion.
- Modular monolith first. We only split services when a boundary becomes painful, measurable, and expensive enough to deserve it.
