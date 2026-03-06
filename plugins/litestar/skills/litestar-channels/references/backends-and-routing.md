# Backends And Routing

## Table of Contents

- Backend selection
- Backpressure strategies
- Generated websocket route handlers
- Generated handlers with history
- Arbitrary channels

## Backend Selection

The docs list these backends:

- `MemoryChannelsBackend`: best for tests, local development, and single-process deployment
- `RedisChannelsPubSubBackend`: lower latency, recommended when history is not needed
- `RedisChannelsStreamBackend`: supports history with slightly higher publish latency
- `AsyncPgChannelsBackend`
- `PsycoPgChannelsBackend`

Guidance:

- Start with memory for local work and tests.
- Move to Redis or Postgres backends when inter-process fanout or durability matters.
- Pick the stream-capable backend when history replay is part of the product.

## Backpressure Strategies

Each subscriber has its own backlog. The docs describe two bounded strategies when `max_backlog` is set:

- `backoff`: drop new messages while the backlog is full
- `dropleft`: evict the oldest message when a new one arrives

```python
from litestar.channels import ChannelsPlugin
from litestar.channels.backends.memory import MemoryChannelsBackend


channels = ChannelsPlugin(
    backend=MemoryChannelsBackend(),
    max_backlog=1000,
    backlog_strategy="backoff",
)
```

```python
from litestar.channels import ChannelsPlugin
from litestar.channels.backends.memory import MemoryChannelsBackend


channels = ChannelsPlugin(
    backend=MemoryChannelsBackend(),
    max_backlog=1000,
    backlog_strategy="dropleft",
)
```

Guidance:

- Use `backoff` when fresh events can be dropped under pressure.
- Use `dropleft` when the latest events matter more than older backlog.
- Always document the delivery tradeoff when messages may be dropped.

## Generated Websocket Route Handlers

The plugin can generate websocket route handlers automatically.

```python
from litestar import Litestar
from litestar.channels import ChannelsPlugin
from litestar.channels.backends.memory import MemoryChannelsBackend


channels_plugin = ChannelsPlugin(
    backend=MemoryChannelsBackend(),
    channels=["foo", "bar"],
    create_ws_route_handlers=True,
)

app = Litestar(plugins=[channels_plugin])
```

Use this when:

- Each channel should have a straightforward websocket endpoint.
- Custom per-channel websocket logic is minimal.

## Generated Handlers with History

Generated websocket handlers can replay history on connect.

```python
from litestar import Litestar
from litestar.channels import ChannelsPlugin
from litestar.channels.backends.memory import MemoryChannelsBackend


channels_plugin = ChannelsPlugin(
    backend=MemoryChannelsBackend(history=10),
    channels=["foo", "bar"],
    create_ws_route_handlers=True,
    ws_handler_send_history=10,
)

app = Litestar(plugins=[channels_plugin])
```

Guidance:

- Align `history` storage on the backend with `ws_handler_send_history` on the plugin.
- Keep replay volume low enough that new connections do not start overloaded.

## Arbitrary Channels

If `arbitrary_channels_allowed=True`, the plugin can create channels on the fly and will generate a single websocket handler with a path parameter for the channel.

Guidance:

- Only enable arbitrary channels when naming, authorization, and lifecycle rules are already defined.
- This is powerful but easier to misuse than explicit channel lists.
