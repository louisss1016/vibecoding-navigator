# Cross-skill conflict review

The six specialists are intentionally complementary, but several of them speak about the same code. The router therefore uses ownership boundaries instead of letting the last-loaded skill silently win.

| Overlap | Primary owner | Supporting owner | Boundary |
| --- | --- | --- | --- |
| Electron + React renderer | `electron-best-practices` | `vercel-react-best-practices`, `frontend-design` | Electron owns process boundaries, security, IPC, packaging, and app integration. React/design own renderer code and visual decisions. |
| Type-safe preload IPC | `electron-best-practices` | `typescript-pro` | Electron owns the IPC contract boundary and security shape. TypeScript owns type modeling, generics, narrowing, and refactoring quality. |
| React UI implementation | `frontend-design` | `vercel-react-best-practices` | Design owns visual direction, typography, layout, content, and motion. Vercel owns React rendering, bundle, and data-fetching performance. |
| Electron E2E testing | `electron-best-practices` | `playwright-expert` | Electron owns app launch, windows, preload, and desktop integration. Playwright owns locators, fixtures, POM, waits, traces, and flake control. |
| SQLite persistence | `sql-pro` | `electron-best-practices` | SQL owns schema, queries, indexes, transactions, and optimization. Electron owns where database access lives and how it crosses IPC. |
| TypeScript across all layers | `typescript-pro` | all other specialists | TypeScript owns language-level type quality; it does not override a domain specialist's security, design, SQL, or test constraints. |

## Precedence rules

1. User requirements and the real project architecture win over every skill recommendation.
2. Security and process-boundary constraints from `electron-best-practices` win over convenience or UI patterns.
3. Domain ownership wins within its boundary: SQL for SQL, Playwright for test mechanics, design for visual direction, and React performance for renderer performance.
4. `typescript-pro` refines the types of the chosen design; it does not change the chosen runtime boundary.
5. Treat Vercel's Next.js/server-specific rules as conditional in an Electron renderer. Do not introduce Next.js server assumptions into a Vite/Electron app.
6. When two recommendations still disagree, surface the conflict, state the trade-off, and ask for a decision before making a broad architectural change.

The expected behavior is additive selection with explicit ownership, not merging all instructions into one undifferentiated prompt.
