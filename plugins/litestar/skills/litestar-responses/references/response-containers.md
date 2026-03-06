# Response Containers

## Table of Contents

- Response headers
- Dynamic headers
- Response cookies
- Dynamic cookies
- Redirect responses
- File responses
- Streaming responses
- Server-sent events
- Template responses
- Returning ASGI applications

## Response Headers

`response_headers` can be declared at app, router, controller, or handler scope.

```python
from litestar import Controller, Litestar, MediaType, Router, get
from litestar.datastructures import ResponseHeader


class MyController(Controller):
    path = "/controller-path"
    response_headers = [
        ResponseHeader(name="controller-level-header", value="controller header", description="controller header")
    ]

    @get(
        path="/handler-path",
        response_headers=[ResponseHeader(name="handler-header", value="handler header", description="handler header")],
        media_type=MediaType.TEXT,
        sync_to_thread=False,
    )
    def handler(self) -> str:
        return "hello world"


router = Router(
    path="/router-path",
    route_handlers=[MyController],
    response_headers=[ResponseHeader(name="router-header", value="router header", description="router header")],
)

app = Litestar(
    route_handlers=[router],
    response_headers=[ResponseHeader(name="app-header", value="app header", description="app header")],
)
```

Guidance:

- Static headers compose across layers.
- Use a plain mapping when no OpenAPI metadata is needed.
- Use `ResponseHeader` when descriptions or documentation-only behavior matter.

## Dynamic Headers

For dynamic header values, document the header on the route and set the actual value in the returned response or an `after_request` hook.

```python
from random import randint

from litestar import Response, get
from litestar.datastructures import ResponseHeader


@get(
    "/resources",
    response_headers=[
        ResponseHeader(name="Random-Header", description="runtime-generated value", documentation_only=True)
    ],
    sync_to_thread=False,
)
def retrieve_resource() -> Response[dict[str, int]]:
    return Response({"id": 1}, headers={"Random-Header": str(randint(1, 100))})
```

## Response Cookies

`response_cookies` are layered like headers.

```python
from litestar import Controller, Litestar, MediaType, Router, get
from litestar.datastructures import Cookie


class MyController(Controller):
    path = "/controller-path"
    response_cookies = [Cookie(key="controller-cookie", value="controller", description="controller cookie")]

    @get(
        path="/",
        response_cookies=[Cookie(key="handler-cookie", value="handler", description="handler cookie")],
        media_type=MediaType.TEXT,
        sync_to_thread=False,
    )
    def handler(self) -> str:
        return "hello world"


router = Router(path="/router-path", route_handlers=[MyController])
app = Litestar(route_handlers=[router])
```

Guidance:

- Use `Cookie` when documenting attributes matters.
- Keep cookie scope, security flags, and lifetime policy consistent across layers.

## Dynamic Cookies

Like headers, document the cookie and set the runtime value in the response.

```python
from random import randint

from litestar import Response, get
from litestar.datastructures import Cookie


@get(
    "/session",
    response_cookies=[Cookie(key="Random-Cookie", description="runtime-generated cookie", documentation_only=True)],
    sync_to_thread=False,
)
def issue_cookie() -> Response[dict[str, str]]:
    return Response(
        {"status": "issued"},
        cookies=[Cookie(key="Random-Cookie", value=str(randint(1, 100)))],
    )
```

## Redirect Responses

Use redirect responses for explicit redirect semantics rather than crafting raw responses manually.

```python
from litestar import get
from litestar.response import Redirect


@get("/docs")
def docs_redirect() -> Redirect:
    return Redirect(path="/schema")
```

Guidance:

- Keep redirect status and target explicit.
- Test both status code and `Location` header.

## File Responses

Use `File` for safe file delivery. It supports Litestar's file-system registry and fsspec-compatible backends.

```python
from litestar import get
from litestar.response import File


@get("/reports/latest")
async def latest_report() -> File:
    return File(path="reports/latest.pdf", filename="report.pdf")
```

Guidance:

- Prefer `File` over hand-built streaming for file downloads.
- Large files will stream automatically based on `chunk_size`.
- Use named file systems or fsspec backends for S3 or other remote storage.

## Streaming Responses

Use `Stream` for progressive HTTP response bodies.

```python
from asyncio import sleep
from collections.abc import AsyncGenerator
from datetime import datetime

from litestar import Litestar, get
from litestar.response import Stream
from litestar.serialization import encode_json


async def current_time_stream() -> AsyncGenerator[bytes, None]:
    while True:
        await sleep(0.01)
        yield encode_json({"current_time": datetime.now().isoformat()})


@get("/time")
def stream_time() -> Stream:
    return Stream(current_time_stream())


app = Litestar(route_handlers=[stream_time])
```

Guidance:

- Generators can be sync or async, direct or callable.
- Make stream generators disconnect-safe and cancellation-aware.
- Infinite streams may need live-server tests rather than in-process clients.

## Server-Sent Events

Use `ServerSentEvent` for browser-friendly unidirectional event streams.

```python
from asyncio import sleep
from collections.abc import AsyncGenerator

from litestar import Litestar, get
from litestar.response import ServerSentEvent, ServerSentEventMessage
from litestar.types import SSEData


async def event_generator() -> AsyncGenerator[SSEData, None]:
    count = 0
    while count < 3:
        await sleep(0.01)
        count += 1
        yield {"data": count, "event": "counter"}
        yield ServerSentEventMessage(event="commented", retry=1000, comment="still alive")


@get("/count", sync_to_thread=False)
def sse_handler() -> ServerSentEvent:
    return ServerSentEvent(event_generator())


app = Litestar(route_handlers=[sse_handler])
```

Guidance:

- Use SSE when the client only needs server-to-client updates over HTTP.
- Prefer subprocess test clients for infinite SSE generators.

## Template Responses

Template responses belong to Litestar's templating system.

```python
from litestar import Request, get
from litestar.response import Template


@get("/info")
def info(request: Request) -> Template:
    return Template(template_name="info.html", context={"user": request.user})
```

Use `litestar-templating` when template-engine setup or advanced rendering behavior is the main task.

## Returning ASGI Applications

Route handlers can return any ASGI application, including third-party response objects.

```python
from starlette.responses import JSONResponse

from litestar import get
from litestar.types import ASGIApp


@get("/")
def handler() -> ASGIApp:
    return JSONResponse(content={"hello": "world"})  # type: ignore
```

Guidance:

- Use this when wrapping a third-party ASGI response or custom low-level app.
- Keep typing expectations in mind; some third-party responses may require `# type: ignore`.
