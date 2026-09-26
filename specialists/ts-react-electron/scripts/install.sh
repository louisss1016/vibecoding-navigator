#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST_FILE="$ROOT_DIR/manifest/skills.json"

usage() {
  printf '%s\n' "Usage: $0 {claude-code|codex|opencode}"
  printf '%s\n' 'Installs this pack project-scoped into the current working directory.'
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

if [[ $# -ne 1 ]]; then
  usage >&2
  exit 2
fi

AGENT_ID="$1"
case "$AGENT_ID" in
  claude-code|codex|opencode) ;;
  *)
    printf '%s\n' "Unsupported agent: $AGENT_ID" >&2
    usage >&2
    exit 2
    ;;
esac

if ! command -v node >/dev/null 2>&1 || ! command -v npx >/dev/null 2>&1; then
  printf '%s\n' 'node and npx are required. Install Node.js/npm and try again.' >&2
  exit 1
fi

if [[ ! -f "$MANIFEST_FILE" ]]; then
  printf '%s\n' "Manifest not found: $MANIFEST_FILE" >&2
  exit 1
fi

printf '%s\n' "Installing fullstack-desktop-skills for $AGENT_ID in: $(pwd)"

while IFS=$'\t' read -r skill_name skill_source source_type distribution; do
  [[ -z "$skill_name" ]] && continue
  printf '%s\n' "Installing $skill_name ($distribution)"
  npx --yes skills add "$skill_source" \
    --skill "$skill_name" \
    --agent "$AGENT_ID" \
    --copy \
    --yes </dev/null
done < <(
  node - "$MANIFEST_FILE" "$ROOT_DIR" <<'NODE'
const fs = require('node:fs');

const manifestFile = process.argv[2];
const rootDir = process.argv[3];
const manifest = JSON.parse(fs.readFileSync(manifestFile, 'utf8'));
if (!Array.isArray(manifest.skills) || manifest.skills.length !== 7) {
  throw new Error('manifest must contain exactly seven skills');
}
for (const skill of manifest.skills) {
  if (!skill.name || !skill.source || !skill.source_type || !skill.distribution) {
    throw new Error('each manifest skill needs name, source, source_type, and distribution');
  }
  let installSource = skill.source;
  if (skill.distribution === 'local') installSource = `${rootDir}/${skill.source}`;
  if (skill.distribution === 'vendored') {
    if (!skill.vendor_path) throw new Error(`${skill.name} is missing vendor_path`);
    installSource = `${rootDir}/${skill.vendor_path}`;
  }
  process.stdout.write(`${skill.name}\t${installSource}\t${skill.source_type}\t${skill.distribution}\n`);
}
NODE
)

printf '%s\n' "Installed seven skills for $AGENT_ID."
