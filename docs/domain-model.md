# Domain Model

## User

Main fields:

- `username`
- `email`
- `bio`
- `password_digest`
- `role`
- `posts_count`

Rules:

- username is lowercased
- username accepts only lowercase letters, numbers, and `_`
- username length is `3..24`
- email is lowercased
- password minimum length is `8`
- bio maximum length is `280`

Roles already exist in the model:

- `member`
- `moderator`
- `admin`

## Post

Main fields:

- `title`
- `url`
- `body`
- `user_id`

Rules:

- title is required
- title length is `8..140`
- a post must have either `url` or `body`
- body max length is `5000`
- each post must have between `1` and `3` tags

Feed helpers already exist:

- `recent_first`
- `top_first`
- `links_first`
- `discussion_first`

## Tag

Main fields:

- `name`
- `slug`
- `description`
- `posts_count`

Rules:

- tag name is normalized to lowercase slug-style text
- tag length is `2..24`
- description max length is `160`

Featured tags are currently ordered by:

- `posts_count`
- then `name`

## Tagging

`taggings` connect posts and tags.

Rules:

- one tag cannot be attached to the same post twice
- `posts_count` on tags is updated by counter cache

## Session

Authentication is email + password.

Current flow:

1. user posts to `/session`
2. Rails authenticates with `has_secure_password`
3. user id is stored in the Rails session
4. `Current.user` is restored on each request
