#!/usr/bin/env bash
set -euo pipefail

root="plugins/litestar/skills"
errors=0

if [[ ! -d "$root" ]]; then
  echo "ERROR: missing $root"
  exit 1
fi

for skill_dir in "$root"/*; do
  [[ -d "$skill_dir" ]] || continue
  skill_name="$(basename "$skill_dir")"
  skill_file="$skill_dir/SKILL.md"

  if [[ ! -f "$skill_file" ]]; then
    echo "ERROR: $skill_name missing SKILL.md"
    errors=$((errors + 1))
    continue
  fi

  declared_name="$(sed -n 's/^name: //p' "$skill_file" | head -n1)"
  declared_desc="$(sed -n 's/^description: //p' "$skill_file" | head -n1)"

  if [[ -z "$declared_name" || -z "$declared_desc" ]]; then
    echo "ERROR: $skill_name missing frontmatter name/description"
    errors=$((errors + 1))
  fi

  if [[ "$declared_name" != "$skill_name" ]]; then
    echo "ERROR: $skill_name frontmatter name mismatch: $declared_name"
    errors=$((errors + 1))
  fi

  if [[ ! "$skill_name" =~ ^[a-z0-9-]+$ ]]; then
    echo "ERROR: $skill_name uses invalid chars"
    errors=$((errors + 1))
  fi

  if [[ ! -f "$skill_dir/agents/openai.yaml" ]]; then
    echo "ERROR: $skill_name missing agents/openai.yaml"
    errors=$((errors + 1))
  fi

done

for skill_link in .agents/skills/*; do
  [[ -L "$skill_link" ]] || continue
  target="$(readlink "$skill_link")"
  if [[ ! -d ".agents/skills/$(basename "$skill_link")" ]]; then
    :
  fi
  if [[ ! -e ".agents/skills/$(basename "$skill_link")/SKILL.md" ]]; then
    echo "ERROR: broken discovery link $skill_link -> $target"
    errors=$((errors + 1))
  fi
done

if [[ "$errors" -gt 0 ]]; then
  echo "Validation failed with $errors error(s)"
  exit 1
fi

echo "Skill layout validation passed"
