# AGENTS.md：项目的唯一上下文入口

新话题开始时，AI 不应该通读源码——它应该只读项目根目录的 `AGENTS.md` 就能接上进度。

## 为什么需要这个文件

Coding agent 是无状态的。每次新对话，它不记得上一轮聊过什么。AGENTS.md 就是它的"工作记忆"：
- 项目是干嘛的
- 做到哪了
- 哪些能碰哪些不能碰
- 下一步该干嘛

## 文件位置

项目根目录，命名 `AGENTS.md`（这是事实标准，Claude Code / Cursor / Codex 都自动读）。

## 完整模板

复制下面这段到项目根目录，填好：

```markdown
# AGENTS.md — 新项目从这里开始读，不要通读源码

> 新对话第一件事：读完这个文件再动手。
> 不要翻整个项目，只看这里提到的文件。

## 一句话目标
【从 PROJECT.md 复制一句话目标】

## Commands
- 安装：【npm install / pip install -r requirements.txt】
- 开发：【npm run dev】
- 测试：【npm test / pytest】
- 构建：【npm run build】
- 快速验证单个文件：【npm test src/api/notes.test.ts】

## 目录结构
【只列关键目录，不要全列】
- src/ui/       界面组件
- src/api/      业务逻辑
- src/db/       数据访问
- src/shared/   共享类型

## 进度

### 当前状态
- 阶段：【第2轮 / Runtime 编排】
- 正在做：【让 Research Loop 能取消】
- 上一个验证通过的 commit：【a3f2c1】

### 已完成
- [x] 第1轮：一条 quote → tool → 结果链路（commit 9b1e4d）
- [x] 第2轮切片1：Session/Run 数据模型（commit c88f2a）
- [x] 第2轮切片2：事件流按 sequence 排序（commit a3f2c1，证据 docs/evidence/slice-02/）

### 正在做
- 切片3：取消按钮 → run_cancelled 事件

### 已废弃（不要重新实现）
- 【比如：旧的 mock provider，已换成真实 API】

## 代码风格
- 【比如：错误统一用 { ok, data/error } 信封返回】
- 【比如：TypeScript strict，不写 any】
- 【比如：函数式组件，不用 class】

## 禁区（不要碰）
- src/legacy/          旧代码，不要改
- config/              配置文件，除非明确说
- 已完成的模块         除非这次切片要改它
- 不要加新依赖，除非我说

## Git 规范
- 每个切片验证通过后 commit
- commit 格式：【见 git-discipline.md】
- main 分支永远是上一个验证通过的状态

## 下一步建议
做完切片3后：
- 进第3轮评测
- 补 2 个 golden case：Provider 失败、超时取消

## 指向
- 完整规划：./PROJECT.md
- 架构图：./ARCHITECTURE.md
- 每次 prompt 模板：./CODING_PROMPT.md.tmpl
- 证据目录：./docs/evidence/
```

## 可追溯链：任何一行代码都能追到它为什么存在

AGENTS.md 是这条链的索引。成熟的做法不是文档多，而是**一个结果可以追溯到它为什么存在**。vibecoding 项目的简化链条：

```
PROJECT.md（为什么做、做什么）
  ↓
ARCHITECTURE.md（怎么设计的、关键决策为什么）
  ↓
切片 / Task（这一轮具体改什么）
  ↓
Commit（做了什么 + 验证方式）
  ↓
docs/evidence/（证据：测试输出、截图）
  ↓
Release / 发布记录（哪一版、改了什么）
  ↓
Feedback / Incident（用得怎么样、出了什么事）
  ↓
回到 PROJECT.md（下一轮要解决什么问题）
```

实际用法就一条：**AGENTS.md 里每条"已完成"都必须带 commit hash 和证据路径**——这样任何时候有人（或 AI）问"这个功能为什么长这样"，你能在 30 秒内从代码追到需求、从需求追到业务问题。追不动，就是链条断了，先补记录再写新代码。

## 更新规则

**每做完一个切片并 commit 后，必须更新 AGENTS.md**：

1. "正在做" → 移到"已完成"，附上 commit hash + 证据目录路径
2. "正在做" → 写新的切片内容
3. "上一个验证通过的 commit" → 更新成最新 commit
4. 如果有新的禁区或代码风格，加到对应 section

**变更需求后，必须更新**：
- "已废弃" section 加上被砍掉的模块
- "当前状态" 说明为什么变了
- 指向 PROJECT.md 的变更记录

## 防腐化机制（每轮开始前 30 秒）

AGENTS.md 最大的风险不是写不好，是**过期**——AI 读到假进度比不读更糟。每轮新对话开始时，先做三个核对，任何一个不过，先修 AGENTS.md 再动手：

1. **commit hash 核对**：`git log --oneline -5`，"上一个验证通过的 commit"是否真实存在且在最上面几个里？不在 → 更新。
2. **进度核对**：`git status` 和"正在做"对得上吗？工作区有一堆"已完成"列表里没有的改动 → 要么补记录，要么先处理。
3. **禁区核对**：禁区里列的路径/文件还存在吗？已废弃模块的禁区该撤销就撤销。

**半自动重建**：进度段可以直接从 git 历史重新生成，不靠手记：

```bash
git log --oneline -20   # 对着输出重写"已完成"列表，一条 commit 一行
```

如果重写后发现 git 历史和记忆差很多，说明中间有没 commit 的活——先按 git-discipline.md 补齐。

**腐化信号**（出现任一条，当轮不写代码，先修文件）：
- 连续 3 轮以上没更新过 AGENTS.md
- "已完成"里的功能实际代码里找不到
- 两个对话对"做到哪了"给出不同答案

## 新对话第一条指令

每次新开一个对话，第一句永远是：

```
读项目根目录的 AGENTS.md，不要通读源码。
先核对 commit hash 和 git status 与文件里的记录一致，再告诉我：
你现在理解到什么程度，下一步打算做什么。
我说可以之后再动手。
```

## 常见错误

- **AGENTS.md 写得太长**：超过 200 行就没人看了，AI 也读不进。只留关键信息，细节去看对应文件（证据去 docs/evidence/，别贴进来）。
- **从来不更新**：那它就是个摆设，新对话 AI 读了还是不知道进度。每轮必更，且先防腐化核对再更新。
- **把所有代码注释都搬进来**：不要。代码里的注释让 AI 自己看源码，AGENTS.md 只放"导航"信息。
- **忘了 commit hash**：记 commit hash 是为了回滚时直接 `git revert`，不用翻 log。
- **把证据贴进 AGENTS.md**：贴路径。目录在 docs/evidence/，AGENTS.md 只放引用。
