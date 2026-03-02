---
name: debugging
description: Debug Litestar services using reproducible failure isolation, environment-safe diagnostics, log/trace correlation, and targeted regression checks. Use when investigating runtime errors, unexpected middleware behavior, or lifecycle issues. Do not use as a substitute for implementing missing tests and observability instrumentation.
---

# Debugging

## Execution Workflow

1. Reproduce the issue with the smallest possible app route or test case.
2. Capture request context, config, and middleware/DI/lifecycle state involved.
3. Isolate the failing layer (routing, parsing, DI, middleware, DB, auth).
4. Apply minimal corrective changes and add a regression test.
5. Re-run affected tests and verify no behavioral regression.

## Implementation Rules

- Keep debugging flags local-only; never expose verbose debug settings in production.
- Prefer deterministic logs and assertions over ad-hoc print debugging.
- Correlate errors with request IDs and route identifiers.
- Fix root causes; avoid masking with broad exception catches.

## Example Pattern

```python
from litestar import Litestar

app = Litestar(
    route_handlers=[...],
    debug=True,  # local-only
)
```

## Validation Checklist

- Confirm issue reproduces before fix and is resolved after fix.
- Confirm both happy-path and failure-path contracts remain correct.
- Confirm no sensitive values are leaked in debug output/logging.

## Cross-Skill Handoffs

- Use `logging` and `metrics` for ongoing observability hardening.
- Use `testing` to codify the bug as a regression test.

## Litestar References

- https://docs.litestar.dev/latest/usage/debugging.html
- https://docs.litestar.dev/latest/usage/testing.html
