# INSTALL：这个 skill 怎么被 agent 用上

## 通过 git 安装与更新（推荐）

仓库已发布到 GitHub，用 git 管理安装副本——安装是一次 clone，升级是一次 pull，不会出现"装了旧版不知道"：

```bash
# 安装（以 Claude Code 用户级为例，其他平台换下表的对应路径）
git clone https://github.com/louisss1016/vibecoding-navigator.git ~/.claude/skills/vibecoding-navigator

# 升级（skill 发新版本后，在安装目录执行）
cd ~/.claude/skills/vibecoding-navigator && git pull
```

CI 对每次 push 自动跑路由测试与版本一致性检查（`.github/workflows/routing-tests.yml`），main 分支永远是通过门禁的状态——直接 pull 不会拉到坏版本。

## 手动复制安装（备选）

把整个 `vibecoding-navigator/` 目录复制到 agent 的 skill 发现路径下：

| Agent | 项目级路径 | 用户级路径 |
|---|---|---|
| Claude Code | `<项目>/.claude/skills/vibecoding-navigator/` | `~/.claude/skills/vibecoding-navigator/` |
| Codex | `<项目>/.agents/skills/vibecoding-navigator/` | `~/.agents/skills/vibecoding-navigator/` |
| CodeBuddy Code（CLI） | `<项目>/.codebuddy/skills/vibecoding-navigator/` | `~/.codebuddy/skills/vibecoding-navigator/` |
| CodeBuddy（IDE 插件） | 设置页"导入 Skill"，或项目 `.codebuddy/skills/vibecoding-navigator/` | 设置页导入（User Skills） |
| WorkBuddy | 项目级或用户级 skills 目录 | `~/.workbuddy/skills/vibecoding-navigator/` |

agent 通过 SKILL.md 的 `description` 自动发现和触发，无需手动调用。触发词见 description："我想做个项目""帮我规划一下""开始 vibecoding""这个项目怎么做"、从零启动新项目、改造已有项目。

## ts-react-electron pack 的额外安装

`specialists/ts-react-electron/` 是一个独立的可安装 pack（自带 `scripts/install.sh`）。路由到它时，按它的 README 执行：

```bash
cd <你的应用项目>
/path/to/vibecoding-navigator/specialists/ts-react-electron/scripts/install.sh claude-code
```

装完后 pack 内的 router（`skills/fullstack-desktop/SKILL.md`）才会被 agent 发现。未安装时按 `docs/stack-routing.md` 的注意项处理：明确告诉用户该专家不可用，用通用原则代替，不假装专家在。

pack 的升级走它自己的 `scripts/update.sh`（与 install.sh 同目录、同参数形式），与主 skill 的 `git pull` 相互独立。

## 使用时的两个复制动作

skill 提供两个要复制进**被开发项目**（不是 skill 自己）的文件：

1. `scripts/gate.sh` → 项目根目录 `scripts/gate.sh`（或软链），发布门禁自动级
2. `references/02-postflight/golden-cases.json.tmpl` → 项目 `tests/golden-cases.json`，随项目演进补充

其余文件（PROJECT.md / ARCHITECTURE.md / AGENTS.md 等模板）按流程在被开发项目里就地生成，见主 SKILL.md 的"怎么开始一个新项目"。

## CodeBuddy 兼容性说明

依据 codebuddy.cn 官方文档（CLI plugins / best-practices、IDE Skills）核实，2026-09-25。按层说明：

| 层 | 兼容性 | 说明 |
|---|---|---|
| Skill 装载与触发 | 完全兼容 | CodeBuddy 技能就是 `SKILL.md` + `name`/`description` frontmatter；description 自动触发（本 skill 触发词已写全），`/vibecoding-navigator` 可手动触发；`/skills` 查看装载与 token 占用 |
| 渐进式披露 | 完全兼容 | CodeBuddy 三级披露（description 常驻 / SKILL.md 主体 / 打包资源按需加载）与本 skill"导航层不复制技术细节"的架构同构——references/、specialists/、scripts/ 天然按需加载 |
| 执行层（子 agent） | 支持，有一个适配点 | CodeBuddy Code 支持自定义子代理与任务委派（`.codebuddy/agents/`）。本 skill 的派工单第 4 项"专家知识"设计为**随派工单传递**，不依赖预定义 agent；若宿主只认静态 agent 定义，把 specialist 契约块写进委派 prompt 即可，`docs/execution-protocol.md` 不用改 |
| 脚本（gate.sh / 路由测试） | 兼容，注意 shell | 两个脚本都按 `bash scripts/gate.sh` / `python tests/run-routing-tests.py` 显式调用，不依赖默认 shell；Windows 下需要 Git Bash 或 WSL |
| 流程/铁律/验收文档 | 完全兼容 | 纯 markdown，无宿主依赖 |

**未经实测的声明边界**：以上为文档级核实；子 agent 派工链路尚未在 CodeBuddy 里实跑。首次使用建议按 `docs/quickstart.md` 跑一个最小切片验证执行层协议，再全面铺开。

## 验证安装

两步验证：

1. **对话验证**：对 agent 说："开始 vibecoding，我想做个 XX"。agent 应该先读 `references/00-preflight/questioning-rules.md` 并开始反问，而不是直接写代码。
2. **路由测试**：在 skill 根目录跑 `python tests/run-routing-tests.py`，全部用例应 PASS（校验用例 schema、路由真实存在、路由表无漂移、specialist 有用例覆盖）。
3. **CodeBuddy 用户**：`/skills` 列表应出现 vibecoding-navigator；输入 `/vibecoding-navigator` 能手动触发。

第一次用？先读 `docs/quickstart.md`——30 分钟端到端跑通第一个切片：复制模板 → 反问 → 产出三个 md → 派第一个切片 → 收五要素回报 → 门禁通过。
