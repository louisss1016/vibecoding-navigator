---
name: fullstack-desktop
description: Routes TypeScript, React, Electron, SQL/SQLite, UI design, and Playwright work to the installed specialist Agent Skills. Use when a desktop application task spans one or more of these domains.
---

# Fullstack Desktop Router

This is a thin routing index, not a replacement for the specialist skills. Read the task, identify every relevant domain, and apply the named specialist skills when they are installed and available to the agent.

## Routing table

| Task signals | Specialist skill |
| --- | --- |
| Electron, main process, preload, IPC, contextBridge, packaging, security | `electron-best-practices` |
| TypeScript, types, generics, type guards, strict typing, TS refactor | `typescript-pro` |
| React, component, hook, renderer, rendering, bundle or React performance | `vercel-react-best-practices` |
| UI, page, layout, styling, visual direction, component design | `frontend-design` |
| SQL, SQLite, database, schema, query, index, query optimization | `sql-pro` |
| Playwright, E2E, UI test, visual regression, page object, flaky test | `playwright-expert` |

## How to route

1. Match the user's task against the table; a task may match multiple rows.
2. Name every matching specialist skill before implementation begins.
3. Let each specialist provide its own technical guidance. Do not reproduce its instructions here.
4. If a matching skill is unavailable, report that fact and continue only with the guidance that is actually available.
5. Keep this router focused on selection. Do not invent a portable `call-skill` API: agents discover and load skills through their own normal Agent Skills mechanism.

## Selection notes

- Match by the substance of the task, not by a single incidental word.
- Use `typescript-pro` with typed IPC or typed React work when type design or refactoring is part of the task.
- Use both `frontend-design` and `vercel-react-best-practices` when a UI redesign also changes React components or rendering behavior.
- Use both `electron-best-practices` and `playwright-expert` when Electron behavior must be exercised through Playwright.
- Use `sql-pro` for persistence, schema, query, or index work even when the database is embedded SQLite.
- Keep the specialist set additive; selecting one row must not suppress another applicable row.

## Conflict policy

- `electron-best-practices` owns process boundaries, IPC security, packaging, and desktop integration.
- `typescript-pro` owns language-level types and refactoring, but does not override domain or security boundaries.
- `frontend-design` owns visual direction; `vercel-react-best-practices` owns renderer performance. Apply Next.js/server rules only when the project actually uses them.
- `playwright-expert` owns test mechanics; Electron owns app launch, windows, preload, and desktop integration.
- `sql-pro` owns schema, queries, indexes, and transactions; Electron owns where database access crosses the process boundary.
- If recommendations still disagree, surface the trade-off and ask before making a broad architectural change.

## Availability

The pack installer installs the router and six specialists together. A project may also install the specialists independently; in that case, only name skills that the agent can actually discover.

When no listed domain is present, do not force a specialist match.

## Example

For an Electron settings page that saves to SQLite and needs E2E coverage, select:

`electron-best-practices`, `typescript-pro`, `vercel-react-best-practices`, `frontend-design`, `sql-pro`, and `playwright-expert`.

The router does not decide implementation details, override an installed specialist, or require a particular framework beyond what the task requests.
