# Plugin And Subscriber Patterns

## Table of Contents

- Configuring `ChannelsPlugin`
- Publishing data
- Starting subscriptions
- Managing subscriptions directly
- Subscriber event processing
- History replay
- Direct websocket integration

## Configuring `ChannelsPlugin`

The plugin is the central channels component and also becomes available as a dependency under the `channels` key.

```python
from litestar import Litestar
from litestar.channels import ChannelsPlugin
from litestar.channels.backends.memory import MemoryChannelsBackend


channels_plugin = ChannelsPlugin(
    backend=MemoryChannelsBackend(),
    channels=["users", "notifications"],
)

app = Litestar(plugins=[channels_plugin])
```

Guidance:

- Define channels explicitly unless arbitrary channels are a deliberate feature.
- Keep one plugin instance per app configuration.

## Publishing Data

Publish through the injected plugin instead of importing a global singleton.

```python
from litestar import post
from litestar.channels import ChannelsPlugin
from litestar.status_codes import HTTP_202_ACCEPTED


@post("/users/{user_id:int}/notify", status_code=HTTP_202_ACCEPTED)
async def notify_user(user_id: int, channels: ChannelsPlugin) -> None:
    channels.publish({"user_id": user_id, "event": "updated"}, "users")
```

Guidance:

- Publish from domain boundaries such as services or command handlers.
- Keep payloads versionable and portable across consumers.
- Use `wait_published()` instead when the caller must wait for the backend write.

## Starting Subscriptions

Use `start_subscription()` to create and clean up a subscriber with a managed context.

```python
from litestar import Litestar, WebSocket, websocket
from litestar.channels import ChannelsPlugin
from litestar.channels.backends.memory import MemoryChannelsBackend


@websocket("/ws")
async def handler(socket: WebSocket, channels: ChannelsPlugin) -> None:
    await socket.accept()

    async with channels.start_subscription(["notifications"]) as subscriber:
        async for message in subscriber.iter_events():
            await socket.send_text(message)


app = Litestar(
    route_handlers=[handler],
    plugins=[ChannelsPlugin(backend=MemoryChannelsBackend(), channels=["notifications"])],
)
```

Use this when event consumption is the primary job of the connection.

## Managing Subscriptions Directly

Subscribers can subscribe and unsubscribe from channels over their lifetime.

```python
from litestar.channels import ChannelsPlugin


async def resubscribe(channels: ChannelsPlugin) -> None:
    subscriber = await channels.subscribe(["foo"])
    await channels.subscribe(subscriber, ["foo", "bar"])
    await channels.unsubscribe(subscriber, ["foo"])
    await channels.unsubscribe(subscriber)
```

Guidance:

- Keep dynamic subscription changes explicit.
- Pair them with authorization and validation rules outside the transport edge.

## Subscriber Event Processing

A `Subscriber` exposes `iter_events()` and `run_in_background()`.

```python
from litestar import Litestar, WebSocket, websocket
from litestar.channels import ChannelsPlugin
from litestar.channels.backends.memory import MemoryChannelsBackend


@websocket("/ws")
async def handler(socket: WebSocket, channels: ChannelsPlugin) -> None:
    await socket.accept()

    async with (
        channels.start_subscription(["notifications"]) as subscriber,
        subscriber.run_in_background(socket.send_text),
    ):
        while True:
            response = await socket.receive_text()
            await socket.send_text(response)


app = Litestar(
    route_handlers=[handler],
    plugins=[ChannelsPlugin(backend=MemoryChannelsBackend(), channels=["notifications"])],
)
```

Guidance:

- Prefer `run_in_background()` when the websocket must also receive data.
- Use `iter_events()` when event consumption is the only concern.

## History Replay

Some backends support per-channel history. The plugin can push it into a subscriber's stream.

```python
from litestar import Litestar, WebSocket, websocket
from litestar.channels import ChannelsPlugin
from litestar.channels.backends.memory import MemoryChannelsBackend


@websocket("/ws")
async def handler(socket: WebSocket, channels: ChannelsPlugin) -> None:
    await socket.accept()

    async with channels.start_subscription(["notifications"]) as subscriber:
        await channels.put_subscriber_history(subscriber, ["notifications"], limit=10)


app = Litestar(
    route_handlers=[handler],
    plugins=[ChannelsPlugin(backend=MemoryChannelsBackend(history=20), channels=["notifications"])],
)
```

Guidance:

- Keep history replay bounded.
- History is replayed sequentially to preserve ordering and avoid overfilling the backlog.

## Direct Websocket Integration

Channels and websockets pair naturally, but disconnect behavior still matters.

Guidance:

- If the websocket also receives data, prefer background subscriber processing over a raw `iter_events()` loop.
- If disconnects can leave a coroutine waiting indefinitely, restructure the flow so a background task or explicit socket receive path can observe the disconnect.
