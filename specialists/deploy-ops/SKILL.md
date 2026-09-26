---
name: deploy-ops
description: 部署与运维专家。当项目要打包上线、配置 CI/CD、管理 dev/staging/prod 环境、接域名 SSL、做发布回滚、配监控日志错误上报、做数据库备份恢复、上线切换（Cutover）、处理线上事故（Incident）时使用。上线后的一切工程问题归这个专家。
contract:
  owns: [CI/CD 流水线, 环境分离与环境变量管理, 域名与 SSL, 发布与回滚, 监控与日志与错误上报, 用户反馈通道, 数据库备份与恢复演练, 上线准入（Go/No-Go）, Cutover 切换, Incident 响应与 Runbook]
  input: [切片定义, 部署目标（本地/Web/桌面/服务器）, 环境清单, 禁区清单, 验证命令]
  output: [改动文件清单, 部署/流水线原始输出, 自审结论, 冲突标记]
  forbidden: [业务功能开发, 流程决策, 前端/后端实现规范（找对应栈专家）]
---

# 部署与运维技术规范

这个专家管两件事：**怎么上去**（打包、CI/CD、环境、域名）和**上去之后怎么办**（监控、日志、错误上报、备份、回滚）。release-gate 里"部署"和"发布后"两节的执行细节归这里。

## 环境管理：三环境分离

| 环境 | 用途 | 纪律 |
|---|---|---|
| dev | 本地开发 | `.env.local`，可连测试库、可打 debug 日志 |
| staging | 上线前验证 | 配置与 prod 尽量一致，数据用脱敏样本 |
| prod | 真实用户 | 只从 CI/CD 发布，禁止本地直推；关 debug 日志 |

- 环境变量集中在一处读取（Node: `process.env` 经 config 模块；Python: pydantic-settings），代码里**零硬编码地址/密钥**。
- `.env.example` 进仓库（列出所有必需变量和示例值），`.env` 永不进仓库（gate.sh 会扫）。
- prod 配置检查清单：API 地址不是 localhost、debug 开关关、日志级别 info+、密钥用的是平台密钥管理不是仓库文件。

## 部署模式速查

| 项目形态 | 推荐路径 | 关键配置 |
|---|---|---|
| 静态/SPA | Vercel / Netlify / GitHub Pages | base 路径、SPA 重写规则、环境变量在平台配 |
| Next.js 全栈 | Vercel | 同上 + Server Actions/Route Handler 的密钥只存服务端 |
| Node 服务 | VPS + pm2 / systemd，或 Fly.io / Railway | 进程守护、日志轮转、端口、Nginx 反代 + HTTPS |
| Python 服务 | VPS + uvicorn（多 worker）+ Nginx，或 Railway / Render | `--workers`、无 `--reload`、静态文件由 Nginx serve |
| 桌面应用 | electron-builder / Tauri | 代码签名（至少 Windows/macOS 各一）、自动更新通道、安装包冒烟测试 |

无论哪种：**发布 = 打 tag → CI 构建 → 部署 → 从生产 URL 跑主链路 golden case**。禁止"本地 build 完手动拖文件上去"。

## CI/CD 最小流水线（GitHub Actions 形态）

```yaml
# .github/workflows/release.yml 骨架
on: { push: { tags: ['v*'] } }
jobs:
  gate-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: bash scripts/gate.sh          # 自动门禁：构建/测试/密钥/漏洞
      - run: <部署命令，按平台>              # 例：npx vercel --prod --token ${{ secrets.VERCEL_TOKEN }}
      - run: <生产 URL 冒烟：curl 主链路健康检查>
```

- 密钥放 CI 的 secrets，不进仓库；CI 里 gate.sh 不过就不许 deploy。
- tag 即回滚点：每次发布保留上一个 tag 的产物（Vercel/Netlify 自动保留历史部署，点一下即回滚；自建机房保留上一个 release 目录）。

## 域名与 SSL

- HTTPS 用平台自动证书（Vercel/Netlify 自带；自建用 certbot 自动续期，续期失败要有告警）。
- 自定义域名配好后，从真实域名（不是平台临时域名）走一遍主链路——临时域名和正式域名的 cookie/CORS 行为可能不同。
- 国内用户为主的项目，评估服务器地域和 ICP 备案要求，别等上线当天才发现。

## 监控、日志、错误上报（上线后不再是没人管的事）

最小可行三件套：

1. **错误上报**：前端接 Sentry（或等价物），后端全局异常处理器把错误信封 + 堆栈上报到日志系统。用户看到的报错界面给一个"报告问题"按钮，一键带上错误 ID。
2. **日志**：生产日志落盘 + 轮转（logrotate / pm2 日志管理），关键操作（登录、支付、删除）记审计日志。日志里**不打用户敏感数据**。
3. **健康检查**：一个 `GET /healthz` 返回版本号和基础检查，配外部 uptime 监控（UptimeRobot 免费档够用），挂了能收到通知。

反馈通道：README 里写清"出问题去哪提"（issue 链接 / 邮箱 / 群），第一个用户 bug 进来 → 回 in-flight 阶段修。

## 备份与恢复

