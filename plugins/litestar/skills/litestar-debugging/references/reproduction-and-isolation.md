# Reproduction And Isolation

## Table of Contents

- Minimal repro apps
- Local debug mode
- Focused logging
- Regression tests as bug proofs

## Minimal Repro Apps

Build a tiny Litestar app that contains only the failing behavior.

```python
from litestar import Litestar, get


@get("/boom")
def boom() -> dict[str, str]:
    raise RuntimeError("repro")


app = Litestar(route_handlers=[boom])
```

Guidance:

- Strip away unrelated middleware, routes, and services first.
- Add pieces back only when the bug disappears without them.

## Local Debug Mode

Use `debug=True` only in local or isolated repro scenarios.

```python
from litestar import Litestar


app = Litestar(route_handlers=[...], debug=True)
```

Guidance:

- Use it to surface detailed tracebacks locally.
- Do not leave it enabled in production-facing code.

## Focused Logging

Add focused logs at the boundary that may be failing.

```python
from litestar import Request, get


@get("/inspect")
def inspect(request: Request) -> dict[str, str]:
    request.logger.info("debugging request boundary", extra={"path": request.url.path})
    return {"path": request.url.path}
```

Guidance:

- Log expected and actual values at one boundary at a time.
- Remove temporary fields once the root cause is found.

## Regression Tests As Bug Proofs

Convert the repro into a test once the defect is understood.

```python
from litestar.testing import create_test_client


def test_regression() -> None:
    with create_test_client(route_handlers=[...]) as client:
        response = client.get("/boom")
        assert response.status_code == 500
```

Guidance:

- The regression test is the proof that the issue existed and is fixed.
- Keep the test focused on the exact broken contract.
