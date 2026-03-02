---
name: websockets
description: Build Litestar WebSocket endpoints with connection lifecycle control, message handling, authentication, and graceful disconnect behavior.
---

# WebSockets

Use this skill for bidirectional real-time endpoints.

## Workflow

1. Define WebSocket route handlers and typed message contracts.
2. Authenticate/authorize connection establishment.
3. Handle receive/send loop with explicit disconnect conditions.
4. Capture metrics/logging for connection counts and failures.

## Checklist

- Validate incoming messages before processing.
- Enforce limits (size, rate, idle timeout).
- Handle reconnect and stale-session behavior.

## Litestar References

- https://docs.litestar.dev/latest/usage/websockets.html
