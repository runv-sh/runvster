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

Engagement fields:

- `score`
- `votes_count`
- `comments_count`

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

## Invitation

Main fields:

- `inviter_id`
- `invitee_id`
- `recipient_email`
- `token`
- `accepted_at`
- `expires_at`
- `revoked_at`

Rules:

- first user becomes admin automatically
- after one month of account age, members unlock 5 total invites
- admins can invite without limit
- invites expire if they are not used in time

## Comment

Main fields:

- `post_id`
- `user_id`
- `parent_id`
- `body`

Rules:

- comments belong to posts
- comments can reply to other comments
- `comments_count` on posts is updated by counter cache

## Vote

Main fields:

- `post_id`
- `user_id`
- `value`

Rules:

- one vote per user per post
- vote can be `1` or `-1`
- post score is recalculated from vote values

## Notification

Notifications track:

- accepted invites
- comments on posts
- replies to comments
- moderation events

## ModerationCase

Moderation reports can target:

- posts
- comments
- user profiles

Statuses:

- `open`
- `reviewing`
- `resolved`
- `dismissed`

## AdminAction

Audit trail for admin operations such as:

- role changes
- moderation decisions
- tag curation

## Session

Authentication is email + password.

Current flow:

1. user posts to `/session`
2. Rails authenticates with `has_secure_password`
3. user id is stored in the Rails session
4. `Current.user` is restored on each request
