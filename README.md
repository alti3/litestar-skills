# litestar-skills

Agent skills for building Litestar web APIs.

## Installation / Usage

Install from GitHub with the `skills` CLI.

### Option A: `bunx --bun`

```bash
bunx --bun skills@latest add https://github.com/taher/litestar-skills
```

### Option B: `npx`

```bash
npx skills@latest add https://github.com/taher/litestar-skills
```

Install a specific Litestar skill from this repository:

```bash
bunx --bun skills@latest add https://github.com/taher/litestar-skills --skill routing
# or
npx skills@latest add https://github.com/taher/litestar-skills --skill routing
```

After install, your agent can use skills by name (for example: `routing`, `dto`, `testing`).

Repository layout (Railway-style plugin structure):

- `plugins/litestar/skills/<skill-name>/SKILL.md`

Compatibility discovery layout:

- `.agents/skills/<skill-name> -> plugins/litestar/skills/<skill-name>` (symlinks)

## Skills

- `app-setup`
- `authentication`
- `caching`
- `channels`
- `cli`
- `contrib`
- `custom-types`
- `databases`
- `dataclasses`
- `debugging`
- `dependency-injection`
- `dto`
- `events`
- `exception-handling`
- `file-uploads`
- `htmx`
- `lifecycle-hooks`
- `logging`
- `metrics`
- `middleware`
- `openapi`
- `plugins`
- `requests`
- `responses`
- `routing`
- `static-files`
- `stores`
- `templating`
- `testing`
- `websockets`

## Full page coverage map

- `plugins/litestar/USAGE_COVERAGE.md`

## Validation

- `scripts/validate_skills_layout.sh`

## Source references

- Litestar docs: https://docs.litestar.dev/latest/
- Usage section: https://docs.litestar.dev/latest/usage/
- Structure inspiration: https://github.com/railwayapp/railway-skills
