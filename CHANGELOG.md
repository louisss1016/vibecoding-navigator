# CHANGELOG

本文件记录 vibecoding-navigator 的结构性变更。版本号与 `VERSION` 文件、主 SKILL.md frontmatter 保持一致。

## [2.3.0] — 2026-09-25

主题：**融合企业级研发 SOP，补上"个人 vibecoding 到团队交付"之间的方法论缺口**。融合来源为外部 SOP 文档《软件/AI公司业务与研发全流程 SOP》（50 章 + 4 附录，约 1.6 万行）。融合原则：**工程契约进 specialists、流程决策进 references、导航层不复制技术细节**——约三分之一内容为真缺口（其余与 skill 现有内容重复或为企业 ToB 专属如售前/FDE/立项，不融）。所有新内容落到既有文件的既有章节，不开新 specialist、不增导航层负担。

### 新增

- `specialists/agent-architecture/SKILL.md`（P0，四大块）：
  - **AI 应用五层测试面**：Model 层（准确性/稳定性/格式遵循/幻觉/安全）、RAG 层（Recall/Precision/Context Relevance/引用正确性/新鲜度/权限隔离）、Tool/MCP 层（工具选择/参数/权限/失败处理/重试/幂等）、Agent 层（任务完成率/步骤正确率/工具调用正确率/错误恢复/循环控制/成本/延迟）、Product 层（用户是否真完成业务目标）——回答"Agent 项目到底测什么"。
  - **知识库治理八问**与**AI 线上监控四层指标表**（技术/模型/Agent/业务——AI 项目的监控不能只有 CPU 和内存）。
  - **AI 项目四个坑**：模型强≠业务价值高、Demo 成功≠生产成功、没有 Eval 就无法稳定迭代、Tool/MCP 接通≠Agent 可用。
  - "30 秒定位"决策表同步更新 3 行。
- `specialists/deploy-ops/SKILL.md`（P0）：`## 命令` 前新增大节——**Go/No-Go 六组上线准入清单**（业务/产品/技术/质量/运维/交付）；**Cutover 八问**（停旧系统时机→数据迁移→切流→校验→回退，先演练再执行）；**Incident 六步**（评估影响→先缓解→再定位→恢复→修复→复盘）+ Incident/Problem/Bug 三概念区分表 + Runbook/Playbook/SOP 三级文档表；**Alert 七问**；**SLO/SLA/SLI 区分**（SLI 测量值/SLO 内部目标/SLA 合同承诺）。frontmatter 的 description 与 contract owns 同步扩充（Cutover/Incident 触发词、上线准入/Cutover/Incident 响应与 Runbook）。
- `references/01-in-flight/slice-discipline.md`（P0）：第 2 节末尾加**好任务五特点**（输入/操作/输出/验收标准/依赖明确）；文末加**DoR / DoD 两张 checklist**——DoR 管住"别急着派工"，DoD 管住"别急着合并"，任何一条不过退回重做。

### 变更（P1，八处充实）

- `references/01-in-flight/adversarial-review.md`：新增 **Code Review 十项优先级**（正确性→业务逻辑→安全性→数据一致性→错误处理→可维护性→性能→测试→可观测性→代码风格，前五项不过关直接打回，明确"不要降级成变量名好不好看"）；**必须升级评审的九种情况**（范围/架构/数据库/权限/外部集成/数据迁移/核心发布/生产变更/严重事故）；**Demo→生产六关**（真实数据/权限/并发/异常/成本/用户，少验证一关就用事故补上）；**复盘问题清单十条**（目标不是"谁写错了"是"下次怎么不再发生"）。
- `references/01-in-flight/git-discipline.md`：新增 **Issue/Commit/PR 语义分工表**（Issue=为什么做、Commit=做了什么、PR=为什么这样改）与 **PR 描述七项**（背景/解决方案/改动范围/测试方式/风险/截图日志/关联 Issue）；个人项目不开 PR 时压缩进 commit message 与 AGENTS.md，信息不因流程简化而丢失。
- `references/00-preflight/change-management.md`：新增**变更影响分析七维**（Scope/Schedule/Cost/Architecture/Test/Deployment/Acceptance）——变更请求七维逐个过再写进变更记录，跳过七维直接改代码会进入"范围膨胀→时间失控→技术债→测试不足→延期→仍不满意"螺旋。
- `references/02-postflight/eval-five-dimensions.md`：新增**项目级质量指标四类**——交付效率（Lead Time/Deployment Frequency/Release Cycle Time）、交付稳定性（Change Failure Rate/Recovery Time/Rework Rate，即 DORA 体系）、产品质量（线上缺陷/投诉/核心流程成功率）、业务结果（使用率/转化/成本/收入）。业务价值优先，前三类为它服务。
- `references/00-preflight/questioning-rules.md`：新增**"用户提的是方案，不是需求"**（"我要一个 Agent"不要直接进开发，先追业务目标）+ **可行性九维**（业务/技术/数据/资源/时间/成本/合规安全/客户接受/实施条件）——"可行"不是"技术上能写出来"。
- `references/01-in-flight/agents-md-discipline.md`：新增**可追溯链**——PROJECT→ARCHITECTURE→切片→Commit→evidence→Release→Feedback→下一轮需求；硬要求：AGENTS.md 每条"已完成"必须带 commit hash 和证据路径，30 秒内从代码追到业务问题，追不动就是链条断了。
- `references/02-postflight/golden-cases.md`：新增**功能验证四件事**（正常/边界/异常/权限安全，前三类决定能不能用、第四类决定敢不敢上线）；**Case 挂了怎么记缺陷**（最小字段集：标题/环境/版本/复现步骤/期望/实际/影响范围/严重程度/优先级/日志截图）与 **Severity ≠ Priority**（问题多严重 vs 应该多快修，分开记才不会吵架）；修复后补复现 golden case（先红后绿）。
- `references/00-preflight/templates/ARCHITECTURE.md.tmpl`：新增**技术方案自检十问**（系统边界/核心模块/数据流/前后端交互/服务间通信/数据库设计/外部集成/异常处理/部署扩容回滚/监控排障验证）——答不上来的就是方案里的空洞。

