#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST_FILE="$ROOT_DIR/manifest/skills.json"
ROUTER_FILE="$ROOT_DIR/skills/fullstack-desktop/SKILL.md"
CASES_FILE="$ROOT_DIR/tests/routing-cases.json"
OFFLINE=0

if [[ "${1:-}" == "--offline" ]]; then
  OFFLINE=1
elif [[ $# -ne 0 ]]; then
  printf '%s\n' "Usage: $0 [--offline]" >&2
  exit 2
fi

if ! command -v node >/dev/null 2>&1 || ! command -v npx >/dev/null 2>&1; then
  printf '%s\n' 'node and npx are required for verification.' >&2
  exit 1
fi

printf '%s\n' 'Checking manifest, router, and routing cases.'
node - "$MANIFEST_FILE" "$ROUTER_FILE" "$CASES_FILE" <<'NODE'
const fs = require('node:fs');
const path = require('node:path');

const [manifestFile, routerFile, casesFile] = process.argv.slice(2);
const expected = [
  'fullstack-desktop',
  'electron-best-practices',
  'typescript-pro',
  'sql-pro',
  'playwright-expert',
  'vercel-react-best-practices',
  'frontend-design',
];
const expectedDistribution = {
  'fullstack-desktop': 'local',
  'electron-best-practices': 'runtime',
  'typescript-pro': 'vendored',
  'sql-pro': 'vendored',
  'playwright-expert': 'vendored',
  'vercel-react-best-practices': 'vendored',
  'frontend-design': 'runtime',
};
const expectedBundledSupport = {
  'typescript-pro': ['references'],
  'sql-pro': ['references'],
  'playwright-expert': ['references'],
  'vercel-react-best-practices': ['AGENTS.md', 'metadata.json', 'rules'],
};
const manifest = JSON.parse(fs.readFileSync(manifestFile, 'utf8'));
if (!Array.isArray(manifest.skills) || manifest.skills.length !== expected.length) {
  throw new Error('manifest must contain exactly seven skills');
}
const names = manifest.skills.map((skill) => skill.name);
if (JSON.stringify(names) !== JSON.stringify(expected)) {
  throw new Error(`manifest order/names mismatch: ${names.join(', ')}`);
}
for (const skill of manifest.skills) {
  for (const key of ['source', 'path', 'source_type', 'distribution', 'license', 'role', 'install_method']) {
    if (!skill[key]) throw new Error(`${skill.name} is missing manifest field ${key}`);
  }
  if (skill.distribution !== expectedDistribution[skill.name]) {
    throw new Error(`${skill.name} has distribution ${skill.distribution}; expected ${expectedDistribution[skill.name]}`);
  }
  if (skill.distribution === 'vendored' && !skill.vendor_path) {
    throw new Error(`${skill.name} is missing vendor_path`);
  }
}

const router = fs.readFileSync(routerFile, 'utf8');
if (!router.startsWith('---\n') || !/^name:\s*fullstack-desktop$/m.test(router)) {
  throw new Error('router frontmatter is missing the required name');
}
if (!/^description:\s*.+$/m.test(router)) throw new Error('router description is missing');
const lineCount = router.trimEnd().split('\n').length;
if (lineCount < 50 || lineCount > 100) throw new Error(`router has ${lineCount} lines; expected 50-100`);
for (const name of expected.slice(1)) {
  if (!router.includes(`\`${name}\``)) throw new Error(`router does not mention ${name}`);
}

const cases = JSON.parse(fs.readFileSync(casesFile, 'utf8'));
const routingDoc = fs.readFileSync(path.resolve(path.dirname(routerFile), '../../docs/routing.md'), 'utf8');
const conflictDoc = fs.readFileSync(path.resolve(path.dirname(routerFile), '../../docs/conflicts.md'), 'utf8');
if (cases.length !== 6) throw new Error('expected six routing cases');
for (const testCase of cases) {
  if (!routingDoc.includes(`| ${testCase.id} |`)) throw new Error(`routing docs missing case ${testCase.id}`);
  for (const name of testCase.expected) {
    if (!router.includes(`\`${name}\``)) throw new Error(`case ${testCase.id} expects undocumented route ${name}`);
  }
}
for (const required of ['Primary owner', 'electron-best-practices', 'typescript-pro', 'sql-pro', 'playwright-expert', 'Precedence rules']) {
  if (!conflictDoc.includes(required)) throw new Error(`conflict review missing ${required}`);
}
for (const skill of manifest.skills.filter((entry) => entry.distribution === 'vendored')) {
  const vendorDir = path.resolve(path.dirname(manifestFile), '..', skill.vendor_path);
  const skillFile = path.join(vendorDir, 'SKILL.md');
  if (!fs.existsSync(skillFile)) throw new Error(`missing bundled copy ${skillFile}`);
  const actualName = fs.readFileSync(skillFile, 'utf8').match(/^name:\s*([^\n]+)$/m)?.[1]?.trim();
  if (actualName !== skill.name) throw new Error(`bundled ${skill.name} has actual name ${actualName}`);
  for (const relative of expectedBundledSupport[skill.name] ?? []) {
    if (!fs.existsSync(path.join(vendorDir, relative))) throw new Error(`bundled ${skill.name} missing ${relative}`);
  }
}
console.log(`PASS: manifest (${expected.length} skills), router (${lineCount} lines), routing cases (${cases.length})`);
NODE

if (( OFFLINE )); then
  printf '%s\n' 'NETWORK_TEST: SKIPPED (--offline)'
  printf '%s\n' 'PASS: local verification complete'
  exit 0
fi

VERIFY_DIR="$(mktemp -d /tmp/fullstack-desktop-skills-verify.XXXXXX)"
cleanup() {
  rm -rf "$VERIFY_DIR"
}
trap cleanup EXIT

printf '%s\n' "Testing upstream discovery and isolated installation in $VERIFY_DIR"

while IFS=$'\t' read -r skill_name skill_source source_type; do
  [[ -z "$skill_name" ]] && continue
  list_log="$VERIFY_DIR/list-$skill_name.log"
  if ! (cd "$VERIFY_DIR" && npx --yes skills add "$skill_source" --list </dev/null >"$list_log" 2>&1); then
    printf '%s\n' "FAIL: skills --list could not fetch $skill_name" >&2
    tail -n 40 "$list_log" >&2 || true
    exit 1
  fi
  if ! grep -Fq "$skill_name" "$list_log"; then
    printf '%s\n' "FAIL: skills --list did not expose $skill_name" >&2
    tail -n 40 "$list_log" >&2 || true
    exit 1
  fi
  printf '%s\n' "PASS: --list exposed $skill_name"
done < <(
  node - "$MANIFEST_FILE" <<'NODE'
const fs = require('node:fs');
const manifest = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
for (const skill of manifest.skills) {
  if (skill.distribution === 'runtime') process.stdout.write(`${skill.name}\t${skill.source}\t${skill.source_type}\n`);
}
NODE
)

while IFS=$'\t' read -r skill_name skill_source distribution; do
  [[ -z "$skill_name" ]] && continue
  install_log="$VERIFY_DIR/install-$skill_name.log"
  if ! (cd "$VERIFY_DIR" && npx --yes skills add "$skill_source" --skill "$skill_name" --agent codex --copy --yes </dev/null >"$install_log" 2>&1); then
    printf '%s\n' "FAIL: isolated install failed for $skill_name" >&2
    tail -n 60 "$install_log" >&2 || true
    exit 1
  fi
  printf '%s\n' "PASS: installed $skill_name for codex"
done < <(
  node - "$MANIFEST_FILE" "$ROOT_DIR" <<'NODE'
const fs = require('node:fs');
const manifest = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
for (const skill of manifest.skills) {
  let source = skill.source;
  if (skill.distribution === 'local') source = `${process.argv[3]}/${skill.source}`;
  if (skill.distribution === 'vendored') source = `${process.argv[3]}/${skill.vendor_path}`;
  process.stdout.write(`${skill.name}\t${source}\t${skill.distribution}\n`);
}
NODE
)

printf '%s\n' 'Checking installed discovery and support files.'
node - "$VERIFY_DIR/.agents/skills" <<'NODE'
const fs = require('node:fs');
const path = require('node:path');

const skillsRoot = process.argv[2];
const expected = {
  'fullstack-desktop': [],
  'electron-best-practices': ['references', 'scripts', 'assets'],
  'typescript-pro': ['references'],
  'sql-pro': ['references'],
  'playwright-expert': ['references'],
  'vercel-react-best-practices': ['AGENTS.md', 'rules'],
  'frontend-design': [],
};
for (const [name, support] of Object.entries(expected)) {
  const skillDir = path.join(skillsRoot, name);
  const skillFile = path.join(skillDir, 'SKILL.md');
  if (!fs.existsSync(skillFile)) throw new Error(`missing ${skillFile}`);
  const content = fs.readFileSync(skillFile, 'utf8');
  const actualName = content.match(/^name:\s*([^\n]+)$/m)?.[1]?.trim();
  if (actualName !== name) throw new Error(`${name} has actual name ${actualName}`);
  if (!/^description:\s*.+$/m.test(content)) throw new Error(`${name} has no description`);
  for (const relative of support) {
    if (!fs.existsSync(path.join(skillDir, relative))) throw new Error(`${name} missing support path ${relative}`);
  }
}
console.log('PASS: seven installed skills and their observed support paths');
NODE

(cd "$VERIFY_DIR" && npx --yes skills list --json > skills-list.json)
node - "$VERIFY_DIR/skills-list.json" <<'NODE'
const fs = require('node:fs');
const expected = new Set([
  'fullstack-desktop',
  'electron-best-practices',
  'typescript-pro',
  'sql-pro',
  'playwright-expert',
  'vercel-react-best-practices',
  'frontend-design',
]);
const installed = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
const names = new Set(installed.map((skill) => skill.name));
for (const name of expected) if (!names.has(name)) throw new Error(`skills list missing ${name}`);
if (installed.some((skill) => !skill.agents.includes('Codex'))) throw new Error('skills list did not report Codex discovery');
console.log(`PASS: skills list discovered ${expected.size} required skills for Codex`);
NODE

printf '%s\n' 'PASS: network discovery and isolated installation verification complete'
