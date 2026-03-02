---
name: contrib
description: Apply Litestar contrib modules and integrations safely, selecting only the pieces needed for your architecture.
---

# Contrib

Use this skill when adding Litestar contrib components.

## Workflow

1. Identify the exact contrib capability needed.
2. Add only targeted integration modules.
3. Validate compatibility with middleware/auth/DTO stack.
4. Add focused tests around integration boundaries.

## Checklist

- Avoid adding contrib modules without clear ownership.
- Keep integration adapters isolated from domain code.
- Verify failure modes and fallback behavior.

## Litestar References

- https://docs.litestar.dev/latest/usage/contrib.html
