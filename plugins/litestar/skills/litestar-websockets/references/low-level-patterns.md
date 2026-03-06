# Low-Level Patterns

## Table of Contents

- Manual websocket handler
- Dependency injection
- Transport modes
- Custom websocket classes
- Combining streaming and receiving manually

## Manual Websocket Handler

Use the low-level `@websocket` decorator when you need explicit control over the socket.

```python
from typing import Any

from litestar import Litestar, WebSocket, websocket


@websocket("/ws")
async def ws_handler(socket: WebSocket[Any, Any, Any]) -> None:
    await socket.accept()
    message = await socket.receive_text()
    await socket.send_text(f"echo:{message}")
    await socket.close()


app = Litestar(route_handlers=[ws_handler])
```

Use this when:

- You need custom receive loops.
- You need multiple concurrent tasks.
- You need low-level socket methods directly.

## Dependency Injection

Dependency injection works in websocket handlers like other Litestar handlers.

```python
from litestar import Litestar, WebSocket, websocket
from litestar.di import Provide


async def provide_prefix() -> str:
    return "echo"


@websocket("/ws", dependencies={"prefix": Provide(provide_prefix)})
async def ws_handler(socket: WebSocket, prefix: str) -> None:
    await socket.accept()
    message = await socket.receive_text()
    await socket.send_text(f"{prefix}:{message}")


app = Litestar(route_handlers=[ws_handler])
```

Guidance:

- Inject services or configuration rather than building them inside the connection loop.
- Keep DI stable and runtime-importable like other Litestar handlers.

## Transport Modes

The docs emphasize that websocket transport modes are protocol-level choices. `text` and `binary` do not directly map to Python `str` and `bytes` types.

Guidance:

- Use `text` for most messages, including JSON.
- Use `binary` when the wire format or client expectations require it.
- Configure send and receive modes independently when needed.

```python
from litestar import Litestar, websocket_listener


@websocket_listener("/", send_mode="binary", receive_mode="text")
async def handler(data: str) -> str:
    return data


app = Litestar(route_handlers=[handler])
```

## Custom Websocket Classes

A custom `websocket_class` can be supplied when connection behavior should be extended consistently.

```python
from litestar import Litestar, WebSocket, websocket


class AppWebSocket(WebSocket):
    async def send_event(self, event: dict[str, str]) -> None:
        await self.send_json(event)


@websocket("/events", websocket_class=AppWebSocket)
async def event_socket(socket: AppWebSocket) -> None:
    await socket.accept()
    await socket.send_event({"type": "ready"})


app = Litestar(route_handlers=[event_socket])
```

Use this sparingly; most endpoints do not need a custom subclass.

## Combining Streaming and Receiving Manually

When a connection must both push a stream and handle inbound messages, coordinate both tasks explicitly.

```python
from collections.abc import AsyncGenerator
from typing import Any

import anyio

from litestar import Litestar, WebSocket, websocket
from litestar.exceptions import WebSocketDisconnect
from litestar.handlers import send_websocket_stream


@websocket("/")
async def handler(socket: WebSocket[Any, Any, Any]) -> None:
    await socket.accept()
    should_stop = anyio.Event()

    async def handle_stream() -> AsyncGenerator[str, None]:
        while not should_stop.is_set():
            await anyio.sleep(0.5)
            yield "ping"

    async def handle_send() -> None:
        await send_websocket_stream(socket, handle_stream(), listen_for_disconnect=False)

    async def handle_receive() -> None:
        async for event in socket.iter_json():
            await socket.send_json(event)

    try:
        async with anyio.create_task_group() as tg:
            tg.start_soon(handle_send)
            tg.start_soon(handle_receive)
    except WebSocketDisconnect:
        should_stop.set()


app = Litestar(route_handlers=[handler])
```

Guidance:

- Coordinate disconnect and cancellation explicitly.
- Disable disconnect listening in `send_websocket_stream()` when another task is already reading from the socket.
- Do not let one task continue after the socket is closed.
