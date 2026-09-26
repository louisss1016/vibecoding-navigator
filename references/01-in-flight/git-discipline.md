# Git 纪律：commit 粒度和回滚策略

## 核心原则

**main 分支永远是"上一个验证通过的状态"。**

错了就 revert，不要在错的基础上继续改。

## commit 粒度

**每个最小切片验证通过后，commit 一次。**

不是：
- ❌ 一天结束才 commit
- ❌ 一个大功能做完才 commit
- ❌ 一周结束才 push

而是：
- ✅ 一个切片跑通了、测试过了、亲手验证了，立刻 commit
- ✅ 改了一行配置修了个 bug，验证通过了，也 commit

为什么：commit 越细，回滚越精确。错了就回到上一个 commit，不会把前面 5 个小时的工作搭进去。

## commit message 格式

```
【类型】【切片说明】

类型：feat / fix / refactor / test / docs
切片说明：这一轮做了什么用户可见的事

验证方式：【跑了什么命令 / 做了什么操作】
证据：【贴关键输出或截图文件名】
回滚点：本 commit 可直接 revert
```

例子：
```
feat: 事件流按 sequence 排序验证通过

验证方式：node test/run-order.test.js
证据：3个session并行跑，事件不乱序
回滚点：本commit可直接 revert
```

## Issue / Commit / PR 各回答一个问题

三个载体的语义分工，写之前想清楚：

| 载体 | 回答的问题 | 写什么 |
|---|---|---|
| Issue | **为什么做** | 需求与上下文、验收标准、实施记录 |
| Commit | **做了什么** | 改了哪一部分、为什么改、影响什么 |
| PR/MR | **为什么这样改** | 见下面七项 |

Commit message 上面的格式就是"做了什么"；PR 描述记"为什么这样改"——后者才是 review 时真正省时间的东西。

## PR 描述至少写七项

```markdown
1. 背景：这个 PR 解决什么问题
2. 解决方案：为什么选这个方案，备选是什么
3. 改动范围：改了哪些文件/模块，明确不碰什么
4. 测试方式：跑了什么命令、结果是什么、证据路径在哪
5. 风险：可能影响什么，出问题怎么回滚
6. 截图/日志：UI 改动贴图，关键输出贴全文
7. 关联 Issue：没有关联 Issue 的 PR，先问"为什么做"
```

个人项目不开 PR，就把这七项压缩进 commit message 的"切片说明"和 AGENTS.md 的切片记录——信息不因为流程简化而丢失。

## commit 前四问

commit 之前，问自己这四个问题：

1. **删了什么？** 有没有删掉不该删的代码？
2. **API 变了吗？** 有没有改函数签名、数据库 schema、接口契约？
3. **加了新依赖吗？** 有没有装新的 npm/pip 包？
4. **碰了禁区文件吗？** 有没有改 AGENTS.md 里"禁区"section 列的文件？

任何一个答案是"是"，先想清楚该不该，再 commit。

## 回滚策略

### 小问题回滚（这个切片做错了）

```bash
git revert <commit-hash>
```

回到上一个能跑的状态，重新规划这个切片。

### 大方向错了（要回到好几步之前）

1. 先看 AGENTS.md 的"已完成"列表，找到你想退到哪个 commit
2. `git log --oneline` 确认那个 commit hash
3. 从那个 commit 开新分支：
   ```bash
   git checkout -b recovery <commit-hash>
   ```
4. 或者直接 reset：
   ```bash
   git reset --hard <commit-hash>
   ```
   （注意：reset 会丢掉后面的 commit，确认好了再用）

### 回滚后必须做的事

- 更新 AGENTS.md 的"已完成"，把回滚掉的切片标记为废弃
- 在"已废弃"section 写清楚为什么废弃
- 不要删掉回滚的 commit 记录，留着它告诉未来的你"这条路试过了，不行"

## 分支策略（个人项目简化版）

不需要复杂的 Git Flow。

- `main`：永远是上一个验证通过的状态
- 新切片直接在 main 上做就行（个人项目没必要开 feature 分支）
- 如果你怕 main 弄脏，每个切片开始前 `git checkout -b slice-xxx`，做完合回 main
- 不要在 main 上保留"写了一半的代码"——要么 commit 验证通过，要么 stash

## 不要做的事

- 不要 `git push --force`（除非你知道你在干嘛）
- 不要 `.gitignore` 里漏 `node_modules/`、`.env/`、`dist/`
- 不要把密钥、API key commit 进去
- 不要"先 commit 了再说"——验证不通过就不要 commit
