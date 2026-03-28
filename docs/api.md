# API

## Base

- namespace: `/api/v1`
- format: JSON
- authentication: Rails session cookie or `Authorization: Bearer <token>`

## Authentication

- Browser clients can keep using the normal Rails session cookie.
- Personal access tokens can be generated from the account screen and both dashboards.
- Send tokens in the `Authorization` header as `Bearer <token>`.
- Tokens inherit the same permissions and account restrictions as the user who created them.

## Current Endpoints

### Session

- `GET /api/v1/session`
- `POST /api/v1/session`
- `DELETE /api/v1/session`

### Posts

- `GET /api/v1/posts`
- `GET /api/v1/posts/:id`
- `POST /api/v1/posts`
- `PATCH /api/v1/posts/:id`
- `DELETE /api/v1/posts/:id`

Filters accepted by `GET /api/v1/posts`:

- `tab`
- `q`
- `tag`
- `author`
- `period`
- `page`

### Comments

- `POST /api/v1/posts/:post_id/comments`
- `PATCH /api/v1/posts/:post_id/comments/:id`
- `DELETE /api/v1/posts/:post_id/comments/:id`

### Votes

- `POST /api/v1/posts/:post_id/vote`
- `PATCH /api/v1/posts/:post_id/vote`
- `DELETE /api/v1/posts/:post_id/vote`

### Tags

- `GET /api/v1/tags`
- `GET /api/v1/tags/:id`

Optional query on tags:

- `featured=true`

### Notifications

- `GET /api/v1/notifications`
- `PATCH /api/v1/notifications/:id`

## Notes

- The API reuses the same moderation, invite, email verification and account restriction rules already active in the HTML app.
- Hidden posts remain inaccessible to non-staff consumers.
- Session creation returns the current user payload for immediate client bootstrap.
