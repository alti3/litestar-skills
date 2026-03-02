---
name: testing
description: Test Litestar applications with sync/async test clients, fixtures, dependency overrides, mocked dependencies, and deterministic assertions for success/failure contracts. Use when adding or fixing Litestar test coverage. Do not use as a substitute for production observability or runtime debugging strategy.
---

# Testing

## Execution Workflow

1. Create app fixtures with predictable configuration and dependencies.
2. Use Litestar test clients for endpoint-level contract assertions.
3. Override/mimic dependencies to isolate behavior under test.
4. Cover happy path, validation failures, auth boundaries, and exception mapping.

## Implementation Rules

- Keep tests deterministic (time, randomness, external I/O).
- Prefer table-driven tests for parameterized route behavior.
- Assert full contracts: status, payload, headers, side effects.
- Use async client patterns when endpoint internals are async-heavy.

## Example Pattern

```python
from litestar.testing import TestClient


def test_health(app) -> None:
    with TestClient(app=app) as client:
        response = client.get("/health")
        assert response.status_code == 200
```

## Validation Checklist

- Confirm startup/shutdown behavior is exercised where relevant.
- Confirm dependency overrides do not leak across tests.
- Confirm expected failures produce stable payloads/status codes.
- Confirm mocked external boundaries are asserted for call behavior.

## Cross-Skill Handoffs

- Use `dependency-injection` to design override-friendly services.
- Use `exception-handling`, `authentication`, and `responses` for domain-specific assertion depth.

## Litestar References

- https://docs.litestar.dev/latest/usage/testing.html
- https://docs.litestar.dev/latest/usage/testing.html#using-mocked-dependencies
- https://docs.litestar.dev/latest/usage/testing.html#using-the-asynchronous-test-client
