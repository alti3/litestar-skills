---
name: requests
description: Handle Litestar request parsing and validation for path, query, header, cookie, and body data with explicit typing and safe defaults.
---

# Requests

Use this skill for inbound HTTP request parsing and validation.

## Workflow

1. Type all handler parameters explicitly.
2. Use parameter helpers for headers/cookies/query aliases and constraints.
3. Validate body payloads via DTO/dataclass/msgspec/pydantic models.
4. Keep transport validation in handlers and business rules in services.

## Checklist

- Avoid untyped `dict` request payloads when schema is known.
- Use narrow types for booleans, enums, UUIDs, and datetimes.
- Handle malformed input with deterministic 4xx responses.

## Litestar References

- https://docs.litestar.dev/latest/usage/requests.html
- https://docs.litestar.dev/latest/usage/routing/parameters.html
