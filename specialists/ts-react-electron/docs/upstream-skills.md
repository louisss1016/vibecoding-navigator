# Upstream Skill Audit

Checked 2026-08-30 from the `main` branches with shallow clones. The repository snapshots used for this audit were:

| Repository | Checked commit | License observation |
| --- | --- | --- |
| [NinjaSln-labs/agent-skills](https://github.com/NinjaSln-labs/agent-skills) | `7b3de9c1c95e3378bb9cb8783eab0edc082e410a` | No root license file was present in the checked repository; the requested skill has no license frontmatter. Redistribution is not presumed. |
| [Jeffallan/claude-skills](https://github.com/Jeffallan/claude-skills) | `882ef55e377dbf9a4dbe496bb41ac6ccd0e555cf` | Repository `LICENSE` and the three requested skills declare MIT. Copyright notice: `Copyright (c) 2025`. |
| [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | `063bee94c3f4df8453406c830b0a7df0f2860278` | GitHub identifies the repository as MIT; the requested skill also declares MIT in its frontmatter. |
| [anthropics/claude-code](https://github.com/anthropics/claude-code) | `f1af9b1f4b1fd4c776135381606edada82ef638e` | Root `LICENSE.md` says use is subject to Anthropic Commercial Terms. The requested skill says `Complete terms in LICENSE.txt`, but no such file was present inside the targeted skill directory. |

## Requested skills

| Skill | Source / path | Actual `name` | License | Install mode | Support and dependency observations | Tested |
| --- | --- | --- | --- | --- | --- | --- |
| `electron-best-practices` | [agent-skills/electron-best-practices](https://github.com/NinjaSln-labs/agent-skills/tree/main/electron-best-practices) | `electron-best-practices` | Undeclared for repository/skill | Runtime install from repository with `--skill` | `SKILL.md`, `references/`, `scripts/`, and `assets/`; `SKILL.md` references Deno scripts and all three support trees. | Yes: `npx skills add ... --skill electron-best-practices` |
| `typescript-pro` | [claude-skills/skills/typescript-pro](https://github.com/Jeffallan/claude-skills/tree/main/skills/typescript-pro) | `typescript-pro` | MIT | Bundled under `vendor/skills/typescript-pro/` | `SKILL.md` and five `references/` files; no scripts/assets observed. | Yes: local bundled install and source audit |
| `sql-pro` | [claude-skills/skills/sql-pro](https://github.com/Jeffallan/claude-skills/tree/main/skills/sql-pro) | `sql-pro` | MIT | Bundled under `vendor/skills/sql-pro/` | `SKILL.md` and five `references/` files; no scripts/assets observed. | Yes: local bundled install and source audit |
| `playwright-expert` | [claude-skills/skills/playwright-expert](https://github.com/Jeffallan/claude-skills/tree/main/skills/playwright-expert) | `playwright-expert` | MIT | Bundled under `vendor/skills/playwright-expert/` | `SKILL.md` and five `references/` files; no scripts/assets observed. | Yes: local bundled install and source audit |
| `vercel-react-best-practices` | [agent-skills/skills/react-best-practices](https://github.com/vercel-labs/agent-skills/tree/main/skills/react-best-practices) | `vercel-react-best-practices` | MIT | Bundled under `vendor/skills/vercel-react-best-practices/` | Contains `SKILL.md`, `AGENTS.md`, `README.md`, `metadata.json`, and `rules/`. The repository-root `--list` does not select this skill, so the direct path was used for the snapshot. | Yes: local bundled install and source audit |
| `frontend-design` | [claude-code/plugins/frontend-design/skills/frontend-design](https://github.com/anthropics/claude-code/tree/main/plugins/frontend-design/skills/frontend-design) | `frontend-design` | Anthropic terms; see repository `LICENSE.md` and skill's `LICENSE.txt` reference | Runtime install from official direct skill path; not vendored | Targeted directory contains only `SKILL.md`; its license metadata refers to a file not included in that directory. The full repository is not treated as an MIT source. | Yes: `npx skills add .../tree/main/plugins/frontend-design/skills/frontend-design --skill frontend-design` |

## Why the pack uses both bundled and runtime installation

The pack includes exact directory copies for the four MIT-licensed entries. The installer passes those local directories to the official `skills` CLI, while the pack itself retains support files such as `references/`, `rules/`, `AGENTS.md`, and Vercel's repository-only `metadata.json`. The current CLI may omit repository-only metadata from the agent discovery copy, but the complete source remains in `vendor/`. The two entries without permissive redistribution terms remain runtime-only and are fetched from their official source paths during installation.

The runtime model does not remove the user's obligation to comply with each upstream repository's terms. In particular, `frontend-design` and the undeclared NinjaSln skill should not be copied into another distribution without permission. See [`docs/distribution.md`](distribution.md) and [`THIRD-PARTY-NOTICES.md`](../THIRD-PARTY-NOTICES.md).

## CLI verification

The local CLI check on 2026-08-30 returned `skills` version `1.5.23`. Its documented and observed agent identifiers are `claude-code`, `codex`, and `opencode`; project discovery paths are `.claude/skills/`, `.agents/skills/`, and `.agents/skills/` respectively. `--list`, repository `--skill`, direct skill-path `--skill`, local-path installation, `--copy`, and `--yes` were exercised in temporary directories.
