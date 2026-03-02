---
name: channels
description: Implement Litestar channels for server-side publish-subscribe streaming and real-time message fanout patterns.
---

# Channels

Use this skill when the app needs pub/sub style message broadcasting.

## Workflow

1. Define channel namespace and event payload schema.
2. Publish messages from application services/events.
3. Attach consumers/subscribers to channel topics.
4. Set delivery, backpressure, and lifecycle behavior intentionally.

## Checklist

- Define stable event names and payload contracts.
- Keep message payloads compact and versionable.
- Avoid direct coupling of channel transport to domain logic.

## Litestar References

- https://docs.litestar.dev/latest/usage/channels.html
