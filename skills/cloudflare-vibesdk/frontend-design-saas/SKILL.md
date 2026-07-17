---
name: frontend-design-saas
description: >
  Cloudflare VibeSDK 风格的 SaaS 仪表盘设计参考。Stripe / Linear / Vercel
  极简专业风，WCAG AA+ 无障碍标准，数据密度与视觉清晰度平衡。
metadata:
  source: cloudflare/vibesdk
  design_vocabulary: "极简专业 · 数据密度 · WCAG AA+ · 浅色主题 · 克制色彩"
  accessibility: WCAG AA+
---

# Frontend Design — SaaS Dashboard

基于 Cloudflare VibeSDK 的设计语言，为 SaaS 仪表盘提供视觉参考。

## 设计基调

- **底色**：纯白 (#FFFFFF) 或极浅灰 (#F9FAFB)，干净、专业
- **侧边栏**：窄侧边栏 (240–260px)，图标 + 文字标签，活跃态高亮
- **数据密度**：紧凑但可读，行高 1.5，内边距 16–20px
- **色彩克制**：品牌色仅用于关键交互元素，数据可视化用语义色
- **无障碍**：AA+ 对比度（文本 ≥ 4.5:1，大文本 ≥ 3:1）

## 页面结构

```
┌──────────┬──────────────────────────────────────┐
│ Sidebar  │  ▲ Top Bar (搜索 + 通知 + 头像)        │
│ 240px    │                                        │
│          │  ◆ Stats Row (4 KPI 卡片)              │
│ Logo     │  数字 + 标签 + 趋势指示器               │
│          │                                        │
│ 导航      │  ■ Main Content Area                  │
│ · 仪表盘  │  表格 / 图表 / 列表                    │
│ · 分析    │  可排序 / 可筛选 / 分页                │
│ · 设置    │                                        │
│ · 用户    │  ★ Recent Activity (右侧面板, 可选)    │
│          │                                        │
└──────────┴──────────────────────────────────────┘
```

## 色彩体系

| 角色       | 色值      | 对比率   | 用途               |
|-----------|-----------|---------|--------------------|
| 背景       | #FFFFFF   | —       | 主内容区            |
| 表面       | #F9FAFB   | —       | 侧边栏 / 卡片       |
| 边框       | #E5E7EB   | —       | 分割线              |
| 文字主色   | #111827   | 17.5:1  | 标题 / 表格头       |
| 文字次要   | #6B7280   | 5.2:1   | 标签 / 说明         |
| 品牌色     | 蓝色系    | ≥ 4.5:1 | CTA / 链接 / 活跃态 |
| 成功       | #059669   | —       | 正向指标            |
| 警告       | #D97706   | —       | 中等指标            |
| 错误       | #DC2626   | —       | 负向指标            |

## 组件规范

### KPI 卡片
- 背景白，边框 1px solid #E5E7EB，圆角 12px
- 标题 14px/500，数值 28px/700，趋势徽章 12px
- 趋势向上 / 向下用语义色 + 方向箭头

### 数据表格
- 表头 13px/600，行 14px/400，hover 行高亮 (#F9FAFB)
- 斑马纹可选，但非必须
- 分页在底部，简洁

### 图表
- 折线图 / 柱状图为主，无 3D 效果
- 网格线极浅 (#F3F4F6)，坐标轴标签 12px
- 图例在图表上方，水平排列

### 按钮
- 主要：品牌色填充，圆角 8px，padding 10px 20px
- 次要：白色 + 边框，hover 变色
- 危险：红色，仅用于删除等确认操作

## 无障碍要求 (WCAG AA+)

- 所有文本对比度 ≥ 4.5:1 (大文本 ≥ 3:1)
- 交互元素 focus 可见 (2px outline + 2px offset)
- 颜色不单独传达信息（辅以图标/文字）
- 表单 label 关联，错误提示清晰
- 支持键盘导航：Tab / Enter / Escape / Arrow

## 反模式 (Don'ts)

- ❌ 深色仪表盘（除非用户明确要求）
- ❌ 多个数据可视化类型混搭在一个视图
- ❌ 品牌色过度使用（按钮、链接、图标全用同色）
- ❌ 无意义的动效 / 加载动画
- ❌ 信息密度过高（行高 < 1.4，无视觉分组）

## 参考来源

- [Cloudflare VibeSDK](https://github.com/cloudflare/vibesdk) — 设计语言与组件模式
- [Stripe Dashboard](https://dashboard.stripe.com) — 表格与 KPI 布局参考
- [Linear App](https://linear.app) — 侧边栏与交互细节参考
- [Vercel Dashboard](https://vercel.com/dashboard) — 数据展示参考