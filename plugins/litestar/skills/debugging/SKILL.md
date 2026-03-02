---
name: debugging
description: Debug Litestar applications with structured diagnostics, error surfacing, and environment-aware troubleshooting workflows.
---

# Debugging

Use this skill for runtime issue investigation in Litestar services.

## Workflow

1. Enable safe debug settings in local environments only.
2. Reproduce with minimal route/test case.
3. Inspect logs, exception handlers, and middleware interactions.
4. Fix root cause and add regression tests.

## Checklist

- Never expose debug mode in production.
- Capture request context for failures.
- Verify both success and failure response contracts after fixes.

## Litestar References

- https://docs.litestar.dev/latest/usage/debugging.html
