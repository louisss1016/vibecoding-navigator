# Fullstack Desktop Skills

A curated full-stack desktop development skill pack for TypeScript + React + Electron applications.

This project contains one small router skill, four bundled upstream specialist skills, and two official runtime-only specialists whose current terms do not allow us to copy them into a redistributable pack. The bundled directories are real files under `vendor/skills/`; GitHub links are retained for provenance and refreshes, not as a substitute for the files.

## Included

- `fullstack-desktop` — thin router for multi-domain desktop tasks
- `electron-best-practices` — Electron processes, IPC, security, packaging, and Electron testing
- `typescript-pro` — advanced TypeScript and type-safe refactoring
- `sql-pro` — SQL/SQLite schema, queries, indexes, and optimization
- `playwright-expert` — Playwright E2E, UI, visual, and flaky-test work
- `vercel-react-best-practices` — Vercel React performance guidance
- `frontend-design` — distinctive, production-grade frontend design

The actual bundled copies are:

```text
vendor/skills/typescript-pro/
vendor/skills/sql-pro/
vendor/skills/playwright-expert/
vendor/skills/vercel-react-best-practices/
```

`electron-best-practices` and `frontend-design` are fetched only during installation because their current upstream terms do not provide permissive redistribution rights. See [`docs/distribution.md`](docs/distribution.md) for the decision and [`THIRD-PARTY-NOTICES.md`](THIRD-PARTY-NOTICES.md) for attribution.

## Install

Requires a current Node.js/npm installation and network access for the upstream skills. Run the installer from the application project where the skills should be discovered:

```bash
git clone https://github.com/your-org/fullstack-desktop-skills.git
cd fullstack-desktop-skills
./scripts/install.sh claude-code
```

The supported agent identifiers are:

```bash
./scripts/install.sh claude-code
./scripts/install.sh codex
./scripts/install.sh opencode
```

Installation is project-scoped and uses `npx skills add`; it does not write to global agent directories. The CLI may create its canonical `.agents/skills/` directory and an agent-specific discovery path such as `.claude/skills/`.

If the skill-pack checkout is separate from the app, run its installer by path while your shell is in the app project:

```bash
/path/to/fullstack-desktop-skills/scripts/install.sh codex
```

## Use

Describe the work normally, or mention the router explicitly:

```text
Use fullstack-desktop to add a settings page to this Electron app. Store the settings in SQLite and add E2E tests.
```

The router identifies the relevant specialist skill names. Agent Skills are discovered through each agent's normal description-based mechanism; the router is not a portable function-call API. See [`docs/routing.md`](docs/routing.md).

## Update

Refresh the bundled MIT-licensed copies and update runtime-only skills in the current project:

```bash
./scripts/update.sh
```

To refresh only the bundled copies at their recorded commits, use `./scripts/vendor.sh`. To pull the latest default-branch snapshots and update their manifest commit pins, use `./scripts/vendor.sh --latest`. Re-run `install.sh <agent>` after refreshing the pack so the application project receives the new local copies. The local router is kept with this checkout.

## Verify

The default verification performs live upstream discovery and installs all seven skills into a temporary directory. It cleans that directory on exit and does not modify this checkout or global agent configuration:

```bash
./scripts/verify.sh
```

For local-only structural and router checks:

```bash
./scripts/verify.sh --offline
```

Upstream provenance, observed licenses, support files, and tested commit snapshots are recorded in [`docs/upstream-skills.md`](docs/upstream-skills.md). Cross-skill ownership and precedence rules are in [`docs/conflicts.md`](docs/conflicts.md).
