#!/usr/bin/env bash
set -euo pipefail

root="plugins/litestar/skills"
max_lines=500
errors=0

if [[ ! -d "$root" ]]; then
  echo "ERROR: missing $root"
  exit 1
fi

for skill_dir in "$root"/*; do
  [[ -d "$skill_dir" ]] || continue
  skill_name="$(basename "$skill_dir")"
  skill_file="$skill_dir/SKILL.md"
  openai_file="$skill_dir/agents/openai.yaml"

  if [[ ! "$skill_name" =~ ^[a-z0-9-]+$ ]]; then
    echo "ERROR: $skill_name uses invalid chars"
    errors=$((errors + 1))
  fi

  if (( ${#skill_name} > 64 )); then
    echo "ERROR: $skill_name exceeds 64 characters"
    errors=$((errors + 1))
  fi

  if [[ ! -f "$skill_file" ]]; then
    echo "ERROR: $skill_name missing SKILL.md"
    errors=$((errors + 1))
    continue
  fi

  line_count="$(wc -l < "$skill_file")"
  if (( line_count > max_lines )); then
    echo "ERROR: $skill_name SKILL.md exceeds $max_lines lines ($line_count)"
    errors=$((errors + 1))
  fi

  if [[ "$(head -n1 "$skill_file")" != "---" ]]; then
    echo "ERROR: $skill_name SKILL.md must start with frontmatter delimiter (---)"
    errors=$((errors + 1))
    continue
  fi

  closing_line="$(awk 'NR > 1 && $0 == "---" {print NR; exit}' "$skill_file")"
  if [[ -z "$closing_line" ]]; then
    echo "ERROR: $skill_name missing closing frontmatter delimiter"
    errors=$((errors + 1))
    continue
  fi

  frontmatter="$(sed -n "2,$((closing_line - 1))p" "$skill_file")"
  body="$(sed -n "$((closing_line + 1)),\$p" "$skill_file")"

  if [[ -z "$frontmatter" ]]; then
    echo "ERROR: $skill_name has empty frontmatter"
    errors=$((errors + 1))
    continue
  fi

  mapfile -t fm_keys < <(printf '%s\n' "$frontmatter" | sed -n 's/^\([a-zA-Z0-9_-]\+\):.*/\1/p')

  if (( ${#fm_keys[@]} != 2 )); then
    echo "ERROR: $skill_name frontmatter must include exactly two keys: name, description"
    errors=$((errors + 1))
  fi

  if [[ "${fm_keys[*]}" != "name description" ]]; then
    echo "ERROR: $skill_name frontmatter keys must be in order: name, description"
    errors=$((errors + 1))
  fi

  declared_name="$(printf '%s\n' "$frontmatter" | sed -n 's/^name: //p' | head -n1)"
  declared_desc="$(printf '%s\n' "$frontmatter" | sed -n 's/^description: //p' | head -n1)"

  if [[ -z "$declared_name" || -z "$declared_desc" ]]; then
    echo "ERROR: $skill_name missing frontmatter name/description values"
    errors=$((errors + 1))
  fi

  if [[ "$declared_name" != "$skill_name" ]]; then
    echo "ERROR: $skill_name frontmatter name mismatch: $declared_name"
    errors=$((errors + 1))
  fi

  if [[ "$declared_desc" != *"Use when"* ]]; then
    echo "ERROR: $skill_name description must include 'Use when' trigger guidance"
    errors=$((errors + 1))
  fi

  if [[ "$declared_desc" != *"Do not use"* ]]; then
    echo "ERROR: $skill_name description must include 'Do not use' scope boundaries"
    errors=$((errors + 1))
  fi

  if ! printf '%s\n' "$body" | grep -q '^## Execution Workflow'; then
    echo "ERROR: $skill_name missing '## Execution Workflow' section"
    errors=$((errors + 1))
  fi

  if ! printf '%s\n' "$body" | grep -q '^## Validation Checklist'; then
    echo "ERROR: $skill_name missing '## Validation Checklist' section"
    errors=$((errors + 1))
  fi

  if ! printf '%s\n' "$body" | grep -q '^## Litestar References'; then
    echo "ERROR: $skill_name missing '## Litestar References' section"
    errors=$((errors + 1))
  fi

  if [[ ! -f "$openai_file" ]]; then
    echo "ERROR: $skill_name missing agents/openai.yaml"
    errors=$((errors + 1))
  else
    if ! grep -q '^display_name:' "$openai_file"; then
      echo "ERROR: $skill_name agents/openai.yaml missing display_name"
      errors=$((errors + 1))
    fi
    if ! grep -q '^short_description:' "$openai_file"; then
      echo "ERROR: $skill_name agents/openai.yaml missing short_description"
      errors=$((errors + 1))
    fi
    if ! grep -q '^default_prompt:' "$openai_file"; then
      echo "ERROR: $skill_name agents/openai.yaml missing default_prompt"
      errors=$((errors + 1))
    fi
  fi
done

if [[ -d ".agents/skills" ]]; then
  for skill_link in .agents/skills/*; do
    [[ -L "$skill_link" ]] || continue
    if [[ ! -e "$skill_link/SKILL.md" ]]; then
      echo "ERROR: broken discovery link $skill_link"
      errors=$((errors + 1))
    fi
  done
fi

if [[ "$errors" -gt 0 ]]; then
  echo "Validation failed with $errors error(s)"
  exit 1
fi

echo "Skill layout validation passed"
