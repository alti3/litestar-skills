# Agent Skills Best-Practices Conformance

This repository follows practical, enforceable skill-authoring standards.

## Enforced quality gates

- One skill per folder under `plugins/litestar/skills/<skill-name>/`.
- Required `SKILL.md` frontmatter with exactly two fields in order:
  - `name`
  - `description`
- Skill folder name matches frontmatter `name` and uses lowercase-hyphen format (`[a-z0-9-]+`, max 64 chars).
- Frontmatter `description` includes both trigger guidance (`Use when`) and scope boundaries (`Do not use`).
- `SKILL.md` remains concise (hard limit: 500 lines).
- Every skill includes operational sections:
  - `## Execution Workflow`
  - `## Validation Checklist`
  - `## Litestar References`
- Every skill includes `agents/openai.yaml` with:
  - `display_name`
  - `short_description`
  - `default_prompt`
- Coverage is tracked against Litestar Usage docs in `plugins/litestar/USAGE_COVERAGE.md`.

Run validation:

```bash
scripts/validate_skills_layout.sh
```

## Notes

- `.agents/skills` discovery symlinks are intentionally local-only and ignored by git (`.gitignore`).
- Skill docs are aligned to current Litestar usage docs and should be reviewed when Litestar updates.

## Sources

- OpenAI Codex Skills docs: https://developers.openai.com/codex/agents/skills
- OpenAI skill metadata docs: https://developers.openai.com/codex/agents/openai-yaml
- Agent Skills specification: https://agentskills.io/skills/specification
- Litestar usage docs: https://docs.litestar.dev/latest/usage/index.html
