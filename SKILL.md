---
name: vibecoding-navigator
version: 2.6.0
description: Vibe coding 全流程导航：coding 前把需求/架构/技术选型钉死，coding 中按最小切片推进并通过子 agent 执行与验收，coding 后用五维评测和可执行发布门禁验收，上线后运维有人管。当用户说"我想做个项目""帮我规划一下""开始 vibecoding""这个项目怎么做"、从零启动新项目、改造已有项目、或做 Agent/LLM/多步任务项目时使用。覆盖需求澄清、切片推进、测试部署、上线运维全流程。
---

# Vibe Coding Navigator

这个 skill 不是教你怎么写代码，而是教你**怎么让 AI 写代码不翻车**。

核心信念：代码廉价，判断昂贵。AI 几分钟能生成几百行代码，但"用户到底要什么、怎么证明这次改对了、错了回退到哪一步、上线之后出事谁管"这些判断不能外包给 AI。

## 三段流程 + 一个执行层

```
前期 Preflight → 中期 In-flight → 后期 Postflight
把需求钉死       每轮一个最小切片    凭什么相信做完了
                        ↕
              执行层：子 agent 按 specialist 路由干活（docs/execution-protocol.md）
```

### 什么时候用哪段

| 你现在的状态 | 用哪段 | 先读哪个文件 |
|---|---|---|
| 还没开始写代码，想法模糊（绿地） | 前期 | `references/00-preflight/questioning-rules.md` |
| 接盘一个已有代码库 | 前期 + brownfield | `references/00-preflight/brownfield-recon.md` |
| 已经在写了，不知道下一步做什么 | 中期 | `references/01-in-flight/round-loop.md` |
| 功能写完了，不知道算不算完 | 后期 | `references/02-postflight/eval-five-dimensions.md` |
| 准备打包上线 | 后期 + 部署专家 | `references/02-postflight/release-gate.md` + `specialists/deploy-ops/` |
| 中途需求变了 | 前期变更流程 | `references/00-preflight/change-management.md` |

## 铁律（违反任何一条都等于没按这个 skill 做）

1. **先规划再动手**。没写 `PROJECT.md`、`ARCHITECTURE.md`、`CODING_PROMPT.md` 三个文件之前，AI 一行代码都不写。
2. **一次只做一个最小切片**。一个切片 = 一个用户可见行为 + 一个可运行验证。做完 commit，再开下一个。
3. **新话题先读 AGENTS.md**。不要让 AI 通读源码，让它读项目根目录的 `AGENTS.md` 续上下文，并先做防腐化核对。
4. **AI 说"完成了"不算数**。必须有真实运行证据（测试输出全文、窗口截图、curl 输出），按 `docs/evidence-format.md` 落盘，没有证据的"完成"是幻觉。子 agent 回报缺五要素中任何一项，视为未完成。
5. **不要改旁边的代码**。不在切片范围内的代码一个字符都别动，发现问题只在总结里提。
6. **main 分支永远可工作**。每个切片验证通过才 commit，错了直接 revert，不把半成品留在主线上。

## 路由表

### 前期：把需求钉死

| 你要做什么 | 读哪个文件 |
|---|---|
| 反问用户、澄清真正需求 | `references/00-preflight/questioning-rules.md` |
| 改造已有代码库（先侦察再提问） | `references/00-preflight/brownfield-recon.md` |
| 拆需求到本质（硬约束 vs 拍脑袋假设） | `references/00-preflight/first-principles.md` |
| 定义第一版 MVP 和"不做什么" | `references/00-preflight/mvp-definition.md` |
| 技术选型纠结（React vs Vue、SQLite vs Postgres） | `references/00-preflight/tech-decision.md` |
| 中途需求变更怎么处理 | `references/00-preflight/change-management.md` |
| 产出项目规划书 | `references/00-preflight/templates/PROJECT.md.tmpl` |
| 产出架构图 | `references/00-preflight/templates/ARCHITECTURE.md.tmpl` |
| 产出可直接喂给 coding agent 的 prompt | `references/00-preflight/templates/CODING_PROMPT.md.tmpl` |

### 中期：每轮一个最小切片

| 你要做什么 | 读哪个文件 |
|---|---|
| 一轮 vibecoding 应该怎么走完 8 步 | `references/01-in-flight/round-loop.md` |
| 写代码时的纪律（先读现状/契约先行/失败测试/参考文件） | `references/01-in-flight/slice-discipline.md` |
| 怎么审查 AI 做的东西（三视角 + 两阶段 review） | `references/01-in-flight/adversarial-review.md` |
| 每轮给 AI 的开口句式 | `references/01-in-flight/round-prompts.md` |
| AGENTS.md 怎么写、怎么维护、怎么防腐化 | `references/01-in-flight/agents-md-discipline.md` |
| git commit 粒度和回滚策略 | `references/01-in-flight/git-discipline.md` |