### 回归

- 路由测试执行器 13/13 PASS（路由表未变，无漂移）。
- 版本一致性：VERSION / 主 SKILL.md frontmatter / CHANGELOG 三处均为 2.3.0。

## [2.2.1] — 2026-09-25

主题：**安装面扩展到 CodeBuddy**。核实 CodeBuddy（CLI + IDE）的 skill 机制后补入安装路径与分层兼容性说明。

### 变更

- `INSTALL.md`：安装路径表新增 CodeBuddy Code（CLI，`.codebuddy/skills/`）与 CodeBuddy IDE（设置页导入）两行；新增"CodeBuddy 兼容性说明"按层表格——skill 装载与渐进式披露完全兼容；子 agent 委派受支持，适配点为派工单第 4 项随单传递专家知识（不依赖预定义 agent）；脚本层需 Git Bash/WSL；验证安装增加 CodeBuddy 专属步骤（`/skills` 可见 + `/vibecoding-navigator` 可触发）。
- 主 `SKILL.md`：version 2.2.1。

### 说明

- 兼容性结论依据 codebuddy.cn 官方文档（CLI plugins / CLI best-practices / IDE Skills 三处）核实；子 agent 派工链路未在 CodeBuddy 实测——已在该节声明边界，首次使用按 quickstart 跑一个最小切片验证。

## [2.2.0] — 2026-09-25

主题：**补齐"跑得起来"的最后一环**。外部评审指出两个自动化"文档里说有、实际没人执行"、新用户缺端到端引导、最重的专家缺快速入口。本版把路由测试从数据升级为可执行门禁（首跑即抓到一处真实路由漂移），补 30 分钟 quickstart，给 agent-architecture 加 30 秒定位区，并用真实冒烟项目验证全链路。

### 新增

- **路由测试执行器**（`tests/run-routing-tests.py`）：`tests/routing-cases.json` 此前只是数据，没有任何东西执行它。执行器做四类检查：① 用例 schema（id 唯一、prompt 非空、expected 非空列表）② expected 每个条目在 skill 里定位到真实文件（specialist SKILL.md / pack 内 router / 前期流程文件）③ 防路由漂移——条目必须同时出现在 `docs/stack-routing.md`（唯一事实源）和主 SKILL.md 摘要表 ④ specialist 覆盖检查——`specialists/` 下每个专家至少要有一条用例。仅标准库，退出码 0/1。
- **快速上手**（`docs/quickstart.md`）：30 分钟端到端 walkthrough，todo app 贯穿：复制两个文件进项目 → 反问实录（四轮定 MVP）→ 四个产出文件 → 第一个切片的派工单实例（六项填满）→ 五要素回报实例 → gate.sh 真实输出 → commit。附"派工单/五要素到底多重"的实测判断与常见卡点表。

### 变更

- `specialists/agent-architecture/SKILL.md`：顶部新增"30 秒定位"区——主链路一句话骨架 + 问题→章节决策表。全文按问题跳读，不顺序读。
- `docs/stack-routing.md`：路由表新增 brownfield-recon 行（接盘存量项目的路由目的地此前只在 routing-cases 里断言、路由表里没有——被新执行器首跑抓到）；"加新专家"第 5 步从"加一条用例"改为"加用例并跑执行器确认通过"。
- `INSTALL.md`：验证安装从单一对话观察升级为"对话验证 + 跑路由测试"两步；加入口指向 quickstart。
- 主 `SKILL.md`：version 2.2.0；"怎么开始一个新项目"增加 quickstart 指引。

