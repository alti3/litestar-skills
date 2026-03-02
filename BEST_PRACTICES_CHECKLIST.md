# Agent Skills Best-Practices Conformance

This repository follows documented skill-structure best practices:

- One skill per folder with required `SKILL.md` frontmatter (`name`, `description`).
- Lowercase hyphen skill names matching folder names.
- Optional `agents/openai.yaml` metadata included for all skills.
- Progressive, focused skill bodies (small, task-specific, cross-linking official docs).
- Standard discoverable `.agents/skills` layout provided via symlinks.
- Coverage matrix for documentation completeness: `plugins/litestar/USAGE_COVERAGE.md`.
- Automated layout/frontmatter validation script: `scripts/validate_skills_layout.sh`.

## Sources

- OpenAI Codex Skills docs: https://developers.openai.com/codex/agents/skills
- OpenAI skill metadata docs: https://developers.openai.com/codex/agents/openai-yaml
- Agent Skills specification: https://agentskills.io/skills/specification
- Railway skills repository structure: https://github.com/railwayapp/railway-skills
