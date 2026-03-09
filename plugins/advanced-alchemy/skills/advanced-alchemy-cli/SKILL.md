---
name: advanced-alchemy-cli
description: Use Advanced Alchemy's CLI for migrations, revision management, inspection, branching, fixture dumping, and framework CLI integration. Use when setting up or operating Alembic migrations through `alchemy`, `litestar database`, or `flask database`, or when embedding the commands into Click or Typer applications. Do not use for runtime repository or service logic.
---

# CLI

## Execution Workflow

1. Install the CLI extra when standalone `alchemy` commands are needed.
2. Point every command at an explicit dotted config path via `--config`.
3. Use `init`, `make-migrations`, `upgrade`, and `downgrade` as the core lifecycle.
4. Use inspection commands such as `check`, `heads`, `history`, and `show-current-revision` in CI or troubleshooting.
5. Use branch-management and utility commands only when the migration graph actually requires them.

## Implementation Rules

- Prefer explicit config paths over implicit discovery in automation.
- Keep destructive commands such as `drop-all` behind clear environment guards.
- Use `check` in CI for drift detection before deployments.
- Embed the CLI into Click or Typer only when the project already has an application CLI worth extending.

## Example Pattern

```bash
alchemy init --config path.to.alchemy_config.config
alchemy make-migrations --config path.to.alchemy_config.config -m "add users"
alchemy upgrade --config path.to.alchemy_config.config
```

## Validation Checklist

- Confirm the dotted config path imports cleanly in the target environment.
- Confirm migration commands operate on the intended database bind.
- Confirm CI uses `check` or revision-inspection commands before deploys.
- Confirm destructive or offline SQL modes are only used intentionally.

## Cross-Skill Handoffs

- Use `advanced-alchemy-getting-started` if the config object itself is not wired yet.
- Use `advanced-alchemy-litestar` or `advanced-alchemy-flask` when framework CLIs expose the same migration commands.
- Use `advanced-alchemy-database-seeding` when fixture dumping or loading is part of the operational workflow.

## Advanced Alchemy References

- https://advanced-alchemy.litestar.dev/latest/usage/cli.html
- https://docs.advanced-alchemy.litestar.dev/latest/usage/cli.html
