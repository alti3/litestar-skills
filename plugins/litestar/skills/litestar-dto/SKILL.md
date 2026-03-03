---
name: litestar-dto
description: Configure Litestar DTO behavior for read/write shaping, AbstractDTO policies, and custom DTO classes with predictable nested field handling. Use when API payload contracts differ from internal model structures. Do not use when internal models can be exposed safely without transformation.
---

# DTO

## Execution Workflow

1. Start with basic DTO mapping for the target model.
2. Add reusable policy via `AbstractDTO` when multiple handlers share shape rules.
3. Implement custom DTO classes when default behavior cannot express required transformations.
4. Validate nested include/exclude behavior and write/update flows.

## Implementation Rules

- Keep DTO rules explicit; avoid hidden transformation surprises.
- Separate read DTO and write DTO policies when requirements differ.
- Limit nested exposure depth intentionally for performance and data safety.
- Keep DTO logic aligned with OpenAPI contract expectations.

## Example Pattern

```python
from litestar import get
from litestar.dto import DTOConfig, DataclassDTO

class PublicUserDTO(DataclassDTO):
    config = DTOConfig(exclude={"password_hash"})

@get("/users/{user_id:int}", dto=PublicUserDTO)
async def get_user(user_id: int) -> object:
    return ...
```

## Validation Checklist

- Confirm response payloads include and exclude the intended fields.
- Confirm input DTO validation rejects forbidden or malformed fields.
- Confirm update flows preserve invariant and read-only fields.

## Cross-Skill Handoffs

- Use `litestar-dataclasses`, `litestar-plugins`, or `litestar-custom-types` for model ecosystem specifics.
- Use `litestar-openapi` to verify generated schema accuracy after DTO changes.

## Litestar References

- https://docs.litestar.dev/latest/usage/dto/index.html
- https://docs.litestar.dev/latest/usage/dto/0-basic-use.html
- https://docs.litestar.dev/latest/usage/dto/1-abstract-dto.html
- https://docs.litestar.dev/latest/usage/dto/2-creating-custom-dto-classes.html