### 修复

- 无行为回退。`tests/routing-cases.json` 数据未动（13 条），只是从此有人执行它。

### 冒烟记录（2026-09-25 实跑，非文档声明）

- 冒烟项目：workspace `smoke-todo/`（纯 Node 零依赖 todo app，git 仓库，两个 commit）。
- 首跑 gate.sh：PASS 4 | WARN 2 | FAIL 2——抓到 `node --test tests/` 在 Node 22 报 MODULE_NOT_FOUND（`--test` 位置参数按 glob 解释，目录被当成入口模块执行）。改用 `node --test "tests/**/*.test.js"`。
- 修复后重跑：PASS 6 | WARN 2 | FAIL 0，exit=0（两个 WARN 为预期：沙箱无网络 npm audit 跳过；1 条 manual case 留人眼级）。该坑已写进 quickstart 常见卡点表。

## [2.1.0] — 2026-09-25

主题：**融合"四板斧"工程契约，覆盖 Agent 项目场景**。v2.0 解决的是"怎么把任何项目管住"，v2.1 补上"Agent 项目怎么做才对"——skill 原来的 specialists 全是 Web/后端/桌面栈，没有一个 Agent 架构专家，而 Agent 项目的材料设计、能力入口、多 Agent 升级、评测回流都有专门的工程契约。

### 新增

- **Agent 架构专家**（`specialists/agent-architecture/SKILL.md`）：融合三板斧核心契约。
  - 第一板斧（材料与能力）：场景材料五类型、RAG vs 知识地图分工、Tool Calling/MCP/CLI 三入口分工、Provider/Capability/Tool 三层分离、能力边界七条、ProviderResult 失败语义（complete/partial/stale/unavailable + missingFields + Recovery Action）、Mock 先行再换真实 Provider。
  - 第二板斧（编排）：Agent Loop 与停止条件、Prompt 六职责、Memory vs Skill vs Tool、单 Agent 失效信号表（七种）、多 Agent 默认升级顺序（单+Tool → +Skill → +Workflow → Router+Worker → Synthesizer+Critic）、Router/Worker/Synthesizer/Critic 角色表、多 Agent 四问（分工/通信/冲突/状态）、角色间只传结构化中间结果、持久化与恢复五语义。
  - 第三板斧（评测与成本）：评测工程化六环节（含 pass^k 稳定性、三类评分器、基线管理）、工程模式速查（三态熔断器、指数退避+jitter、降级三形式、缓存三层、结构化日志字段、Trace/Span 树、工具参数 JSON Schema 校验、两步授权、小模型做杂活）。
  - 核心信念落进契约：**模型不是安全边界**——授权、拦截、审计、确认在模型外部完成。
- `references/00-preflight/questioning-rules.md` 增加"Agent 项目追加三问"（一次回答 vs 连续任务 / 材料与能力 / 人工确认与停止条件）。
- `references/01-in-flight/round-prompts.md` 增加"阶段 1.5：第一条材料链路"开口 prompt（输入 → Tool/Mock → 事实，失败语义先于实现）。
- `references/02-postflight/golden-cases.json.tmpl` 增加 `agent` 类用例（会话隔离、Provider partial、Trace 还原、超预算降级、pass^3 稳定性）。

### 变更

- `docs/execution-protocol.md`：新增"多 Agent 升级判据"——起子 agent 前先对失效信号表，默认顺序不许跳级；并行子 agent 之间只传结构化中间结果。
- `references/01-in-flight/round-loop.md`：第 8 步回流从一句话升级为归因回流表（缺材料/缺编排/缺标准/缺承载/AI 跑偏 → 各自回流方向），回流后必须用同一失败案例重跑。
- `references/01-in-flight/adversarial-review.md`：新用户视角升级为四问法（第一次看懂/第一次会用/连续用不累/出错知道怎么办），"连续用不累"不过关 = 上下文连续性没做好，回拆解层而非加按钮。
- `references/02-postflight/eval-five-dimensions.md`：新增七项细查表（Outcome×2/Evidence×2/Trajectory×2/Safety×1）、评测工程化六环节、AuditDecision 回流表；Partial Success 不许误报。顺手修复一处加粗语法错误。
- `references/02-postflight/product-states.md`：六态 → 九态，Agent 项目追加 Provider unavailable / Runtime unavailable / Completed with warnings 三态及制造方法。
- `references/00-preflight/tech-decision.md`：新增 Agent 选型速查（上下文 vs RAG vs 知识库、Tool vs MCP vs CLI、单 Agent vs 多 Agent、单模型 vs 路由）。
- `references/02-postflight/golden-cases.md`：category 增加 agent；必备用例区分通用/Agent 两类。
- `docs/stack-routing.md`、主 `SKILL.md`：新增 agent-architecture 路由行；主 SKILL.md version 2.1.0，description 增加 Agent/LLM 项目触发词。
- `tests/routing-cases.json`：新增 K/L/M 三条 Agent 场景路由用例。

