---
name: advanced-alchemy-modeling
description: Design Advanced Alchemy SQLAlchemy models using its base classes, mixins, unique-record helpers, relationship patterns, and declarative base customization. Use when building or refactoring database models, choosing UUID or bigint key strategies, adding slugs or audit columns, or simplifying deduplicated many-to-many workflows. Do not use for repository or HTTP endpoint logic.
---

# Modeling

## Execution Workflow

1. Choose a base class around key shape and audit needs: `BigIntBase`, `BigIntAuditBase`, `UUIDBase`, `UUIDv7Base`, or related variants.
2. Add mixins intentionally: `SlugKey` for URL slugs, audit columns when timestamps are required, and `UniqueMixin` when get-or-create semantics matter.
3. Model relationships with explicit loading strategy such as `selectin` or `joined` instead of relying on defaults.
4. Use `UniqueMixin` to collapse duplicate creation logic for tags, lookup tables, and many-to-many helper models.
5. Customize the declarative base only when the built-in bases do not fit an existing schema or database-specific requirement.

## Implementation Rules

- Pick one primary-key strategy per bounded context and keep it consistent.
- Let mixins own their concern; do not duplicate slug or audit columns by hand.
- Implement both `unique_hash()` and `unique_filter()` whenever `UniqueMixin` is used.
- Keep model classes transport-agnostic and leave request or response shaping to services or framework layers.

## Example Pattern

```python
from advanced_alchemy.base import BigIntAuditBase
from advanced_alchemy.mixins import SlugKey, UniqueMixin


class Tag(BigIntAuditBase, SlugKey, UniqueMixin):
    __tablename__ = "tag"
```

## Validation Checklist

- Confirm the base class matches the database key and migration strategy.
- Confirm relationship loading avoids obvious N+1 behavior in hot paths.
- Confirm `UniqueMixin` criteria match actual uniqueness guarantees.
- Confirm timestamps, slugs, and indexes align with the expected query patterns.

## Cross-Skill Handoffs

- Use `advanced-alchemy-types` for custom column types on model fields.
- Use `advanced-alchemy-repositories` for CRUD and filtering over these models.
- Use `advanced-alchemy-services` when the model requires schema conversion or business rules.

## Advanced Alchemy References

- https://advanced-alchemy.litestar.dev/latest/usage/modeling.html
- https://github.com/litestar-org/advanced-alchemy/blob/main/README.md
