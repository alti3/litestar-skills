---
name: litestar-websockets
description: Build Litestar WebSocket endpoints with typed message handling, authentication/authorization, connection lifecycle control, and graceful disconnect/reconnect behavior. Use when implementing bidirectional real-time communication. Do not use for one-way pub/sub patterns that are better handled by channels alone.
---

# WebSockets

## Execution Workflow

1. Define WebSocket routes and message schemas.
2. Authenticate connection establishment and authorize channel/topic access.
3. Implement receive/send loops with explicit timeout, backpressure, and disconnect handling.
4. Emit observability signals for active connections, failures, and throughput.

## Implementation Rules

- Validate incoming messages before domain processing.
- Enforce message size/rate limits and idle timeouts.
- Keep connection state minimal and externally recoverable.
- Handle disconnect paths explicitly to avoid resource leaks.

## Example Pattern

```python
from litestar import websocket
from litestar.connection import WebSocket

@websocket("/ws")
async def ws_handler(socket: WebSocket) -> None:
    await socket.accept()
    message = await socket.receive_text()
    await socket.send_text(f"echo:{message}")
```

## Validation Checklist

- Confirm handshake/auth failure behavior is deterministic.
- Confirm invalid message payloads are rejected safely.
- Confirm reconnection flows and stale-session cleanup work as intended.
- Confirm graceful shutdown closes active sockets predictably.

## Cross-Skill Handoffs

- Use `litestar-channels` for backend event fanout pipelines.
- Use `litestar-authentication`, `litestar-metrics`, and `litestar-logging` for secure observability-rich operation.

## Litestar References

- https://docs.litestar.dev/latest/usage/websockets.html