- 数据库定时备份（SQLite：定时复制文件 + 保留 N 份；Postgres：pg_dump 定时任务），备份文件**存到另一个地方**（对象存储/另一台机），不要和库放同一台机器的同一块盘。
- **恢复演练**：上线前至少一次，从备份文件还原到一个干净环境，验证能跑起来。没演练过的备份等于没有备份。
- 灾难恢复清单写进 README：库丢了怎么恢复、服务挂了怎么回滚到上一个 tag、密钥泄露了怎么轮换。

## 上线准入：Go/No-Go 判断

上线不能只判断"代码写完了"。正式发布前过这张六组清单，任何一组有关键缺口 → No-Go，修完再评：

```text
业务
[ ] 范围已确认        [ ] 验收标准满足      [ ] 业务负责人确认
产品
[ ] 功能完整          [ ] 已知限制已同步
技术
[ ] 部署包已准备      [ ] 数据库迁移已验证  [ ] 外部依赖已确认  [ ] 配置正确
质量
[ ] SIT/UAT 完成      [ ] 性能验证完成      [ ] Critical/Blocker 问题关闭
运维
[ ] 监控已接入        [ ] 告警已配置        [ ] 日志可查询      [ ] Runbook 已准备  [ ] 回滚方案已验证
交付
[ ] 用户培训完成      [ ] 操作手册完成      [ ] 联系人与升级路径明确  [ ] 支持团队已接手
```

## Cutover：上线切换不是"点一下发布"

替换旧系统/旧版本时，切换前必须回答（写进发布方案，不靠现场记忆）：

```text
什么时候停旧系统？→ 数据什么时候迁移？→ 迁移谁执行？→ 迁移多久？
→ 如何校验数据（条数/关键字段对账）？→ 什么时候切流？→ 谁确认？
→ 失败怎么办？→ 如何回退到旧状态？
```

纪律：**切换方案先演练再执行**；切流后第一件事是跑主链路验证 + 看监控，不是庆祝。

## Incident：线上出问题以后怎么处理

不要第一反应"先找代码哪里错了"。真实故障处理的顺序：

```text
1. 评估影响（谁受影响、多大范围）
2. 先缓解影响（回滚 / 降级 / 限流——缓解手段要在出事前就备好）
3. 再定位根因
4. 恢复服务
5. 修复根因
6. 复盘并防止复发
```

三个词不要混：

| 概念 | 是什么 | 例子 |
|---|---|---|
| Incident | 线上正在发生的影响，第一要务是恢复 | 生产 500 飙升 |
| Problem | 导致多次 Incident 的潜在根因，第一要务是消除 | 发布流程缺少验证环节 |
| Bug | 代码缺陷，修完关单 | 某个接口没判空 |

运维文档分三级，别混着写：

| 文档 | 回答什么 | 例子 |
|---|---|---|
| Runbook | 已知问题怎么操作 | Redis 内存高 → 查 key → 查连接数 → 安全操作 → 验证恢复 |
| Playbook | 一类复杂事件怎么调查、决策、升级 | 接口大量 5xx → 评估范围 → 看最近发布 → 查依赖 → 判断是否回滚 → 升级 |
| SOP | 一整套标准流程怎么执行 | 本 skill 的发布流程本身就是 SOP |

## 告警必须能驱动动作（Alert ≠ Notification）

一个成熟告警至少回答七问：什么出了问题？影响谁？严重程度？谁负责？第一步做什么？在哪里看更多信息？什么条件下升级？什么时候通知业务/客户？——答不全的告警只是噪音，配 Runbook/Playbook 链接，按业务影响排序。

## SLO / SLA / SLI 不要混

- **SLI**：测量值（成功请求比例）
- **SLO**：内部目标（月成功率 ≥ 99.9%）
- **SLA**：对客户/合同的服务承诺（未达标触发约定补偿）

SLO 要贴近真实用户体验（主链路成功率），不是内部服务器指标。个人项目至少定义一条主链路 SLO，告警挂在它上面。

## 命令

- 本地预览生产构建（Web）：`npm run build && npm run start`
- 冒烟生产 URL：`curl -fsS https://<域名>/healthz`
- 备份（SQLite）：`sqlite3 app.db ".backup 'backup-$(date +%F).db'"`
- 回滚（Vercel）：`vercel rollback` 或在控制台选上一个部署

## 常见坑

1. **生产跑 dev server**：`--reload` / `npm run dev` 上生产——慢、内存涨、还带调试端点。发布命令里显式关。
2. **环境变量忘了在平台配**：本地 `.env` 有，生产没有，上线即 500。`.env.example` + gate.sh 扫描双保险。
3. **CORS/域名**：prod 域名和 localhost 的 origins 是两套，middleware 要显式列 prod 域名。
4. **日志打满磁盘**：debug 日志无轮转，VPS 三天写满。logrotate 是部署清单必选项。
5. **只会部署不会回滚**：第一次发布就要验证"退回到上一个 tag"的路径，别等出事才学。
6. **密钥进了 git 历史**：扫描发现时密钥已经泄露——轮换密钥 + 清历史，只在 README 写"已轮换"不够。

## 什么时候不用这个专家

- 纯本地自用、永远不上线的工具（那确实不需要，但 release-gate 的"第一次发布特殊检查"仍然适用）