### 后期：凭什么相信做完了

| 你要做什么 | 读哪个文件 |
|---|---|
| 五个维度验收（结果/过程/证据/安全/成本，含测量命令） | `references/02-postflight/eval-five-dimensions.md` |
| 建立回归用例（golden cases，机器可读） | `references/02-postflight/golden-cases.md` + `golden-cases.json.tmpl` |
| 六种产品状态都有 UI 落点 | `references/02-postflight/product-states.md` |
| 发布前最后一道门禁（自动级 + 人眼级） | `references/02-postflight/release-gate.md` |
| 证据长什么样、放哪、怎么引用 | `docs/evidence-format.md` |

### 执行层：谁干活、怎么派工

| 你要做什么 | 读哪个文件 |
|---|---|
| 什么时候起子 agent、派工单格式、五要素回报、并行与仲裁 | `docs/execution-protocol.md` |
| 多专家冲突时听谁的（所有权矩阵 + 运行时仲裁） | `docs/ownership-matrix.md` |
| 证据格式与落盘 | `docs/evidence-format.md` |

### 技术栈专家（按需路由）

技术栈路由的唯一事实源是 `docs/stack-routing.md`。摘要：

| 技术栈信号 | 路由到 |
|---|---|
| LLM / Agent / 工具调用 / RAG / MCP / 多步任务 / 评测调优 | `specialists/agent-architecture/` |
| TypeScript / React / Electron / SQLite / Playwright / 前端视觉 | `specialists/ts-react-electron/`（入口 `skills/fullstack-desktop/SKILL.md`） |
| Python / FastAPI / SQLite / pytest | `specialists/python-fastapi/` |
| Java / Spring / Spring Boot / Maven / MyBatis / JPA / JUnit | `specialists/java-spring/` |
| Web / React / Next.js / Vercel | `specialists/web-react/` |
| Vue / Vue 3 / Vite / Pinia / Element Plus / Vue Router | `specialists/vue3/` |
| UI 打磨 / 圆角 / 阴影 / 动效 / 字体排印 / 配色精细 / 视觉评审 | `specialists/ui-polish/`（vendor better-* 工艺 pack 的 router） |
| 部署 / CI / 域名 / SSL / 回滚 / 监控 / 日志 / 备份 | `specialists/deploy-ops/` |

技术栈专家只回答"怎么写"的问题，不回答"做什么"和"做到哪算完"的问题——那是上面三段流程的事。每个 specialist 头部带 `contract` 契约块，派工前先读契约再派工。

## 怎么开始一个新项目

> 第一次用：先读 `docs/quickstart.md`，30 分钟端到端跑通一个例子，再回来按下面走。

1. 读 `references/00-preflight/questioning-rules.md`，按规则反问用户。（已有代码库先读 `brownfield-recon.md`）
2. 走完前期规则文件，产出三个模板文件到项目根目录：`PROJECT.md`、`ARCHITECTURE.md`、`CODING_PROMPT.md`。
3. 在项目根目录建 `AGENTS.md`（模板见 `references/01-in-flight/agents-md-discipline.md`）和 `docs/evidence/` 目录。
4. 读 `docs/execution-protocol.md`，从第一个最小切片开始中期流程：每个切片走 `round-loop.md` 的 8 步，按 execution-protocol 派工给子 agent、收五要素回报。
5. 每个切片验证通过后 commit（格式见 `git-discipline.md`），更新 `AGENTS.md` 和 `tests/golden-cases.json`。
6. 功能做完进后期验收：跑 `eval-five-dimensions.md`，发布前跑 `scripts/gate.sh` 自动门禁 + `release-gate.md` 人眼级清单。
7. 上线按 `specialists/deploy-ops/SKILL.md` 执行，发布后监控/反馈/回滚归 deploy-ops——上线后不再是没人管的事。

## 注意

- 这个 skill 是导航，不是百科。不要把任何技术细节复制进来，技术内容全在 `specialists/` 里。
- 前期做重，因为前期翻车成本最低；后期验收做严，因为发布后翻车成本最高。
- 遇到没想清楚的需求，回到前期追问，不要让 AI 在模糊需求上自由发挥。
- 铁律 4 和 evidence-format 是配套的：没有落盘证据的验收等于没验收。
- **做 Agent 项目（接 LLM、有工具调用、多步任务）**：前期多答三问（ questioning-rules 的"Agent 项目追加三问"），技术契约全程挂 `specialists/agent-architecture/`，验收加七项细查和 agent 类 golden cases。
- 升级历史见 `CHANGELOG.md`；这个 skill 怎么装见 `INSTALL.md`。
