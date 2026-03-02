---
name: lifecycle-hooks
description: Use Litestar lifecycle hooks for cross-cutting setup/teardown and request/response lifecycle instrumentation.
---

# Lifecycle Hooks

Use this skill when behavior must run at specific app/request lifecycle points.

## Workflow

1. Choose app-level startup/shutdown vs request lifecycle hooks.
2. Keep hook logic deterministic and lightweight.
3. Use hooks for cross-cutting instrumentation/policies.
4. Validate ordering interactions with middleware and events.

## Litestar References

- https://docs.litestar.dev/latest/usage/lifecycle-hooks.html
- https://docs.litestar.dev/latest/usage/events.html
