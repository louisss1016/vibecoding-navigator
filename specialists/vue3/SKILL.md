---
name: vue3
description: Vue 3 + Vite + Pinia + Element Plus + Vitest 栈的技术专家。当项目是纯 Web 应用、用 Vue 3 做前端、用 Vite 构建、用 Pinia 管理状态时使用。
contract:
  owns: [Vue 3 SFC 与组合式 API, 组件通信（props/emits/provide-inject）, Pinia 状态管理, Vue Router, Element Plus 使用与按需引入, Vitest/Vue Test Utils 测试组织]
  input: [切片定义, 接口契约（组件 props/API 响应类型）, 禁区清单, 验证命令]
  output: [改动文件清单, 构建/测试原始输出, 自审结论, 冲突标记]
  forbidden: [流程决策, 后端业务规则实现, 数据库 schema（找对应后端专家）, nginx/CI/监控细节（找 deploy-ops）]
---

# Vue 3 + Vite 技术规范

## 项目结构（推荐）

```
项目根/
├── index.html
├── vite.config.ts          # 构建配置（别名、代理、按需插件）
├── tsconfig.json
├── src/
│   ├── main.ts             # createApp 入口，挂载插件（router/pinia/element-plus）
│   ├── App.vue             # 根组件
│   ├── router/
│   │   └── index.ts        # Vue Router 4，路由表 + 导航守卫
│   ├── stores/             # Pinia，一个 store 一个文件
│   │   └── user.ts
│   ├── api/                # 请求层，一个模块一组接口（axios 实例）
│   │   └── todo.ts
│   ├── components/         # 通用组件
│   ├── views/              # 页面级组件，按路由分组
│   ├── types/              # 共享类型（与后端契约对齐）
│   ├── utils/
│   └── styles/             # 全局样式 + scss 变量
├── tests/ 或 src/**/*.spec.ts   # Vitest
└── .env.example            # VITE_ 前缀环境变量模板
```

- **只用 Vue 3 语法**：`<script setup>` + 组合式 API。项目里不许混 Vue 2 写法（选项式 API、`this.$set`、filter）——见常见坑第 2 条。
- 上 TypeScript：`defineProps<{...}>()` 泛型声明 props，不用运行时数组写法。

## 组件约定

- 单文件组件三块顺序：`<script setup>` → `<template>` → `<style scoped>`。
- props 单向数据流：组件**不许直接改 props**，要改就走 `emit('update:modelValue', v)` 或让父组件传新值。
- 组件通信按距离选：父传子 props / 子传父 emits / 跨层 provide-inject / 全局 Pinia。别祖孙三代还靠 props 层层透传。
- `v-for` 必须绑稳定 key（数据 id），**禁用 index 当 key**——列表中间插入/删除时 DOM 会错位复用。
- 模板里不放业务逻辑：复杂判断抽成 computed 或 composable（`src/composables/`）。

## 状态管理（Pinia）

- 全局共享状态（用户信息、权限、主题）才进 Pinia；组件自己用的状态放 `ref`。
- **服务端数据不塞 Pinia 当缓存**：接口数据要么请求时取、用时渲染（简单场景），要么用 VueQuery 这类请求库管 Loading/Error/缓存。Pinia 里手搓一份服务端数据副本 = 早晚和库里的不一致。
- store 用 setup 风格（`defineStore('user', () => {...})`），和组合式 API 心智一致。
- 解构 store 会丢响应式——要么 `storeToRefs(store)`，要么不结结构直接用 `store.xxx`（Pinia 的 getter 可以直接点）。

## API 调用

- 统一走 `api/` 下的 axios 实例：baseURL 从环境变量读、请求/响应拦截器集中处理错误信封和 401 跳登录。
- 每个请求必须有 Loading 和 Error 的 UI 落点（见 `references/02-postflight/product-states.md`），不允许请求后裸 setState。
- `VITE_` 前缀的环境变量**会打进客户端包**——API 密钥类机密不许放这里，和 Next 的 `NEXT_PUBLIC_` 一个道理。

## UI 组件库（Element Plus）

- 国内业务系统默认 Element Plus；引入走 `unplugin-vue-components` + `unplugin-auto-import` 按需自动引入，**禁止 main.ts 全量 import**——全量引入打包体积多一大截。
- 表单：`el-form` + `rules` 声明式校验，别手写一堆 if-else 判断。
- 表格：`el-table` 数据量大时用后端分页，别一次拉全表前端分页。

## 路由（Vue Router 4）

- history 模式；权限路由在导航守卫里集中拦（登录态 + 角色），别在每个页面组件里各判一遍。
- 路由懒加载：`() => import('../views/xxx.vue')`，首包别吞全部页面。

## 测试（Vitest + Vue Test Utils）

- 组件测试：`@vue/test-utils` 挂载 + 断言 DOM 文本/交互，重点测条件渲染和 emit。
- 纯逻辑（composable、工具函数、store）直接单测，不起组件。
- E2E 用 Playwright（跨栈通用，路由表里 Playwright 信号归 ts-react-electron pack 的 playwright-expert）。

## 命令

- 安装：`npm install`
- 开发：`npm run dev`
- 构建：`npm run build`
- 本地预览生产构建：`npm run preview`
- 测试：`npm run test`（Vitest）
- 单文件：`npx vitest run src/stores/user.spec.ts`

## 常见坑

1. **解构丢响应式**：`const { count } = reactive({...})` 之后改原对象，`count` 不更新—— reactive 解构出来的是快照。用 `toRefs()`；store 用 `storeToRefs()`。
2. **Vue 2 思维写 Vue 3**：选项式 API 和组合式 API 混在一个项目、还在用 `this.$set` / filter / `$listeners`。Vue 3 没有这些——统一 `<script setup>`，透传用 `attrs`，过滤用 computed/method。
3. **直接改 props**：`props.title = 'x'` 控制台直接报警告且数据不同步。子组件要改父组件的数据，emit 事件让父组件改。
4. **history 模式刷新 404**：`createWebHistory` 下 `/todos` 深链接直打/刷新，nginx 没配 `try_files ... /index.html` 就 404。这是部署问题，但根子在路由模式——找 deploy-ops 配 fallback。
5. **Element Plus 全量引入**：`app.use(ElementPlus)` 一把梭，打包多出几 MB。按需引入插件配一次，收益永久。
6. **`VITE_` 变量当保险箱**：以为环境变量就是后端的机密——`VITE_` 开头的全都会打进前端包，任何人 devtools 可见。机密一律后端持有。
7. **nextTick 当同步**：改完 ref 立刻读 DOM 拿到旧值——Vue 的 DOM 更新是异步批处理的。要读更新后的 DOM，`await nextTick()`。
8. **watch 默认不深度**：监听 reactive 对象，深层属性变化不触发。要么 `{ deep: true }`，要么监听具体属性；初始化就要执行的用 `immediate: true`。

## 什么时候不用这个专家

- React / Next.js 项目（去 web-react）
- 桌面壳（去 ts-react-electron）
- 重后端逻辑（配 java-spring / python-fastapi）
- nginx / CI / 监控 / 回滚（去 deploy-ops）
