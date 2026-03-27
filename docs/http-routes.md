# HTTP Routes

## Public Routes

| Method | Path | Purpose |
| --- | --- | --- |
| `GET` | `/` | Recent feed |
| `GET` | `/top` | Top feed |
| `GET` | `/links` | Link-only feed |
| `GET` | `/discussao` | Text discussion feed |
| `GET` | `/posts/:id` | Post detail |
| `GET` | `/tags/:id` | Tag page |
| `GET` | `/u/:username` | Public user profile |
| `GET` | `/login` | Login page |
| `GET` | `/sign-up` | Account creation page |
| `GET` | `/up` | Health check |

## Auth Routes

| Method | Path | Purpose |
| --- | --- | --- |
| `POST` | `/session` | Create session |
| `DELETE` | `/sign-out` | Destroy session |
| `POST` | `/users` | Create account |
| `GET` | `/notifications` | Notification inbox |
| `PATCH` | `/notifications/:id` | Mark notification as read |

## Protected Routes

| Method | Path | Purpose |
| --- | --- | --- |
| `GET` | `/posts/new` | New post form |
| `POST` | `/posts` | Create post |
| `POST` | `/posts/:post_id/comments` | Create comment |
| `POST/PATCH/DELETE` | `/posts/:post_id/vote` | Vote on post |
| `POST` | `/invitations` | Send invite |
| `POST` | `/moderation_cases` | Report content/profile |
| `GET` | `/dashboard` | Member or admin dashboard |

## Admin Routes

| Method | Path | Purpose |
| --- | --- | --- |
| `GET` | `/admin/users` | Manage roles |
| `PATCH` | `/admin/users/:id` | Edit user and role |
| `DELETE` | `/admin/users/:id` | Delete user |
| `GET` | `/admin/posts` | Manage posts |
| `PATCH` | `/admin/posts/:id` | Edit post |
| `DELETE` | `/admin/posts/:id` | Delete post |
| `GET` | `/admin/comments` | Manage comments |
| `PATCH` | `/admin/comments/:id` | Edit comment |
| `DELETE` | `/admin/comments/:id` | Delete comment |
| `GET` | `/admin/invitations` | Manage invites |
| `PATCH` | `/admin/invitations/:id` | Revoke invite |
| `DELETE` | `/admin/invitations/:id` | Delete invite |
| `GET` | `/admin/moderation_cases` | Moderation queue |
| `PATCH` | `/admin/moderation_cases/:id` | Resolve moderation case |
| `GET` | `/admin/tags` | Curate tag descriptions |
| `PATCH` | `/admin/tags/:id` | Edit tag |
| `DELETE` | `/admin/tags/:id` | Delete tag |

## Redirects

| Method | Path | Redirect |
| --- | --- | --- |
| `GET` | `/sign-in` | `/login` |
| `GET` | `/index.html` | `/` |
| `GET` | `/www/index.html` | `/` |

## Notes

- The feed tabs shown in the UI are backed by real routes.
- `/login` is the canonical login entry point.
- signup is invitation-only after the first admin account exists.
