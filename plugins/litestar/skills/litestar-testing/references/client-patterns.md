# Client Patterns

## Table of Contents

- `TestClient`
- `AsyncTestClient`
- Choosing the right client
- `create_test_client`
- Testing websockets
- Running async code from `TestClient`
- Live-server subprocess helpers

## `TestClient`

Use `TestClient` for synchronous tests where the app can run in its own event loop and thread.

```python
from litestar.status_codes import HTTP_200_OK
from litestar.testing import TestClient

from my_app.main import app


def test_health_check() -> None:
    with TestClient(app=app) as client:
        response = client.get("/health-check")
        assert response.status_code == HTTP_200_OK
        assert response.text == "healthy"
```

## `AsyncTestClient`

Use `AsyncTestClient` when your fixtures, app resources, and test all need to share the same event loop.

```python
from litestar.status_codes import HTTP_200_OK
from litestar.testing import AsyncTestClient

from my_app.main import app


async def test_health_check() -> None:
    async with AsyncTestClient(app=app) as client:
        response = await client.get("/health-check")
        assert response.status_code == HTTP_200_OK
        assert response.text == "healthy"
```

## Choosing the Right Client

The Litestar docs highlight a common failure mode: `TestClient` runs the app in a separate event loop, so async resources created in fixtures can become attached to the wrong loop.

Guidance:

- If the app depends on async clients, pools, or DB sessions provided by async fixtures, use `AsyncTestClient`.
- If the test is fully synchronous and the app owns its own async resources, `TestClient` is usually fine.

## `create_test_client`

Use `create_test_client` to assemble a minimal app inline for isolated contract tests.

```python
from litestar.status_codes import HTTP_200_OK
from litestar.testing import create_test_client

from my_app.main import health_check


def test_health_check() -> None:
    with create_test_client(route_handlers=health_check) as client:
        response = client.get("/health-check")
        assert response.status_code == HTTP_200_OK
        assert response.text == "healthy"
```

Use this when:

- The handler can be tested in isolation.
- You want a disposable app for one test.
- You need to inject fakes via constructor kwargs without importing the full app.

## Testing Websockets

The test client supports `websocket_connect()`.

```python
from typing import Any

from litestar import WebSocket, websocket
from litestar.testing import create_test_client


def test_websocket() -> None:
    @websocket(path="/ws")
    async def websocket_handler(socket: WebSocket[Any, Any, Any]) -> None:
        await socket.accept()
        payload = await socket.receive_json()
        await socket.send_json({"message": payload})
        await socket.close()

    with create_test_client(route_handlers=[websocket_handler]) as client, client.websocket_connect("/ws") as ws:
        ws.send_json({"hello": "world"})
        assert ws.receive_json() == {"message": {"hello": "world"}}
```

Guidance:

- Assert both inbound and outbound frames.
- Cover close behavior when the endpoint manages disconnect explicitly.
- Combine with `litestar-websockets` patterns when listeners or streams are involved.

## Running Async Code from `TestClient`

The synchronous client exposes a blocking portal so synchronous tests can run async functions in the same loop as the app.

```python
from concurrent.futures import Future, wait

import anyio

from litestar.testing import create_test_client


def test_with_portal() -> None:
    async def get_float(value: float) -> float:
        await anyio.sleep(value)
        return value

    with create_test_client(route_handlers=[]) as test_client, test_client.portal() as portal:
        future: Future[float] = portal.start_task_soon(get_float, 0.25)
        assert portal.call(get_float, 0.1) == 0.1
        wait([future])
        assert future.result() == 0.25
```

## Live-Server Subprocess Helpers

The docs note that some transports are a poor fit for the in-process client, especially infinite SSE streams. Use `subprocess_sync_client()` or `subprocess_async_client()` when the client/server transport needs to be more realistic.

Guidance:

- Reach for subprocess helpers when the test hangs or becomes misleading because HTTPX tries to consume the full body.
- Keep these tests narrow because they are slower than in-process tests.
