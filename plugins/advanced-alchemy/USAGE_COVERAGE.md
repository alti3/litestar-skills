# Advanced Alchemy Usage Coverage Matrix

This file maps current Advanced Alchemy getting-started and usage documentation pages to repository skills.

- Source indexes reviewed:
  - https://advanced-alchemy.litestar.dev/latest/getting-started.html
  - https://advanced-alchemy.litestar.dev/latest/usage/index.html
- Supplemental sources reviewed:
  - https://github.com/litestar-org/advanced-alchemy/blob/main/README.md
  - https://github.com/litestar-org/advanced-alchemy/blob/main/examples/litestar/litestar_service.py
- Last reviewed: 2026-03-09

## Coverage

| Usage page | Covered by skill |
|---|---|
| /latest/getting-started.html | getting-started |
| /latest/usage/index.html | getting-started |
| /latest/usage/modeling.html | modeling |
| /latest/usage/repositories.html | repositories |
| /latest/usage/services.html | services |
| /latest/usage/routing.html | routing |
| /latest/usage/types.html | types |
| /latest/usage/caching.html | caching |
| /latest/usage/cli.html | cli |
| /latest/usage/database_seeding.html | database-seeding |
| /latest/usage/frameworks/litestar.html | litestar |
| /latest/usage/frameworks/flask.html | flask |
| /latest/usage/frameworks/fastapi.html | fastapi |

## Notes

- `advanced-alchemy-getting-started` covers the bootstrap path across package install, sync or async configuration, and first CRUD wiring.
- The GitHub README and Litestar example are supplemental references for `advanced-alchemy-litestar`, but they are not usage-site pages so they are not listed in the matrix.
- Each page maps to one primary skill for discovery simplicity; related concerns are linked in cross-skill handoff sections inside the skill files.
