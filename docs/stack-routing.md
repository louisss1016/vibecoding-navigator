# 技术栈路由：任务信号 → 专家

> 本文件是路由的**唯一事实源**。主 SKILL.md 的路由表只是摘要，两边不一致时以本文件为准。

根据项目里出现的关键词，路由到对应的 specialist skill。多专家同时命中时，按 `ownership-matrix.md` 裁决。

## 路由表

| 信号 | 路由到 | 入口 |
|---|---|---|
| LLM / Agent / 智能体 / 工具调用 / Tool Calling / MCP / RAG / 多步任务 / 编排 / 评测调优 | `agent-architecture/` | `specialists/agent-architecture/SKILL.md` |
| Electron / 桌面应用 / 主进程 / preload / IPC / 打包 | ts-react-electron pack | `specialists/ts-react-electron/skills/fullstack-desktop/SKILL.md` |
| TypeScript / 类型 / 泛型 / strict mode / 类型重构 | ts-react-electron pack（typescript-pro） | 同上 |
| React（桌面端 Electron 内）/ hooks / 渲染性能 | ts-react-electron pack（vercel-react-best-practices） | 同上 |
| React（纯 Web）/ Next.js / Vercel / 浏览器前端 | `specialists/web-react/` | `specialists/web-react/SKILL.md` |
| SQLite / 数据库 schema / 查询 / 索引 | 看项目主栈：TS 项目 → ts-react-electron pack（sql-pro）；Python 项目 → `specialists/python-fastapi/` | 对应 SKILL.md |
| Playwright / E2E / 视觉测试 | ts-react-electron pack（playwright-expert） | `specialists/ts-react-electron/skills/fullstack-desktop/SKILL.md` |
| Python / FastAPI / uvicorn / Pydantic | `specialists/python-fastapi/` | `specialists/python-fastapi/SKILL.md` |
| pytest / Python 测试 | `specialists/python-fastapi/` | `specialists/python-fastapi/SKILL.md` |
| 部署 / CI / CD / 域名 / SSL / 上线 / 回滚 / 监控 / 日志 / 备份 | `specialists/deploy-ops/` | `specialists/deploy-ops/SKILL.md` |
| 前端视觉方向 / UI 设计 / 组件样式 | ts-react-electron pack（frontend-design，runtime-only） | `specialists/ts-react-electron/skills/fullstack-desktop/SKILL.md` |
| 接盘已有代码库 / 存量改造 / "不知道现在怎么跑的" | `references/00-preflight/brownfield-recon.md`（前期侦察流程，不是技术专家；侦察完按项目主栈再路由到上面的专家） | 同左 |

**关于 ts-react-electron**：它不是一个单独的 SKILL.md，而是一个完整的可安装 skill pack（自带 install.sh / manifest / vendor）。派工给子 agent 时，入口是 `skills/fullstack-desktop/SKILL.md` 这个 router，由它再路由到 pack 内的具体专家。

## 怎么判断路由

1. 读 `AGENTS.md` 的"技术栈"section，直接知道项目用什么。
2. 如果 AGENTS.md 没写，问用户："这个项目用什么语言/框架？"
3. 路由是叠加式的——一个"Electron + Python 后端"项目会同时命中两个专家。
4. 派工单格式、并行规则、仲裁规则见 `execution-protocol.md`——路由决定"挂哪个专家"，execution-protocol 决定"怎么派活"。

## 加新专家

如果要加新栈（比如 Go、Rust、Flutter、小程序）：

1. 在 `specialists/` 下新建目录
2. 写 `SKILL.md`，**头部必须带 contract 契约块**（格式见 `execution-protocol.md` 的"specialist 契约块"一节），内容参考 `specialists/python-fastapi/SKILL.md` 的结构——注意：不要再引用不存在的 `.skill-template`，直接照现有 specialist 写
3. 在本文件的路由表里加一行信号 → 新专家（含入口路径）
4. 在 `ownership-matrix.md` 里说明新专家的边界
5. 在 `tests/routing-cases.json` 里加至少一条该专家的路由用例，并跑 `python tests/run-routing-tests.py` 确认通过——执行器校验用例 schema、路由真实存在、与路由表无漂移，还检查新专家有用例覆盖

五步缺一不可，少一步这个专家就是不可路由的。

## 注意

- 技术专家只回答"怎么写"的问题，不回答"做什么"和"做到哪算完"。
- 如果路由到的专家不存在（比如用户要 Go 但没装），明确告诉用户"这个栈的专家还没写"，用通用原则代替，不要假装专家在。
- 不要因为看到一个关键词就强路由。要看任务实质——"用 React 画个图表"不一定需要完整的 React 专家，可能只是写个组件。
- 路由冲突（比如 React 信号同时命中 ts-react-electron 和 web-react）按项目实际形态裁：桌面壳里的 React 归 ts-react-electron，纯浏览器 React 归 web-react。
