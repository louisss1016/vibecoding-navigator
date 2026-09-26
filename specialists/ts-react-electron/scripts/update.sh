#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v npx >/dev/null 2>&1 || ! command -v git >/dev/null 2>&1 || ! command -v rsync >/dev/null 2>&1; then
  printf '%s\n' 'npx, git, and rsync are required. Install Node.js/npm and git, then try again.' >&2
  exit 1
fi

printf '%s\n' 'Refreshing the bundled MIT-licensed upstream skill snapshots.'
"$ROOT_DIR/scripts/vendor.sh" --latest
printf '%s\n' 'Updating runtime-only skills recorded by the current skills CLI in this project.'
npx --yes skills update --project --yes
