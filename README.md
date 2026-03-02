# litestar-skills

Agent skills for building Litestar web APIs.

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
