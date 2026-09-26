---
name: web-react
description: Web 前端 React/Next.js/Vercel 栈的技术专家。当项目是纯 Web 应用、用 React 或 Next.js 做前端、部署到 Vercel/Netlify 时使用。
contract:
  owns: [React 组件与 hooks 约定, 状态管理选型, API 调用层, 样式方案, 六种产品状态的 UI 落点, Vercel/Netlify 前端部署]
  input: [切片定义, 接口契约（组件 props/API 响应类型）, 禁区清单, 验证命令]
  output: [改动文件清单, 构建/测试原始输出, 自审结论, 冲突标记]
  forbidden: [流程决策, 后端业务规则实现, 数据库 schema（找对应后端专家）, CI/监控细节（找 deploy-ops）]
---

# Web + React 技术规范

## 两种项目形态，先确认是哪一种

| 形态 | 信号 | 结构 |
|---|---|---|
| SPA（Vite） | 纯前端、后端是独立 API、无 SEO 需求 | Vite + React |
| 全栈（Next.js） | 要 SSR/SEO、前后端一个仓库、部署 Vercel | Next.js App Router |

派工单里必须写清是哪种，组件的写法不一样。

## 项目结构（Next.js App Router）

```
项目根/
├── app/
│   ├── layout.tsx          # 根布局
│   ├── page.tsx            # 首页
│   └── (feature)/          # 按功能分组的路由
│       └── todos/
│           ├── page.tsx    # 服务端组件，取数
│           └── actions.ts  # server actions（写操作）
├── components/             # 展示组件，默认服务端组件
│   └── todos/
├── lib/
│   ├── api.ts              # 客户端 fetch 封装（错误信封处理）
│   └── types.ts            # 共享类型（与后端契约对齐）
├── public/
└── .env.example            # NEXT_PUBLIC_ 开头的环境变量模板
```

SPA 形态把 `app/` 换成 `src/`，入口 `src/main.tsx`，路由用 react-router。

## 组件约定

- 函数式组件 + hooks，不用 class。
- 组件文件只放 UI；数据获取放 page/loader，写操作放 actions 或 api 层，组件不直接 fetch。
- props 用 type 声明，不用 any；跨层共享类型放 `lib/types.ts`（与后端契约对齐，单一来源）。
- 列表 key 用稳定 id，不用 index。

## 状态管理（按复杂度选，别一上来 Redux）

| 场景 | 选什么 |
|---|---|
| 组件自己用 | useState / useReducer |
| 跨两三层传 | props 或 context |
| 全局共享状态（用户信息、主题） | Zustand（默认推荐，最省事） |
| 服务端数据缓存 | TanStack Query（SWR/React Query），别用 useState 手搓缓存 |

原则：**服务端数据优先用 Query 类库管**——它们自带 Loading/Error/Stale 状态，正好是六种产品状态的地基。

## API 调用

- 统一走 `lib/api.ts` 封装：baseURL、错误信封解构、超时设置集中一处。
- 每个请求必须有 Loading 和 Error 的 UI 落点（见 `references/02-postflight/product-states.md`），不允许裸 fetch 后 setState。
- 环境变量里 API 地址用 `NEXT_PUBLIC_` 前缀，**不许硬编码 localhost**——发布检查会查这个。

## 样式

- 默认 Tailwind（最快、和 Vercel 生态最配）；复杂设计系统再考虑 CSS Modules。
- 颜色/间距用设计 token，不散落魔法数字。
- 深色模式等"待验证假设"功能，MVP 阶段不做（见 PROJECT.md 的假设清单）。

## 部署（Vercel）

- 生产构建命令 `next build` / `vite build`，Vercel 自动识别。
- 环境变量在 Vercel 项目设置里配，`.env.local` 只进开发机，不进仓库。
- 自定义域名 + HTTPS 在 Vercel 控制台开；国内访问速度要看用户实际分布。
- 部署后必须从生产 URL 走一遍主链路（release-gate 强制项），本地跑通不算。

## 常见坑

1. **水合错误（Hydration mismatch）**：服务端/客户端渲染不一致，常见原因是渲染了 `Date.now()`、`window` 对象、随机数。这类值放 useEffect 里取。
2. **"use client" 泛滥**：整个页面标成客户端组件，SSR 好处全无。默认服务端组件，只把交互叶子标 client。
3. **SPA 直接发请求给第三方 API**：key 暴露在前端。需要保密的调用走 Next.js route handler / server action 代理。
4. **CORS 怪罪前端**：跨域是后端中间件问题，前端先查 api.ts 的 baseURL 对不对，再找后端专家加 CORS 头。
5. **构建通过但线上白屏**：base 路径、环境变量、路由模式（history vs hash）三者之一配错，从生产 URL 排查。

## 命令

- 安装：`npm install`
- 开发：`npm run dev`
- 构建：`npm run build`
- 本地预览生产构建：`npm run start`
- 测试：`npm test`

## 什么时候不用这个专家

- 需要桌面壳（去 ts-react-electron）
- 重后端逻辑（配 python-fastapi）
- 要离线/读本地文件（Electron 比 Web 合适）
