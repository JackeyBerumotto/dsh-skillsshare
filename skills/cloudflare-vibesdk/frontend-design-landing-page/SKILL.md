---
name: frontend-design-landing-page
description: >
  Cloudflare VibeSDK 风格的营销转化页设计参考。奶油底色、大留白、
  胶囊 CTA、柔和阴影，打造高转化率的品牌落地页。适用 SaaS、产品
  展示、活动注册等场景。 | Marketing conversion page design reference in the Cloudflare VibeSDK style. Cream background colors, generous white space, pill-shaped CTAs, and soft shadows create high-conversion brand landing pages. Suitable for SaaS, product showcases, event registration, and similar scenarios.
metadata:
  source: cloudflare/vibesdk
  design_vocabulary: "奶油底色 · 大留白 · 胶囊 CTA · 柔和阴影 · 暖色调"
  accessibility: WCAG AA
---

# Frontend Design — Landing Page (Marketing Conversion)

基于 Cloudflare VibeSDK 的设计语言，为营销转化页提供视觉参考。

## 设计基调

- **底色**：奶油色 / 暖白 (#FDF8F0 ~ #FFF8E7)，营造温暖、亲和的品牌氛围
- **留白**：大量垂直留白，section 间距 120–160px，内边距 64–80px
- **CTA**：胶囊形状（border-radius: 9999px），主色鲜明，带悬停微动效
- **阴影**：柔和、大偏移的阴影（`box-shadow: 0 20px 60px -12px rgba(0,0,0,0.08)`）
- **字体**：无衬线展示字体（如 Inter / Satoshi）+ 正文系统字体，字号对比强烈

## 页面结构

```
┌─────────────────────────────────────┐
│  ▲ Hero Section                     │
│  大标题 (3.5–4.5rem) + 副标题 + CTA  │
│  背景可加 subtle 纹理或渐变           │
├─────────────────────────────────────┤
│  ■ Social Proof / Logo Cloud        │
│  客户/合作伙伴 Logo 行               │
├─────────────────────────────────────┤
│  ◆ Features (3 列 bento grid)       │
│  图标 + 标题 + 简述                  │
├─────────────────────────────────────┤
│  ★ Testimonial / Case Study         │
│  大引用 + 头像 + 数据亮点            │
├─────────────────────────────────────┤
│  ▼ Pricing / FAQ (可选)             │
│  简洁卡片式，胶囊 CTA 重复出现       │
├─────────────────────────────────────┤
│  ● Footer                           │
│  极简，仅必要链接                   │
└─────────────────────────────────────┘
```

## 色彩体系

| 角色       | 色值      | 用途               |
|-----------|-----------|--------------------|
| 背景主色   | #FDF8F0   | 页面底色            |
| 背景强调   | #FFF8E7   | 交替区块            |
| 主色       | 暖色系    | CTA / 链接          |
| 文字主色   | #1A1A2E   | 标题                |
| 文字次要   | #6B6B80   | 正文 / 说明         |
| 边框       | #E8E4D8   | 卡片 / 分割线        |

## 动效原则

- CTA 悬停：`scale(1.02)` + 阴影加深，`transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1)`
- 滚动触发 fade-in-up，交错 80ms 延迟
- 避免闪烁、旋转、弹跳等干扰性动画
- 所有动效尊重 `prefers-reduced-motion`

## 反模式 (Don'ts)

- ❌ 深色背景 + 霓虹渐变（不是 VibeSDK 风格）
- ❌ 毛玻璃效果（glassmorphism）
- ❌ 过度装饰的 Hero 指标数字（01/02/03 编号）
- ❌ 多个不同颜色的 CTA 按钮竞争注意力
- ❌ 自动播放视频/轮播

## 参考来源

- [Cloudflare VibeSDK](https://github.com/cloudflare/vibesdk) — 设计语言与组件模式
- Stripe 营销页 — 留白与 CTA 布局参考
- Linear 品牌页 — 字体与间距系统参考