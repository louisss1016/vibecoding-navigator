# Third-party notices

This pack contains unmodified copies of the following upstream skill directories. Their original directory structure, `SKILL.md` files, references, rules, metadata, and other support files are retained.

## Jeff Allan `claude-skills`

- Skills: `typescript-pro`, `sql-pro`, `playwright-expert`
- Source: https://github.com/Jeffallan/claude-skills
- Snapshot: `882ef55e377dbf9a4dbe496bb41ac6ccd0e555cf`
- License: MIT
- Copyright notice: Copyright (c) 2025

The MIT license applies to the three vendored skill directories through the upstream repository license:

```text
MIT License

Copyright (c) 2025

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Vercel React Best Practices

- Skill: `vercel-react-best-practices`
- Source: https://github.com/vercel-labs/agent-skills/tree/main/skills/react-best-practices
- Snapshot: `063bee94c3f4df8453406c830b0a7df0f2860278`
- License declared by the skill/repository: MIT

The Vercel skill's upstream `SKILL.md` declares MIT and the repository README states MIT. The copy is retained under `vendor/skills/vercel-react-best-practices/`.

## Not bundled

- `electron-best-practices` from NinjaSln-labs: no redistribution license was declared for the requested directory at the audited snapshot.
- `frontend-design` from Anthropic: the repository `LICENSE.md` reserves rights and points to Anthropic Commercial Terms; the skill also refers to a `LICENSE.txt` whose complete terms are not inside the requested directory.

Those two are still supported by the installer through their official source paths, but this pack does not copy their contents into its distribution.
