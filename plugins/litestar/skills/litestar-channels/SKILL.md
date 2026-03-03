---
name: litestar-channels
description: Implement Litestar channels for publish-subscribe event delivery, subscriber lifecycle, backend selection, and real-time fanout flows. Use when building server-side event streams or async pub/sub messaging. Do not use for simple request-response APIs that do not require asynchronous broadcast semantics.
---

# Channels

## Execution Workflow

1. Define channel names and versioned event payload contracts.
2. Select a channel backend and configure delivery durability expectations.
3. Publish events from domain boundaries, not directly from transport adapters.
4. Register subscribers with explicit lifecycle and error-handling behavior.
5. Monitor backpressure, queue growth, and retry policies.

## Implementation Rules

- Keep payloads compact and schema-stable.
- Prefer domain events over transport-coupled message formats.
- Make subscriber handlers idempotent when retries are possible.
- Enforce bounded work per message to avoid event loop starvation.

## Example Pattern

```python
# Pseudocode pattern: inject a channel publisher and emit typed events.
async def publish_user_created(channels: object, user_id: str) -> None:
    await channels.publish("users.created", {"user_id": user_id})
```

## Validation Checklist

- Confirm subscribers receive events in expected topic scope.
- Confirm failure/retry behavior does not duplicate side effects.
- Confirm disconnections and shutdown flush/cleanup are predictable.
- Confirm event ordering assumptions are documented and tested.

## Cross-Skill Handoffs

- Use `litestar-websockets` for client-facing bidirectional sessions.
- Use `litestar-metrics` and `litestar-logging` for observability on fanout throughput and errors.

## Litestar References

- https://docs.litestar.dev/latest/usage/channels.html
