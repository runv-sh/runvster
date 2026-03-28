# System Overview

## What Runvster Is

Runvster is a community product focused on a dense, list-first feed for links and discussion.

The current implementation is intentionally small:

- users can create accounts
- users can log in with email and password
- users can publish link posts or text posts
- posts can be tagged
- the homepage is a feed with basic filters
- posts support comments and replies
- posts support upvotes and downvotes
- the product includes notifications, moderation reports and admin review flows

## What Exists Today

The app already has:

- Rails monolith in `apps/web`
- PostgreSQL as the main database
- Redis in the stack
- Solid Queue worker process
- Mailpit for local mail capture
- Docker Compose for local runtime

## Current User Flows

### Read the feed

Visitors can open:

- `/`
- `/top`
- `/links`
- `/discussao`

### Create account

Account creation exists at:

- `/sign-up`

The signup route is available, but it is intentionally not promoted in the public navigation.

### Login

Login lives at:

- `/login`

`/sign-in` redirects to `/login`.

### Publish

Authenticated users can:

- open `/posts/new`
- publish a post with a title plus either a URL or body text
- attach between 1 and 3 tags

## Feed Behavior

Current feed modes:

- `Recentes`: newest posts first
- `Top`: ranking based on votes, comments and recency
- `Links`: only posts with URL
- `Discussao`: only text posts without URL

Important note:

The current `Top` feed is already backed by real activity, but it is still intentionally simple. The score combines post votes, comment volume and freshness instead of a more mature long-term ranking model.

## Current Gaps

The biggest missing parts are:

- production deployment setup
- deeper moderation actions beyond report triage
- richer notification preferences or digest flows
- CI/CD, monitoring and backup automation
- automated test coverage
