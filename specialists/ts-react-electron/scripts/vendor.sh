#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST_FILE="$ROOT_DIR/manifest/skills.json"
LATEST=0

usage() {
  printf '%s\n' "Usage: $0 [--latest]"
  printf '%s\n' 'Refreshes the MIT-licensed upstream copies in vendor/skills.'
  printf '%s\n' 'Without --latest, the manifest upstream_ref values are used.'
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
elif [[ "${1:-}" == "--latest" ]]; then
  LATEST=1
elif [[ $# -ne 0 ]]; then
  usage >&2
  exit 2
fi

if ! command -v git >/dev/null 2>&1 || ! command -v rsync >/dev/null 2>&1; then
  printf '%s\n' 'git and rsync are required to refresh bundled skills.' >&2
  exit 1
fi

FETCH_DIR="$(mktemp -d /tmp/fullstack-desktop-skills-vendor.XXXXXX)"
REFS_FILE="$FETCH_DIR/refs.tsv"
cleanup() {
  rm -rf "$FETCH_DIR"
}
trap cleanup EXIT

printf '%s\n' 'Refreshing vendored upstream skills.'
while IFS=$'\t' read -r skill_name vendor_path repository upstream_path requested_ref; do
  [[ -z "$skill_name" ]] && continue
  repo_dir="$FETCH_DIR/repo-$skill_name"
  stage_dir="$FETCH_DIR/stage-$skill_name"
  target_dir="$ROOT_DIR/$vendor_path"

  printf '%s\n' "Fetching $skill_name from $repository"
  git clone --depth 1 "$repository" "$repo_dir" >/dev/null

  if (( LATEST )); then
    actual_ref="$(git -C "$repo_dir" rev-parse HEAD)"
  else
    actual_ref="$requested_ref"
    if [[ -z "$actual_ref" ]]; then
      actual_ref="$(git -C "$repo_dir" rev-parse HEAD)"
    elif ! git -C "$repo_dir" cat-file -e "$actual_ref^{commit}" >/dev/null 2>&1; then
      git -C "$repo_dir" fetch --depth 1 origin "$actual_ref" >/dev/null
    fi
  fi

  if [[ "$vendor_path" = /* || "$vendor_path" == *..* || "$upstream_path" = /* || "$upstream_path" == *..* ]]; then
    printf '%s\n' "Unsafe manifest path for $skill_name" >&2
    exit 1
  fi

  mkdir -p "$stage_dir"
  git -C "$repo_dir" archive --format=tar "$actual_ref" "$upstream_path" \
    | tar -x -C "$stage_dir" --strip-components="$(awk -F/ '{print NF}' <<< "$upstream_path")"
  if [[ ! -f "$stage_dir/SKILL.md" ]]; then
    printf '%s\n' "Vendored source did not contain SKILL.md: $skill_name" >&2
    exit 1
  fi

  mkdir -p "$target_dir"
  rsync -a --delete "$stage_dir/" "$target_dir/"
  printf '%s\t%s\n' "$skill_name" "$actual_ref" >> "$REFS_FILE"
  printf '%s\n' "Bundled $skill_name at $actual_ref"
done < <(
  node - "$MANIFEST_FILE" <<'NODE'
const fs = require('node:fs');
const manifest = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
for (const skill of manifest.skills ?? []) {
  if (skill.distribution !== 'vendored') continue;
  for (const key of ['name', 'vendor_path', 'repository', 'upstream_path']) {
    if (!skill[key]) throw new Error(`${skill.name ?? 'unknown'} is missing ${key}`);
  }
  process.stdout.write([
    skill.name,
    skill.vendor_path,
    skill.repository,
    skill.upstream_path,
    skill.upstream_ref ?? '',
  ].join('\t') + '\n');
}
NODE
)

if (( LATEST )); then
  node - "$MANIFEST_FILE" "$REFS_FILE" <<'NODE'
const fs = require('node:fs');
const [manifestFile, refsFile] = process.argv.slice(2);
const refs = new Map(
  fs.readFileSync(refsFile, 'utf8').trim().split('\n').filter(Boolean)
    .map((line) => line.split('\t')),
);
const manifest = JSON.parse(fs.readFileSync(manifestFile, 'utf8'));
for (const skill of manifest.skills ?? []) {
  const ref = refs.get(skill.name);
  if (ref) skill.upstream_ref = ref;
}
fs.writeFileSync(manifestFile, `${JSON.stringify(manifest, null, 2)}\n`);
NODE
  printf '%s\n' 'Updated manifest upstream_ref values to the fetched commits.'
fi

printf '%s\n' 'Vendored skill refresh complete.'
