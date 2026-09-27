# 所有权矩阵：多专家同时命中时听谁的

一个项目经常同时命中多个专家。它们意见冲突时，按这个矩阵裁决。子 agent 并行执行时的仲裁规则见 `execution-protocol.md` 的"仲裁规则"一节——本文件是领域所有权的静态定义，execution-protocol 是运行时流程。

## 基本原则

- **按领域划边界，不要按文件划边界。**
- 每个领域有且只有一个"所有者"。
- 跨领域的决策，所有者说了算。

## 所有权表

| 领域 | 所有者 | 它说了算的事 | 它不管的事 |
|---|---|---|---|
| 项目流程 | vibecoding-navigator（主 skill） | 做什么、做到哪算完、下一轮做什么 | 具体代码怎么写 |
| 技术选型 | 主 skill + 用户 | 用什么栈、什么数据库 | 该选型的内部实现细节 |
| 代码质量 | 对应技术专家 | 这个栈该怎么写 | 流程对不对 |
| 架构边界 | 主 skill | 模块怎么分、跨模块怎么调 | 模块内部怎么实现 |
| Agent 架构 | agent-architecture | 材料与能力入口怎么接、Loop/多 Agent 怎么编排、评测对象与回流怎么定 | 具体某个框架/库的 API 用法 |
| Java 后端 | java-spring | Spring Boot 分层与依赖注入、Controller/Service/Repository 边界、事务怎么划、JPA/MyBatis 用法、JUnit 测试组织 | 流程对不对、前端与部署 |
| Vue 前端 | vue3 | Vue 3 SFC 与组合式 API、组件通信、Pinia 状态管理、Vue Router、Element Plus 用法、Vitest 测试组织 | 流程对不对、后端与部署 |
| 测试 | 技术专家 | 怎么写测试 | 测什么业务场景 |
| UI 视觉 | `references/00-preflight/ui-design-baseline.md`（跨栈设计基线） | 字号阶梯、间距节奏、色彩 token、布局层级、组件完成度底线 | 具体框架的写法（归各栈专家）、视觉素材制作 |
| 渲染性能 | ts-react-electron pack 内的 vercel-react-best-practices（Web React 场景归 web-react） | 渲染行为、bundle 性能 | 视觉方向本身 |
| 业务逻辑 | 主 skill + 用户 | 业务规则是什么 | 代码怎么写 |
| 部署 | deploy-ops | 怎么打包、怎么上线、怎么回滚 | 上线后监控归谁（见下） |
| 上线后运维 | deploy-ops | 监控、日志、错误上报、用户反馈通道、备份恢复 | 业务功能开发 |

> 历史修正：本矩阵曾把"UI 视觉"的所有者写成 web-react，并把"上线后监控"列为"它不管的事"。两处均已修正——frontend-design 实际存在于 ts-react-electron pack 内；监控是上线产品的一部分，归 deploy-ops。

## 常见冲突场景

### 场景 1：React 专家说"用 context"，TypeScript 专家说"用 discriminated union"

裁决：
- 代码风格（context vs zustand）→ React 专家
- 类型设计（discriminated union vs 其他）→ TypeScript 专家
- 两者不冲突，各管各的层

### 场景 2：Python 专家说"用 Django ORM"，前端专家说"REST API 返回这种格式"

裁决：
- 数据库 ORM 选什么 → Python 专家
- API 返回格式 → 前端专家（因为 UI 要消费这个格式）
- 不一致就定一个共享类型，两边都按这个类型写

### 场景 3：主 skill 说"这轮做最小切片"，技术专家说"这个功能需要重构才能做"

裁决：
- 流程上要不要拆切片 → 主 skill（这个它说了算）
- 但技术专家的警告要听：如果真的需要重构，把重构也当成一个单独的切片，不要混在功能切片里

### 场景 4：两个专家给了矛盾建议

裁决：
- 先看上面的所有权表，这个领域归谁听谁的
- 如果还分不清，把 trade-off 告诉用户，让用户定
- 不要自己偷偷选一个

## 跨领域修改的规则

如果一个切片要动两个领域（比如"加一个 todo，前端 UI + 后端 API 都要改"）：

1. 先定跨层接口（输入输出类型）
2. 前端专家按接口写 UI
3. 后端专家按接口写 API
4. 两边都完成后，对接测试
5. 接口本身归架构（主 skill）管，两边不能私自改

## 子 agent 时代的补充规则

specialist 从"文档"升级为"执行层子 agent"后（见 `execution-protocol.md`），以下规则同时生效：

- 子 agent 只在自己 `owns` 的领域内做决策，越界部分标记冲突回传，不自行处理。
- 接口契约由编排层在派工单里定死，任何专家（包括 deploy-ops）都不能单方面改契约。
- "上线后监控它不管"这种所有权真空不允许再出现——每个领域必须有且只有一个所有者，新增专家时必须先落所有权再写内容。

## 不要做的事

- 不要让一个技术专家越界改另一个专家的领域
- 不要因为"专家 A 说这样好"就压过专家 B——按所有权来
- 不要忽略冲突，假装它们一致
- 不要把矛盾丢给用户——先按所有权表裁，裁不动再问
