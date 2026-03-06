# Failure Patterns

## Table of Contents

- Mocked dependencies with `create_test_client`
- Exception contract assertions
- Testing app-level `404` and `405`
- Testing dependency override precedence
- Testing validation failures
- Testing websocket failure paths

## Mocked Dependencies with `create_test_client`

Prefer injecting a fake service through Litestar dependencies instead of patching handler internals.

```python
from dataclasses import asdict, dataclass

from litestar import get
from litestar.di import Provide
from litestar.status_codes import HTTP_200_OK
from litestar.testing import create_test_client


@dataclass
class Item:
    name: str


class Service:
    def get_one(self) -> Item:
        raise NotImplementedError


@get("/item")
def get_item(service: Service) -> Item:
    return service.get_one()


class FakeService(Service):
    def get_one(self) -> Item:
        return Item(name="Chair")


def test_get_item() -> None:
    with create_test_client(
        route_handlers=get_item,
        dependencies={"service": Provide(lambda: FakeService())},
    ) as client:
        response = client.get("/item")
        assert response.status_code == HTTP_200_OK
        assert response.json() == asdict(Item(name="Chair"))
```

## Exception Contract Assertions

Assert the full failure contract when custom exception handlers are in play.

```python
from litestar import Litestar, Request, Response, get
from litestar.testing import TestClient


class InventoryError(Exception):
    pass


def inventory_error_handler(_: Request, __: InventoryError) -> Response[dict[str, str]]:
    return Response({"code": "inventory_error", "message": "out of stock"}, status_code=409)


@get("/reserve")
def reserve() -> None:
    raise InventoryError()


app = Litestar(route_handlers=[reserve], exception_handlers={InventoryError: inventory_error_handler})


def test_inventory_error_contract() -> None:
    with TestClient(app=app) as client:
        response = client.get("/reserve")
        assert response.status_code == 409
        assert response.json() == {"code": "inventory_error", "message": "out of stock"}
```

Guidance:

- Assert headers too when the exception contract sets them.
- Keep client-visible payload assertions separate from internal logging assertions.

## Testing App-Level `404` and `405`

`404` and `405` customizations belong on the app. Test them through real routing, not through direct handler calls.

```python
from litestar import Litestar, Request, Response, get
from litestar.exceptions import MethodNotAllowedException, NotFoundException
from litestar.testing import TestClient


@get("/items")
def list_items() -> dict[str, list[str]]:
    return {"items": []}


def not_found_handler(request: Request, _: NotFoundException) -> Response[dict[str, str]]:
    return Response({"code": "not_found", "path": request.url.path}, status_code=404)


def method_not_allowed_handler(request: Request, _: MethodNotAllowedException) -> Response[dict[str, str]]:
    return Response({"code": "method_not_allowed", "path": request.url.path}, status_code=405)


app = Litestar(
    route_handlers=[list_items],
    exception_handlers={
        NotFoundException: not_found_handler,
        MethodNotAllowedException: method_not_allowed_handler,
    },
)


def test_not_found_handler() -> None:
    with TestClient(app=app) as client:
        response = client.get("/missing")
        assert response.status_code == 404
        assert response.json() == {"code": "not_found", "path": "/missing"}
```

## Testing Dependency Override Precedence

Test precedence explicitly when app, router, controller, and handler scopes reuse the same key.

```python
from litestar import Controller, Litestar, Router, get
from litestar.di import Provide
from litestar.testing import TestClient


async def provide_app_mode() -> str:
    return "app"


async def provide_router_mode() -> str:
    return "router"


async def provide_handler_mode() -> str:
    return "handler"


class ExampleController(Controller):
    path = "/example"

    @get("/default")
    async def default(self, mode: str) -> dict[str, str]:
        return {"mode": mode}

    @get("/override", dependencies={"mode": Provide(provide_handler_mode)})
    async def override(self, mode: str) -> dict[str, str]:
        return {"mode": mode}


router = Router(
    path="/v1",
    route_handlers=[ExampleController],
    dependencies={"mode": Provide(provide_router_mode)},
)

app = Litestar(route_handlers=[router], dependencies={"mode": Provide(provide_app_mode)})


def test_dependency_override_precedence() -> None:
    with TestClient(app=app) as client:
        assert client.get("/v1/example/default").json() == {"mode": "router"}
        assert client.get("/v1/example/override").json() == {"mode": "handler"}
```

This keeps exception-contract tests and override-precedence tests documented in one place, which helps when failures depend on both wiring and error mapping.

## Testing Validation Failures

When request validation is part of the contract, assert the intended status and payload shape, not just the failure.

```python
from litestar import get
from litestar.testing import create_test_client


@get("/search")
def search(page: int) -> dict[str, int]:
    return {"page": page}


def test_validation_failure() -> None:
    with create_test_client(route_handlers=[search]) as client:
        response = client.get("/search?page=abc")
        assert response.status_code == 400
        assert "detail" in response.json()
```

## Testing Websocket Failure Paths

For websocket tests, cover close behavior and invalid input handling when the endpoint enforces a protocol.

```python
from typing import Any

from litestar import WebSocket, websocket
from litestar.testing import create_test_client


def test_websocket_invalid_payload() -> None:
    @websocket("/ws")
    async def handler(socket: WebSocket[Any, Any, Any]) -> None:
        await socket.accept()
        payload = await socket.receive_json()
        if "message" not in payload:
            await socket.send_json({"code": "invalid_payload"})
            await socket.close()
            return
        await socket.send_json(payload)

    with create_test_client(route_handlers=[handler]) as client, client.websocket_connect("/ws") as ws:
        ws.send_json({"wrong": True})
        assert ws.receive_json() == {"code": "invalid_payload"}
```
