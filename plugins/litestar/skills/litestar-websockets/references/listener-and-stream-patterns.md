# Listener And Stream Patterns

## Table of Contents

- `@websocket_listener`
- `WebsocketListener` classes
- Listener dependency injection
- `@websocket_stream`
- Disconnect listening and data discard
- Combining listeners and streams

## `@websocket_listener`

Use `@websocket_listener` for typed event-driven websocket handling.

```python
from litestar import Litestar, websocket_listener


@websocket_listener("/")
async def handler(data: str) -> str:
    return data


app = Litestar(route_handlers=[handler])
```

Guidance:

- The incoming `data` parameter is already processed according to the handler configuration.
- The return value is serialized and sent automatically.
- This is usually the cleanest option when the connection follows request/response-like message handling.

## `WebsocketListener` Classes

Use `WebsocketListener` when you want class-based organization and lifecycle hooks for websocket listeners.

```python
from litestar import Litestar
from litestar.handlers import WebsocketListener


class EchoListener(WebsocketListener[str, str]):
    path = "/echo"

    async def on_receive(self, data: str) -> str:
        return data


app = Litestar(route_handlers=[EchoListener()])
```

Guidance:

- Keep listener classes small and focused.
- Use class-based listeners when the endpoint needs related lifecycle methods or shared configuration.

## Listener Dependency Injection

Listeners can receive dependencies just like HTTP handlers.

```python
from litestar import Litestar, websocket_listener
from litestar.di import Provide


async def provide_greeting() -> str:
    return "hello"


@websocket_listener("/", dependencies={"greeting": Provide(provide_greeting)})
async def handler(data: str, greeting: str) -> str:
    return f"{greeting}:{data}"


app = Litestar(route_handlers=[handler])
```

Important:

- Listener dependencies are evaluated per connection, not per received message.

## `@websocket_stream`

Use `@websocket_stream` for proactive push from an async generator.

```python
import asyncio
import time
from collections.abc import AsyncGenerator

from litestar import Litestar, websocket_stream


@websocket_stream("/")
async def ping() -> AsyncGenerator[float, None]:
    while True:
        yield time.time()
        await asyncio.sleep(0.5)


app = Litestar(route_handlers=[ping])
```

Guidance:

- This is appropriate for server-driven updates.
- If the client should also send messages, use `send_websocket_stream()` with another handler style instead.

## Disconnect Listening and Data Discard

By default, `websocket_stream` listens for disconnects in the background. The docs warn that this can discard incoming data if the application is also trying to read from the socket.

Guidance:

- Leave disconnect listening enabled when the socket is stream-only.
- Set `allow_data_discard=True` only when incoming data can be ignored safely.
- If you need to receive data while streaming, switch to `send_websocket_stream()` and manage disconnect flow yourself.

## Combining Listeners and Streams

A listener can be combined with a background stream using `send_websocket_stream()` and a connection lifespan context.

```python
from collections.abc import AsyncGenerator
from contextlib import asynccontextmanager
from typing import Any

import anyio

from litestar import Litestar, WebSocket, websocket_listener
from litestar.exceptions import WebSocketDisconnect
from litestar.handlers import send_websocket_stream


@asynccontextmanager
async def listener_lifespan(socket: WebSocket) -> AsyncGenerator[None, Any]:
    is_closed = anyio.Event()

    async def handle_stream() -> AsyncGenerator[str, None]:
        while not is_closed.is_set():
            await anyio.sleep(0.1)
            yield "ping"

    async def handle_send() -> None:
        await send_websocket_stream(socket, handle_stream(), listen_for_disconnect=False)

    async with anyio.create_task_group() as tg:
        tg.start_soon(handle_send)
        try:
            yield
        except WebSocketDisconnect:
            is_closed.set()
            raise


@websocket_listener("/", connection_lifespan=listener_lifespan)
async def listener(data: str) -> str:
    return data


app = Litestar(route_handlers=[listener])
```

Use this when:

- The connection needs reactive inbound handling and proactive outbound updates.
- You want to keep business logic in a listener-style callback.
