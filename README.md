# litestar-skills

Agent skills for building Litestar web APIs.

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

Install a specific Litestar skill from this repository:

```bash
bunx --bun skills@latest add https://github.com/alti3/litestar-skills --skill routing
# or
npx skills@latest add https://github.com/alti3/litestar-skills --skill routing
```

After install, your agent can use skills by name (for example: `routing`, `dto`, `testing`).

Repository layout (Railway-style plugin structure):

- `plugins/litestar/skills/<skill-name>/SKILL.md`

Compatibility discovery layout:

- `.agents/skills/<skill-name> -> plugins/litestar/skills/<skill-name>` (local symlinks, git-ignored)

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

## Quality and Coverage

- Litestar usage coverage map: `plugins/litestar/USAGE_COVERAGE.md`
- Best-practices checklist: `BEST_PRACTICES_CHECKLIST.md`
- Layout and metadata validation: `scripts/validate_skills_layout.sh`

Run validation locally:

```bash
scripts/validate_skills_layout.sh
```

## Source references

- Litestar docs: https://docs.litestar.dev/latest/
- Litestar usage section: https://docs.litestar.dev/latest/usage/index.html
- OpenAI skills docs: https://developers.openai.com/codex/agents/skills
