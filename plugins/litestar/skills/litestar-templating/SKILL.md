---
name: litestar-templating
description: Build Litestar template-rendered responses with configured template engines, clean context shaping, reusable partials, and server-rendered page patterns. Use when returning HTML from Litestar handlers. Do not use for pure JSON API endpoints without server-side rendering.
---

# Templating

## Execution Workflow

1. Configure template engine and directory structure.
2. Build handlers that map domain data into explicit view-context objects.
3. Use reusable layouts/partials to reduce duplication.
4. Keep HTML rendering concerns separate from business services.

## Implementation Rules

- Keep template context keys stable and documented.
- Avoid business-rule calculations directly inside templates.
- Validate escaping and safe rendering for user-controlled content.
- Keep template inheritance and partial usage predictable.

## Example Pattern

```python
from litestar import get

@get("/dashboard")
async def dashboard() -> object:
    return ...  # template response with explicit context mapping
```

## Validation Checklist

- Confirm templates render with expected context values.
- Confirm missing context keys fail clearly during development.
- Confirm rendered output is safe and consistent across locales/timezones.

## Cross-Skill Handoffs

- Use `htmx` for partial-update interaction patterns.
- Use `responses` when mixing HTML and non-HTML endpoint behavior.

## Litestar References

- https://docs.litestar.dev/latest/usage/templating.html
