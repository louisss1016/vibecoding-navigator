# 发布门禁：最后一道检查

功能开发完、验收过了，发布前过门禁。门禁分两级：**自动级**（命令跑，全绿才准进人眼级）和**人眼级**（亲眼验证，任何一项打不了勾就不能发）。

```
自动级（scripts/gate.sh，一条命令）→ 全绿 → 人眼级（本文件清单）→ 全过 → 打 tag 发布
```

## 自动级：跑 `scripts/gate.sh`

把 skill 的 `scripts/gate.sh` 复制到项目（或软链），在项目根目录运行：

```bash
bash scripts/gate.sh
```

脚本自动检测技术栈（node / python），依次检查并给出 PASS/WARN/FAIL：

| 检查 | 对应原人工项 | FAIL 的处理 |
|---|---|---|
| git 工作区干净 | "git status 干净" | 先提交或 stash 再发 |
| debug 残留扫描（console.log/debugger/print/breakpoint） | "没有 debug 代码残留" | 删掉再发 |
| 密钥泄露扫描（硬编码 key/token/password 模式） | "没有硬编码密钥" | 改环境变量再发 |
| 依赖漏洞（npm audit / pip-audit） | （新增） | 升级或替换依赖 |
| 构建（npm run build / compileall） | "构建命令能跑通" | 修构建 |
| 测试（npm test / pytest） | 隐式在验收里 | 修测试 |
| golden cases 自动部分（tests/golden-cases.json 里 type=command 的） | "Golden cases 全部跑过" | 修 case 或修代码 |

退出码 0 = 自动级通过；1 = 有 FAIL；报告自动落盘 `docs/evidence/gate-<时间戳>.txt`。

**WARN 不阻塞发布，但要在 release note 里写明原因**（比如"pip-audit 未安装，依赖未扫描"）。

## 人眼级：发布前检查清单

### 功能

- [ ] MVP 主链路从头到尾走通了，亲手操作过（不是看 AI 的汇报）
- [ ] `PROJECT.md` 里的验收标准逐条打勾
- [ ] 五维评测（结果/过程/证据/安全/成本）没有 ❌
- [ ] `tests/golden-cases.json` 里 manual 类型的 case 全部人眼跑过，`last_run` 已更新

### 错误处理

- [ ] 六种产品状态都有 UI 表现（Loading/Empty/Partial/Stale/Error/Retry），每种截图留证
- [ ] 断网时不白屏，显示人话错误
- [ ] 错误信息不暴露堆栈、文件路径、API key
- [ ] 危险操作（删除、外发）有确认提示

### 构建和部署

- [ ] 构建产物能启动，跑一遍主链路
- [ ] 打包后的产物不是"开发模式"——资源路径对、环境变量对
- [ ] 如果是桌面应用：打出安装包，双击安装，能启动
- [ ] 如果是 Web 应用：部署到生产环境，**从生产 URL** 能访问、能走完主链路
- [ ] 部署过程本身按 `specialists/deploy-ops/SKILL.md` 执行（CI、环境变量、回滚方案就绪）

### 数据与迁移

- [ ] 数据库迁移：改过 schema 的，老用户升级后第一次用不崩（alembic upgrade / 迁移脚本验证过）
- [ ] 备份：上线前跑过一次备份，并验证备份文件能恢复（恢复演练，不是只备份）
- [ ] 全新安装：没有历史数据时，Empty 状态友好（golden case: fresh-install-empty）

### 安全与合规

- [ ] 自动级密钥扫描、依赖扫描通过（无 WARN 绕过）
- [ ] 生产环境变量在部署平台配好，`.env` 不进仓库
- [ ] 第三方依赖的 license 有记录（THIRD-PARTY-NOTICES 或等价物），商用前确认无传染性 license

### 配置与日志

- [ ] 配置文件默认值合理，不指向本地开发地址
- [ ] 生产环境不打 debug 日志，日志有落盘或上报位置
- [ ] 端口/域名：部署到真实环境后，URL 对不对

### 文档

- [ ] `AGENTS.md` 是最新的（进度、commit hash、下一步都对）
- [ ] `PROJECT.md` 的变更记录是最新的
- [ ] README 或使用说明写清楚怎么装、怎么跑
- [ ] 已知的限制写在文档里，不要埋在聊天记录里

## 发布流程

1. 跑 `scripts/gate.sh`，自动级全绿
2. 跑一次五维评测（`eval-five-dimensions.md`，含成本维测量命令）
3. 过一遍上面的人眼级清单
4. 构建 / 打包
5. 从构建产物启动，走一遍主链路
6. 打 tag：`v0.1.0`
7. 写 release note（这版做了什么、已知什么问题、WARN 项及原因）

## 第一次发布的特殊检查

第一次发布额外注意：

- [ ] 数据库迁移：如果之前改了 schema，新用户第一次用不能崩
- [ ] 配置文件：默认值合理，不要指向本地开发地址
- [ ] 日志：生产环境不要打 debug 日志
- [ ] 端口/域名：部署到真实环境后，URL 对不对
- [ ] 用户第一次打开：没有历史数据时，Empty 状态友好吗

## 发布后

- [ ] 监控就位：错误上报/日志有人看（方案见 `specialists/deploy-ops/SKILL.md`）——上线后监控不再是"没人管的事"
- [ ] 用户反馈通道就位：用户在哪报 bug、你怎么收到
- [ ] 告诉用户：怎么用、有什么已知问题
- [ ] 观察一天：有没有用户反馈 bug
- [ ] 回滚方案可执行：知道怎么退回到上一个 tag，且演练过
- [ ] 第一个 bug 进来，回到 in-flight 阶段修
