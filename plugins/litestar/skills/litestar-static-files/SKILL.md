---
name: litestar-static-files
description: Serve static assets in Litestar with secure directory mounting, cache-control strategy, and production-ready delivery boundaries. Use when exposing JS/CSS/images or other immutable assets. Do not use for handling uploaded file ingestion workflows.
---

# Static Files

## Execution Workflow

1. Mount static directories at explicit URL prefixes.
2. Restrict served directories to safe roots and avoid traversal risks.
3. Apply cache headers suitable for immutable/versioned assets.
4. Align local serving behavior with reverse proxy/CDN production strategy.

## Implementation Rules

- Keep static mounts isolated from writable upload directories.
- Use content hashing/versioning for long-lived cache headers.
- Avoid serving sensitive files from project root paths.
- Keep MIME and compression behavior deterministic.

## Example Pattern

```python
from litestar import Litestar
from litestar.static_files import StaticFilesConfig

app = Litestar(
    route_handlers=[...],
    static_files_config=[StaticFilesConfig(path="/assets", directories=["static"])],
)
```

## Validation Checklist

- Confirm expected assets are served at intended paths only.
- Confirm missing assets return clean `404` responses.
- Confirm cache behavior matches deployment strategy.

## Cross-Skill Handoffs

- Use `responses` for advanced file response behavior.
- Use `file-uploads` for intake/storage validation before publication.

## Litestar References

- https://docs.litestar.dev/latest/usage/static-files.html
