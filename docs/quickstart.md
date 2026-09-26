# 快速上手：30 分钟跑通第一个切片

> 适合：第一次用这个 skill、要从零启动一个绿地项目的人。
> 目标：30 分钟内完成"需求钉死 → 第一个切片派工 → 五要素回报 → 门禁通过 → commit"一个完整闭环。
> 全程以 todo app 为例（纯 Node、零依赖）。**接盘已有代码库的**，先走 `references/00-preflight/brownfield-recon.md` 只读侦察，再回到本文件第 2 步。

## 全流程一图

```
复制两个文件进项目                     ← 第 0 步（2 分钟）
      ↓
对 agent 说"开始 vibecoding"           ← 第 1 步（10 分钟）
agent 一次一个问题地反问，不写代码
      ↓
产出 PROJECT.md / ARCHITECTURE.md /
CODING_PROMPT.md + AGENTS.md           ← 第 2 步（8 分钟）
      ↓
定第一个最小切片 → 派工单（六项）      ← 第 3 步（5 分钟）
      ↓
子 agent 干活 → 五要素回报             ← 第 4 步
      ↓
跑 scripts/gate.sh → 通过 → commit    ← 第 5 步（3 分钟）
      ↓
下一个切片，循环
```

## 第 0 步：把两个文件复制进项目

skill 提供两个要复制进**被开发项目**（不是 skill 自己）的文件：

```bash
# 在 todo app 项目根目录
mkdir -p scripts tests
cp <skill路径>/scripts/gate.sh scripts/gate.sh
cp <skill路径>/references/02-postflight/golden-cases.json.tmpl tests/golden-cases.json
git init && git add -A && git commit -m "chore: 引入 gate.sh 与 golden cases 骨架"
```

`tests/golden-cases.json` 先原样复制，第一个切片做完后往里面加用例。

## 第 1 步：让 agent 反问，而不是写代码

对 agent 说：

> 开始 vibecoding。我想做个 todo app，个人用，先别写代码。

agent 应该读 `references/00-preflight/questioning-rules.md`，然后**一次只问一个问题**。一段真实的对话长这样（节选）：

```text
agent: 这个东西谁会用？他在什么情况下打开它？打开时想立刻看到什么？
用户: 我自己。早上到工位想看看今天要干嘛，随手记一条。

agent: 在没有这个 app 之前，你是怎么记这些事的？
用户: 微信文件传输助手或者便利贴，经常忘。

agent: 如果第一版只能做一件事，做完你就能用起来，是哪件事？
用户: 能加一条、能划掉、重启不丢。别的都不要。

agent: 你怎么知道这个版本可以给别人用了？哪一步你亲眼看到它工作了，才敢说做完了？
用户: 我加三条，划掉一条，关掉再打开，划掉的还在那。

agent: 第一版明确不做哪些事？
用户: 不做分类、不做提醒、不做多端同步、不做登录。

agent: 技术上有硬约束吗？
用户: 别搞花活，能跑就行。
```

四个问题就够定 MVP 了——信息够了就停，不要凑满 6 个。停止标准：你能一句话说清"用户做什么 → 系统返回什么 → 用户因此能完成什么事"、能列出明确不做什么、知道跑通哪条链路算成。

## 第 2 步：产出四个文件

反问结束后，agent 按模板产出（模板在 `references/00-preflight/templates/`）：

```text
todo-app/
├── PROJECT.md          # 谁用/什么场景/MVP/不做什么/验收标准/硬约束
├── ARCHITECTURE.md     # 模块划分 + 第一版技术选型 + 选型理由
├── CODING_PROMPT.md    # 可直接喂给 coding agent 的实现指令
├── AGENTS.md           # 技术栈/结构/禁区/验证命令（模板见 agents-md-discipline.md）
└── docs/evidence/      # 空目录，等证据落盘
```

`AGENTS.md` 是后续每轮 AI 的上下文入口——新话题先读它，不让 AI 通读源码。它的"禁区"section 就是将来派工单第 3 项的来源。

## 第 3 步：定第一个最小切片，开工单

第一个切片选 MVP 主链路的最小可验证单位。对 todo app：**"用户输入文字、点添加，列表出现这条 todo，输入框清空"**。

编排层（主 agent）按 `docs/execution-protocol.md` 的六项把派工单写全。一张真实密度的派工单：

```markdown
## 派工单 — slice-01-add-todo

1. 切片定义：用户在输入框打字、点"添加"后，列表顶部出现这条 todo，输入框清空。
2. 接口契约：addTodo(text: string) → { ok: true, todo } | { ok: false, error: 'EMPTY_TEXT' }。
   纯函数 + 内存数组，无跨层接口。契约由编排层定死，你无权改。
3. 禁区：src/todo.js 之外一律不碰；不许改 tests/golden-cases.json；不许加依赖。
4. 专家知识：纯 Node 项目，无 specialist 匹配——按 slice-discipline 通用规范执行，
   不假装有专家（stack-routing 注意项）。
5. 验证命令：npm test && node --check src/todo.js。期望：5 个用例全绿。
6. 硬规则：先提方案我确认后再写代码；只做这一个切片；不留 console.log。
```

