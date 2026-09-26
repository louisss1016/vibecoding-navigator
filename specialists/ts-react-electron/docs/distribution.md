# Distribution policy

The deliverable is a folder, not a router plus a list of links.

The pack includes the actual upstream files for the four skills whose terms permit redistribution:

```text
vendor/skills/typescript-pro/
vendor/skills/sql-pro/
vendor/skills/playwright-expert/
vendor/skills/vercel-react-best-practices/
```

The pack retains those complete directories, including their `references/`, `rules/`, `AGENTS.md`, and `metadata.json` support files, and the installer installs them from local paths. GitHub is retained only as provenance and as the source for a deliberate refresh. The `skills` CLI may omit repository-only metadata when it copies a skill into an agent discovery directory; that does not remove the complete copy from this pack.

Two entries are intentionally runtime-only:

- NinjaSln's `electron-best-practices` has no declared redistribution license in the audited snapshot.
- Anthropic's `frontend-design` is covered by the repository's commercial terms rather than a permissive open-source license.

This is the maximum safe bundle based on the terms visible in the audited snapshots. To include either restricted entry in a redistributable package, obtain explicit permission from its copyright holder first, then add the permission record and a separately reviewed vendor copy.
