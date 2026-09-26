# Routing and Skill Discovery

## Mechanism verified

Agent Skills are directories containing a `SKILL.md` with YAML `name` and `description`. The current `npx skills` CLI installs project skills into the target agent's project discovery location and lets the agent discover them through its normal skill mechanism.

There is no portable cross-agent `call-skill` function that a Router skill can invoke. Therefore `fullstack-desktop` is deliberately an explicit routing index: it maps task signals to specialist skill names, while the agent's normal automatic selection remains authoritative. The router never pretends to load unavailable skills and does not duplicate specialist instructions.

The CLI version and agent identifiers verified for this first release are:

| Agent | `--agent` identifier | Project discovery path |
| --- | --- | --- |
| Claude Code | `claude-code` | `.claude/skills/` |
| Codex | `codex` | `.agents/skills/` |
| OpenCode | `opencode` | `.agents/skills/` |

The shared `.agents/skills/` path is expected for both Codex and OpenCode in the current CLI. The installer passes an explicit agent identifier rather than relying on auto-detection.

Four specialists are installed from the pack's bundled `vendor/skills/` directories. The Electron and frontend-design specialists are fetched at install time because their current upstream terms do not permit us to redistribute their contents. This distribution distinction does not change the routing names.

## Routing contract

| Domain signals | Route to |
| --- | --- |
| Electron, main, preload, IPC, contextBridge, packaging, security | `electron-best-practices` |
| TypeScript, types, generics, guards, strict mode, refactor | `typescript-pro` |
| React, components, hooks, renderer, rendering, bundle, performance | `vercel-react-best-practices` |
| UI, page, layout, styling, visual direction, component design | `frontend-design` |
| SQL, SQLite, database, schema, query, index, optimization | `sql-pro` |
| Playwright, E2E, UI testing, visual regression, page objects, flaky tests | `playwright-expert` |

## Test cases

The expected routes below are checked by `tests/verify-skills.sh` against the router contract.

| Case | Task | Expected specialist skills |
| --- | --- | --- |
| A | Fix the Electron preload IPC API. | `electron-best-practices`, `typescript-pro` |
| B | Optimize this React settings component. | `vercel-react-best-practices`, `typescript-pro` |
| C | Redesign the application sidebar. | `frontend-design`, `vercel-react-best-practices` |
| D | Optimize this SQLite query. | `sql-pro` |
| E | Add Playwright tests for the settings page. | `playwright-expert` |
| F | Build an Electron settings page that stores data in SQLite and add E2E tests. | all six specialist skills |

For case F, routing is intentionally additive: Electron, TypeScript, React, UI, SQL, and Playwright all apply. The agent should use the specialists that are installed and report any missing skill instead of silently treating the router as a substitute.

For the ownership matrix and precedence rules used when several routes match, see [`docs/conflicts.md`](conflicts.md).
