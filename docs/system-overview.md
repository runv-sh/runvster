# System Overview

## What Runvster Is

Runvster is a community product focused on a dense, list-first feed for links and discussion.

The current implementation is intentionally small:

- users can create accounts
- users can log in with email and password
- users can publish link posts or text posts
- posts can be tagged
- the homepage is a feed with basic filters

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
- `Top`: temporary ranking based on tag signal and recency
- `Links`: only posts with URL
- `Discussao`: only text posts without URL

Important note:

The current `Top` feed is only a placeholder. Since the system still does not have votes or comments, this ranking is not yet a real community ranking algorithm.

## Current Gaps

The biggest missing parts are:

- comments
- votes
- moderation
- notifications
- admin
- production deployment setup
