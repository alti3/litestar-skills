---
name: databases
description: Build Litestar database integrations including SQLAlchemy and Piccolo setup, plugin usage, serialization, and repository patterns.
---

# Databases

Use this skill for persistence architecture in Litestar.

## Workflow

1. Choose SQLAlchemy or Piccolo based on team/runtime constraints.
2. Configure plugin/session lifecycle at app startup.
3. Define repository/service boundaries around ORM models.
4. Handle transaction scope and serialization deterministically.

## SQLAlchemy Coverage

- Base integration and session setup.
- Plugin configuration.
- Serialization patterns.
- Repository abstractions.

## Piccolo Coverage

- Plugin integration and session/engine patterns.

## Litestar References

- https://docs.litestar.dev/latest/usage/databases/index.html
- https://docs.litestar.dev/latest/usage/databases/sqlalchemy/index.html
- https://docs.litestar.dev/latest/usage/databases/sqlalchemy/plugins.html
- https://docs.litestar.dev/latest/usage/databases/sqlalchemy/serialization.html
- https://docs.litestar.dev/latest/usage/databases/sqlalchemy/repository.html
- https://docs.litestar.dev/latest/usage/databases/piccolo/index.html
