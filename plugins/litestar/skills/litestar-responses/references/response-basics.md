# Response Basics

## Table of Contents

- Plain typed returns
- `Response[T]` for explicit control
- Status code patterns
- Layered `response_class`
- Custom response classes
- Background tasks

## Plain Typed Returns

Use plain typed return values when Litestar defaults already match the contract.

```python
from pydantic import BaseModel

from litestar import get


class Resource(BaseModel):
    id: int
    name: str


@get("/resources/{resource_id:int}")
def retrieve_resource(resource_id: int) -> Resource:
    return Resource(id=resource_id, name="example")
```

Guidance:

- This is the default JSON path and should be the starting point for most HTTP handlers.
- Keep the return annotation precise so OpenAPI stays accurate.

## `Response[T]` for Explicit Control

Use `Response[T]` when the payload is ordinary but headers, cookies, status code, or background tasks are dynamic.

```python
from litestar import Response, get
from litestar.status_codes import HTTP_201_CREATED


@get("/created")
def created() -> Response[dict[str, str]]:
    return Response({"result": "ok"}, status_code=HTTP_201_CREATED)
```

Guidance:

- Always provide the generic argument, even when the body is `None`.
- Use this instead of a custom response class when the customization is local.

## Status Code Patterns

Litestar defaults to `200 OK` for most handlers. The docs also note:

- `delete` defaults to `204 No Content`
- multi-method `route()` handlers default to `200`
- if the response should be empty, the annotation should be `None`

```python
from litestar import delete
from litestar.status_codes import HTTP_204_NO_CONTENT


@delete("/resources/{resource_id:int}", status_code=HTTP_204_NO_CONTENT)
def delete_resource(resource_id: int) -> None:
    return None
```

Guidance:

- Do not annotate a `204` handler with a body type.
- Set the status code explicitly when the default of the decorator does not match your contract.

## Layered `response_class`

`response_class` participates in Litestar's layered architecture. The closest layer to the handler wins.

```python
from litestar import Controller, Litestar, Router, get
from litestar.response import Response


class EnvelopeResponse(Response[dict[str, object]]):
    pass


class ResourceController(Controller):
    path = "/resources"
    response_class = EnvelopeResponse

    @get("/")
    def list_resources(self) -> dict[str, object]:
        return {"items": []}


router = Router(path="/v1", route_handlers=[ResourceController])
app = Litestar(route_handlers=[router])
```

Guidance:

- Use layered `response_class` only when many handlers truly share the same serialization behavior.
- Override at a lower layer only when behavior must differ locally.

## Custom Response Classes

Use a custom response class when you need type encoders or shared behavior that built-in responses do not provide.

```python
from litestar import Litestar, Response, get
from litestar.datastructures import MultiDict


class MultiDictResponse(Response[MultiDict]):
    type_encoders = {MultiDict: lambda data: data.dict()}


@get("/")
async def index() -> MultiDict:
    return MultiDict([("foo", "bar"), ("foo", "baz")])


app = Litestar(route_handlers=[index], response_class=MultiDictResponse)
```

Use this when:

- A domain type needs custom serialization.
- Many handlers need the same encoding behavior.
- OpenAPI and runtime serialization should remain aligned.

## Background Tasks

All Litestar responses and response containers accept a `background` kwarg.

```python
import logging

from litestar import Litestar, Response, get
from litestar.background_tasks import BackgroundTask

logger = logging.getLogger(__name__)


async def audit_call(endpoint: str, message: str) -> None:
    logger.info("%s: %s", endpoint, message)


@get("/hello", sync_to_thread=False)
def hello(name: str) -> Response[dict[str, str]]:
    return Response(
        {"hello": name},
        background=BackgroundTask(audit_call, "hello", message=f"served {name}"),
    )


app = Litestar(route_handlers=[hello])
```

Guidance:

- Background tasks run after the response finishes sending.
- Keep them short and failure-tolerant.
- Do not use them for critical workflows that need transactional guarantees.