## [2.0.0] — 2026-09-25

主题：**从"人肉执行手册"升级为"可上线产品生产线"**。新增执行层、验收机械化、上线运维链路，修复路由缺陷。

### 新增

- **执行层协议**（`docs/execution-protocol.md`）：三层架构（编排层/执行层/知识层）；派工单六项格式；子 agent 回报五要素（缺一即未完成）；并行规则；运行时仲裁规则。specialist 从"被动文档"升级为"执行单元"。
- **证据格式**（`docs/evidence-format.md`）：证据落盘目录结构、三类证据标准、notes.md 模板、AGENTS.md 引用方式（引路径不贴内容）。
- **部署运维专家**（`specialists/deploy-ops/SKILL.md`）：CI/CD 最小流水线、三环境分离、域名 SSL、发布回滚、监控/日志/错误上报三件套、用户反馈通道、备份与恢复演练。ownership-matrix 中"上线后监控"从无人管改为归 deploy-ops。
- **golden cases 机器可读化**（`references/02-postflight/golden-cases.json.tmpl`）：`tests/golden-cases.json` 格式定义，`verify.type` 区分 command/manual。
- **自动发布门禁**（`scripts/gate.sh`）：git 干净度、debug 残留、密钥泄露、依赖漏洞、构建、测试、golden cases 自动部分一键检查，报告落盘 `docs/evidence/gate-<时间戳>.txt`，FAIL 即禁止发布。
- **存量项目改造流程**（`references/00-preflight/brownfield-recon.md`）：只读侦察 prompt、危险信号排查表（先于新功能）、RECON.md 模板。
- **路由测试**（`tests/routing-cases.json`）：覆盖三个 specialist + deploy-ops 的路由用例。
- **VERSION / INSTALL.md / CHANGELOG.md**：skill 自身工程化三件套。

### 变更

- `specialists/python-fastapi/SKILL.md`：从空壳骨架补全为完整技术规范（项目结构、FastAPI 约定、错误信封、数据库、pytest、常见坑），新增 contract 契约块。
- `specialists/web-react/SKILL.md`：同上（SPA/Next.js 双形态、组件约定、状态管理选型表、API 封装、Vercel 部署、常见坑）。
- `references/02-postflight/release-gate.md`：重构成"自动级（gate.sh）+ 人眼级"两级门禁；新增数据与迁移、安全与合规两节；发布后新增监控就位、反馈通道、回滚可执行检查。
- `references/02-postflight/eval-five-dimensions.md`：成本维补测量命令表（启动/响应/内存/泄漏/包体积）和 token/API 成本小节；证据维指向 evidence-format。
- `references/01-in-flight/agents-md-discipline.md`：新增"防腐化机制"（每轮 30 秒三核对、git log 半自动重建、腐化信号）；模板补充证据路径引用。
- `references/00-preflight/change-management.md`：新增"变更影响分析映射表"（变更类型 → 必跑 case 分类 → 必复核文档）。
- `docs/stack-routing.md`：确立为路由唯一事实源；修正 ts-react-electron 入口路径（`skills/fullstack-desktop/SKILL.md`）；新增 deploy-ops 路由行；新增 specialist 五步扩展流程（含契约块、路由测试）。
- `docs/ownership-matrix.md`：修正 UI 视觉所有者（frontend-design 实际在 ts-react-electron pack 内）；新增部署/上线后运维两行；新增"子 agent 时代的补充规则"。

### 修复

- 删除两处死引用 `../../.skill-template/SKILL.md`（该文件不存在，曾导致按指南扩展 specialist 直接卡死）。
- 修正主 SKILL.md 路由表指向 `specialists/ts-react-electron/` 但该目录无根 SKILL.md 的问题（实际入口在 `skills/fullstack-desktop/SKILL.md`）。
- 消除三张路由表（主 SKILL.md / stack-routing.md / pack 内置 router）的漂移：stack-routing.md 为事实源，其余只做摘要。

## [1.0.0] — 初始版本

三段流程（Preflight / In-flight / Postflight）、六条铁律、8 步循环、切片纪律、对抗性审查、五维评测、六种产品状态、golden cases、变更管理。specialists：python-fastapi、web-react（均为空壳）、ts-react-electron（完整 pack）。