注意第 6 条：子 agent 的**第一轮回报应该是方案**（改哪几个文件、每步做什么、怎么验证），不是代码。被批准后才动手。

## 第 4 步：收五要素回报

子 agent 说"完成了"的时候，必须带回五样东西，**缺任何一样都视为未完成**（这是铁律 4 的执行层版本）：

```markdown
1. 文件清单：新增 src/todo.js、tests/todo.test.js；未改其他文件。
2. 验证命令 + 原始输出全文：
   $ npm test
   ...（TAP 输出贴全文，# pass 5 # fail 0，不许摘要成"测试通过"）
   $ node --check src/todo.js → 无输出，退出码 0
3. 证据路径：docs/evidence/slice-01-add-todo/test-output.txt、add-success.png
4. 自审结论：空输入返回 EMPTY_TEXT 已覆盖；200 字截断做了（MAX_LEN）；
   toggle/remove 做成纯函数，原数组不被修改——这条用例也补了。
5. 冲突标记：无。
```

只汇报"新增了哪些函数、封装了哪些类"而没有用户可见行为和证据的，直接打回——它在汇报代码量，不是汇报价值。

## 第 5 步：跑门禁，通过后 commit

```bash
bash scripts/gate.sh
```

真实输出（纯 Node 零依赖项目，2026-09-25 实跑）：

```text
gate.sh  20260925-185841  cwd=/.../smoke-todo
检测到技术栈：node

== 1. git 工作区 ==
  [PASS] git 工作区干净
== 2. debug 残留 ==
  [PASS] 无 debug 残留
== 3. 密钥泄露 ==
  [PASS] 未发现硬编码密钥
== 4. 依赖漏洞 ==
  [WARN] npm audit 跑不动（网络？），人工确认后放行
== 5. 构建 ==
  [PASS] npm run build 通过
== 6. 测试 ==
  [PASS] npm test 通过
== 7. golden cases ==
golden cases: 2 条自动 / 1 条手动
  [RUN ] add-todo-suite: npm test
  [RUN ] syntax-check: node --check src/todo.js
自动 golden cases 全部通过
  [PASS] 自动 golden cases 全部通过
  [WARN] 还有 1 条 manual case 需人眼执行（release-gate 人眼级）

================ 汇总 ================
PASS 6 | WARN 2 | FAIL 0
自动门禁通过。继续人眼级检查（release-gate.md）。
```

WARN 不阻断发布（npm audit 网络不通、manual case 留给人眼级）；**FAIL 才阻断**。门禁通过后 commit，把新遇到的边界情况补一条进 `tests/golden-cases.json`，更新 `AGENTS.md`，然后开下一个切片。

发布前的完整流程（含人眼级七节）见 `references/02-postflight/release-gate.md`；每轮 8 步的完整走法见 `references/01-in-flight/round-loop.md`。

## 派工单和五要素，在真实对话里到底多重

实测密度（以本文件第 3、4 步的实例为准）：

- 派工单六项 ≈ 15-25 行 markdown，写一次管一个切片
- 五要素回报 ≈ 10-20 行，其中"原始输出全文"是大头

判断：**值得**。它防的是最贵的失效模式——AI 说"完成了"但其实没跑过。减负空间在契约项：单文件小项目第 2 项一行带过（"无跨层接口"）即可；但五要素一项都不能砍，缺一项就等于没验收。如果跑起来依然觉得每轮写派工单太麻烦，先砍篇幅别砍项数。

## 常见卡点（都是真踩过的）

| 现象 | 原因 | 怎么办 |
|---|---|---|
| agent 不反问，直接开始写代码 | 没触发 questioning-rules | 把"先别写代码"说在前面；仍不行就重开对话显式让它读该文件 |
| `node --test tests/` 报 Cannot find module | **Node 22 起 `--test` 的位置参数按 glob 解释，传目录会被当成入口模块执行** | 用 `node --test "tests/**/*.test.js"` 或 `node --test tests/xxx.test.js` |
| 门禁第 1 项 FAIL：git 有未提交改动 | 跑门前有没提交的编辑 | 先 commit 再跑门禁；门禁要求的是"发布时工作区干净" |
| 子 agent 回报缺要素 | 它把回报当聊天，不当契约 | 直接打回，把缺的那项名字贴给它；缺要素 = 未完成，没有例外 |
| golden case 跑过了但功能是坏的 | 用例断言太弱（只断言"不抛异常"） | 断言必须包含用户可见行为：列表出现、状态切换、脏数据不产生 |
| npm audit 一直 WARN | 沙箱/离线环境 | 人工确认无新依赖后放行；有依赖时在能联网的环境重跑 |

## 下一步

- 每轮完整 8 步：`references/01-in-flight/round-loop.md`
- 怎么审查 AI 的活：`references/01-in-flight/adversarial-review.md`
- 五维评测：`references/02-postflight/eval-five-dimensions.md`
- 上线部署：`specialists/deploy-ops/SKILL.md`
- 做 Agent/LLM 项目：前期多答三问 + 挂 `specialists/agent-architecture/`
