---
name: advanced-alchemy-database-seeding
description: Seed databases and load fixtures with Advanced Alchemy using JSON fixture files, sync or async helpers, repository bulk operations, and framework startup hooks. Use when creating development or test seed data, loading initial reference data, or dumping and restoring fixture-backed tables. Do not use for schema migrations or general runtime CRUD handling.
---

# Database Seeding

## Execution Workflow

1. Store fixtures as JSON objects or arrays of objects in a dedicated fixtures directory.
2. Use `open_fixture()` for sync code or `open_fixture_async()` for async code.
3. Create repository instances inside a real session and load fixture records in batches.
4. Seed parent tables before child tables and make the process idempotent when possible.
5. Wire seeding into startup hooks, dedicated commands, or one-off scripts based on environment needs.

## Implementation Rules

- Keep fixture files versioned alongside the application code.
- Use `add_many()` or `upsert_many()` instead of row-by-row inserts for non-trivial datasets.
- Separate development, test, and production seed data explicitly.
- Do not hide seeding in normal request paths.

## Example Pattern

```python
product_data = await open_fixture_async(fixtures_path, "product")
await product_repo.add_many([Product(**item) for item in product_data])
await db_session.commit()
```

## Validation Checklist

- Confirm fixture files include all required model fields.
- Confirm seeding can run twice without creating bad duplicates or broken foreign keys.
- Confirm batch operations commit only after the dataset passes validation.
- Confirm framework startup seeding is acceptable for the target environment and data size.

## Cross-Skill Handoffs

- Use `advanced-alchemy-cli` for dumping fixture data or pairing seeding with migration workflows.
- Use `advanced-alchemy-litestar`, `advanced-alchemy-fastapi`, or `advanced-alchemy-flask` for framework-specific startup integration.
- Use `advanced-alchemy-repositories` when custom seed logic depends on repository helpers.

## Advanced Alchemy References

- https://advanced-alchemy.litestar.dev/latest/usage/database_seeding.html
- https://docs.advanced-alchemy.litestar.dev/latest/usage/database_seeding.html
