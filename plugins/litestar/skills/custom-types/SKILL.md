---
name: custom-types
description: Add custom type support in Litestar for parsing, validation, and OpenAPI schema compatibility.
---

# Custom Types

Use this skill when API inputs/outputs include non-standard application types.

## Workflow

1. Define custom type behavior for parsing/serialization.
2. Register schema hooks so OpenAPI stays accurate.
3. Add tests for round-trip parse/serialize behavior.
4. Validate error messaging for invalid values.

## Litestar References

- https://docs.litestar.dev/latest/usage/custom-types.html
