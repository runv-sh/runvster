# HTTP Routes

## Public Routes

| Method | Path | Purpose |
| --- | --- | --- |
| `GET` | `/` | Recent feed |
| `GET` | `/top` | Top feed |
| `GET` | `/links` | Link-only feed |
| `GET` | `/discussao` | Text discussion feed |
| `GET` | `/posts/:id` | Post detail |
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

## Protected Routes

| Method | Path | Purpose |
| --- | --- | --- |
| `GET` | `/posts/new` | New post form |
| `POST` | `/posts` | Create post |

## Redirects

| Method | Path | Redirect |
| --- | --- | --- |
| `GET` | `/sign-in` | `/login` |
| `GET` | `/index.html` | `/` |
| `GET` | `/www/index.html` | `/` |

## Notes

- The feed tabs shown in the UI are backed by real routes.
- `/login` is the canonical login entry point.
- signup exists, but it is not exposed in the public top navigation.
