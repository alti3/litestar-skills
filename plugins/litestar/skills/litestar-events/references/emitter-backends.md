# Emitter Backends

## Table of Contents

- Default backend
- Concurrency and listener failures
- Configuring a custom backend
- Custom backend requirements
- When to replace `SimpleEventEmitter`

## Default Backend

Litestar's app config exposes `event_emitter_backend`, and the `2.x` config reference shows it defaults to `SimpleEventEmitter`.

```python
from litestar import Litestar
from litestar.events import SimpleEventEmitter


app = Litestar(
    route_handlers=[...],
    listeners=[...],
    event_emitter_backend=SimpleEventEmitter,
)
```

The usage docs describe `SimpleEventEmitter` as an in-memory async queue that works well when you do not need retry, persistence, or scheduling behavior.

## Concurrency And Listener Failures

The events API reference notes that listeners are executed concurrently in a task group. Litestar wraps listener functions so one listener's exception does not cancel unfinished sibling listeners.

Practical guidance:

- Assume listeners for the same event may run concurrently.
- Do not depend on implicit ordering between sibling listeners.
- Keep each listener failure-tolerant and observable.
- Test failure paths when one listener raising should not prevent another side effect.

## Configuring A Custom Backend

A custom backend is supplied through the app's `event_emitter_backend` config.

```python
from litestar import Litestar


app = Litestar(
    route_handlers=[...],
    listeners=[...],
    event_emitter_backend=MyEmitterBackend,
)
```

Guidance:

- Keep the backend choice centralized at app construction.
- Document what delivery semantics the backend provides, because Litestar itself does not infer retry or persistence guarantees.

## Custom Backend Requirements

The usage and API docs together establish these requirements:

- Inherit from `BaseEventEmitterBackend`.
- Accept `listeners: Sequence[EventListener]` in the initializer.
- Implement `emit(event_id: str, *args: Any, **kwargs: Any) -> None`.
- Implement `__aenter__` and `__aexit__`, because the backend is an async context manager.

```python
from collections.abc import Sequence
from typing import Any, Self

from litestar.events import BaseEventEmitterBackend, EventListener


class MyEmitterBackend(BaseEventEmitterBackend):
    def __init__(self, listeners: Sequence[EventListener]) -> None:
        super().__init__(listeners)

    async def __aenter__(self) -> Self:
        return self

    async def __aexit__(self, exc_type: object, exc: object, tb: object) -> None:
        return None

    def emit(self, event_id: str, *args: Any, **kwargs: Any) -> None:
        ...
```

Design expectations:

- If the backend hands work to Redis, Postgres, or a queue, make failure and retry semantics explicit.
- Keep emitted payloads serializable if the backend crosses process boundaries.
- Treat backend resource setup and teardown as app-lifecycle concerns.

## When To Replace `SimpleEventEmitter`

The usage docs recommend replacing the default backend when the system needs more complex behavior such as:

- retry mechanisms
- persistence
- scheduling or cron-like execution
- external event infrastructure

Use cases that justify a custom backend:

- Events must survive process restarts.
- Multiple app instances must observe the same events.
- Delivery must integrate with an external broker or task queue.

When those requirements are absent, prefer the default in-memory backend for simplicity.
