---
name: ui-polish
description: UI 设计工艺专家 pack。当界面"能看但廉价"——圆角不同心、对齐差像素、动效生硬、色彩发脏、排版失衡——需要把 UI 从 demo 相打磨到产品相时使用。vendored from jakubkrehel/skills（MIT）。
contract:
  owns: [UI 工艺规则（圆角/阴影/表面深度）, 光学对齐, 动效数值（时长/曲线/缩放）, 字体排版工艺, 色彩体系与对比度, 布局分组与间距节奏, 可访问性底线（焦点/命中区/ARIA）, UI 评审清单]
  input: [切片定义, 接口契约（组件 props/API 响应类型）, 禁区清单, 验证命令]
  output: [改动文件清单, 构建/测试原始输出, 自审结论, 冲突标记]
  forbidden: [流程决策, 需求澄清, 后端业务规则实现（找对应后端专家）, 打包部署细节（找 deploy-ops）]
---

# UI 工艺专家（ui-polish pack）

本 pack 是一个可安装 skill 合集（vendored from [jakubkrehel/skills](https://github.com/jakubkrehel/skills)，MIT License，见 `vendor/LICENSE`），把界面从"能跑"打磨到"产品相"。**所有数值都是精确值，不是近似范围**——`cubic-bezier(0.2, 0, 0, 1)` 不是 `cubic-bezier(0.4, 0, 0.2, 1)`，`0.96` 不是 `0.95`，照抄即可。

## 与 ui-design-baseline 的分层

| 层 | 文件 | 管什么 |
|---|---|---|
| 底线 | `references/00-preflight/ui-design-baseline.md` | 别白得发光：字号阶梯、间距节奏、色彩 token、布局层级——不过线打回 |
| 工艺 | 本 pack | 过了底线之后的精度：同心圆角、光学对齐、精确动效、字体工艺、对比度、评审清单 |

基线管"不及格"，本 pack 管"不精致"。两个都要过。

## 内部路由：按信号选 vendored 专家

| 信号 | 读哪个 |
|---|---|
| 圆角/阴影/表面深度/边框/图片描边 | `vendor/better-ui/SKILL.md`（深入：surfaces.md） |
| 动效/过渡/入场退场/图标切换/性能 | `vendor/better-ui/SKILL.md`（深入：animations.md / enter-exit.md / icon-transitions.md / performance.md） |
| 图标（描边粗细/currentColor/状态） | `vendor/better-ui/SKILL.md`（深入：icons.md） |
| 字体选择/字号行高/字距/数字对齐/换行 | `vendor/better-typography/SKILL.md` |
| 色彩体系/色板生成/token 命名/对比度 | `vendor/better-colors/SKILL.md` |
| 分组/对齐/区块间距/断点/自适应 | `vendor/better-layout/SKILL.md` |
| 焦点管理/键盘支持/命中区/ARIA/减少动态 | `vendor/better-accessibility/SKILL.md` |
| UI 整体评审/交付前检查 | `vendor/better-interface/SKILL.md`（评审格式见 review-format.md） |

派工单涉及 UI 打磨时，把上表对应的 SKILL.md 路径写进派工单的"专家知识"项。多信号同时命中（比如"按钮又丑又难用"同时命中 better-ui 和 better-accessibility）就都带上，两个专家不冲突：一个管观感一个管可用。

## 使用规则

1. **先过基线再过工艺**：ui-design-baseline 的最小检查五条不过，别谈打磨。
2. **尊重项目现有约定**：沿用项目的组件库、token、密度和动效语言，本 pack 的规则只在规则明确规定了精确交互时覆盖项目约定。
3. **动效必须有静态线索兜底**：颜色、图标或标签——动效永远不是唯一的反馈通道（可访问性红线）。
4. **数值照抄**：规则里写死的值（0.96、150ms、cubic-bezier(0.2, 0, 0, 1)、1px @ oklch 10%）直接用在评审意见里，不要"大约"。
5. 评审 UI 时先"慢放"：以 10% 速度感觉哪里不对，那就是全速下细微的错。

## 什么时候不用这个专家

- 纯后端切片、CLI 工具——没有界面
- 项目设计语言已成熟且只做功能性小改（跟项目约定走，别引新规范）
- 只要功能验证的一次性原型（底线仍要过：能看，不是白得发光）
