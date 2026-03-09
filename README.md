# litestar-skills

Agent skills for building Litestar and Advanced Alchemy web APIs.

## Installation / Usage

Install from GitHub with the `skills` CLI.

### Option A: `bunx --bun`

```bash
bunx --bun skills@latest add https://github.com/alti3/litestar-skills
```

### Option B: `npx`

```bash
npx skills@latest add https://github.com/alti3/litestar-skills
```

Install a specific skill from this repository:

```bash
bunx --bun skills@latest add https://github.com/alti3/litestar-skills --skill litestar-routing
# or
npx skills@latest add https://github.com/alti3/litestar-skills --skill litestar-routing
```

Example Advanced Alchemy install:

```bash
bunx --bun skills@latest add https://github.com/alti3/litestar-skills --skill advanced-alchemy-litestar
# or
npx skills@latest add https://github.com/alti3/litestar-skills --skill advanced-alchemy-litestar
```

After install, your agent can use skills by name (for example: `litestar-routing`, `litestar-dto`, `advanced-alchemy-litestar`, `advanced-alchemy-services`).

Repository layout (Railway-style plugin structure):

- `plugins/litestar/skills/<skill-name>/SKILL.md`
- `plugins/advanced-alchemy/skills/<skill-name>/SKILL.md`

Compatibility discovery layout:

- `.agents/skills/<skill-name> -> plugins/<plugin>/skills/<skill-name>` (local symlinks, git-ignored)

## Skills

### Litestar plugin

- `litestar-app-setup`
- `litestar-authentication`
- `litestar-caching`
- `litestar-channels`
- `litestar-cli`
- `litestar-contrib`
- `litestar-custom-types`
- `litestar-databases`
- `litestar-dataclasses`
- `litestar-debugging`
- `litestar-dependency-injection`
- `litestar-dto`
- `litestar-events`
- `litestar-exception-handling`
- `litestar-file-uploads`
- `litestar-htmx`
- `litestar-lifecycle-hooks`
- `litestar-logging`
- `litestar-metrics`
- `litestar-middleware`
- `litestar-openapi`
- `litestar-plugins`
- `litestar-requests`
- `litestar-responses`
- `litestar-security`
- `litestar-routing`
- `litestar-static-files`
- `litestar-stores`
- `litestar-templating`
- `litestar-testing`
- `litestar-websockets`

### Advanced Alchemy plugin

- `advanced-alchemy-caching`
- `advanced-alchemy-cli`
- `advanced-alchemy-database-seeding`
- `advanced-alchemy-fastapi`
- `advanced-alchemy-flask`
- `advanced-alchemy-getting-started`
- `advanced-alchemy-litestar`
- `advanced-alchemy-modeling`
- `advanced-alchemy-repositories`
- `advanced-alchemy-routing`
- `advanced-alchemy-services`
- `advanced-alchemy-types`

## Quality and Coverage

- Litestar usage coverage map: `plugins/litestar/USAGE_COVERAGE.md`
- Advanced Alchemy usage coverage map: `plugins/advanced-alchemy/USAGE_COVERAGE.md`
- Plugin indexes: `plugins/litestar/README.md`, `plugins/advanced-alchemy/README.md`
- Best-practices checklist: `BEST_PRACTICES_CHECKLIST.md`
- Layout and metadata validation: `scripts/validate_skills_layout.sh`

Run validation locally:

```bash
scripts/validate_skills_layout.sh
```

## Source references

- Litestar docs: https://docs.litestar.dev/latest/
- Litestar usage section: https://docs.litestar.dev/latest/usage/index.html
- Advanced Alchemy docs: https://advanced-alchemy.litestar.dev/latest/
- Advanced Alchemy README: https://github.com/litestar-org/advanced-alchemy/blob/main/README.md
- OpenAI skills docs: https://developers.openai.com/codex/agents/skills
