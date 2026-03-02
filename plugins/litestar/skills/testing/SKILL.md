---
name: testing
description: Test Litestar applications with test clients, dependency overrides, lifecycle control, and deterministic API assertions.
---

# Testing

Use this skill when implementing or fixing Litestar test suites.

## Workflow

1. Build app fixtures with predictable config.
2. Use Litestar test client for endpoint assertions.
3. Override dependencies for isolation.
4. Cover error paths, auth boundaries, and serialization behavior.

## Checklist

- Test both success and failure contracts.
- Verify startup/shutdown side effects when relevant.
- Use table-driven cases for parameterized route behavior.

## Litestar References

- https://docs.litestar.dev/latest/usage/testing.html
