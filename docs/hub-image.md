# 枢纽场景（Hub）图片资源清单

> 供 AI 图片生成工具统一批量生成，所有图片存放于 `assets/images/hub/`

## 全局风格约束

- **主题**: 赛博朋克地下避难所 / 末世废土科技感
- **色调**: 暗色为主（深紫 #0F0A14、深蓝黑 #0A0A12），霓虹红 (#B71212 / #D91F1F) 作为点缀
- **画风**: 半写实概念艺术风格，带有颗粒质感与微弱光源，与主菜单风格统一
- **格式**: PNG（透明背景除非特别说明）
- **通用负面提示词**: no text, no watermark, no signature, no frame border, no UI elements

---

## 1. 场景背景

| 字段 | 值 |
|------|-----|
| **文件名** | `bg_hub.png` |
| **尺寸** | 1080 × 1920 (竖屏，9:16) |
| **用途** | Hub 场景全屏背景，替代当前纯色 ColorRect |
| **提示词** | `Underground cyberpunk bunker interior, wide view of a dimly lit subterranean command center, metal walls with exposed pipes and cables, faint neon red and purple glow from scattered monitors, concrete floor with metal grating, industrial atmosphere, dark ambient lighting, concept art style, grainy texture, dark purple and deep blue tones, no characters` |
| **透明背景** | 否（需要完整背景） |

---

## 2. 顶栏资源图标（4 个）

通用样式：简约图标风格，单色霓虹线条 + 微弱发光效果，深色透明背景。

| 文件名 | 尺寸 | 对应资源 | 提示词 |
|--------|------|----------|--------|
| `icon_bio_electricity.png` | 64 × 64 | 生物电 | `Minimalist cyberpunk icon, glowing bio-electric lightning bolt symbol, neon cyan-green glow, thin line art style, dark transparent background, flat icon design` |
| `icon_nano_alloy.png` | 64 × 64 | 纳米合金 | `Minimalist cyberpunk icon, hexagonal nano-alloy metal ingot symbol, neon silver-blue glow, thin line art style, dark transparent background, flat icon design` |
| `icon_hashrate.png` | 64 × 64 | 算力 | `Minimalist cyberpunk icon, digital processor chip with circuit lines symbol, neon purple glow, thin line art style, dark transparent background, flat icon design` |
| `icon_mental_power.png` | 64 × 64 | 精神力 | `Minimalist cyberpunk icon, psychic brain wave ripple symbol, neon magenta-pink glow, thin line art style, dark transparent background, flat icon design` |

---

## 3. 设施卡片插画（6 个）

用于设施槽卡片左侧或背景，展示设施的视觉概念。

通用样式：横版卡片插画，赛博朋克工业风，暗色调，左侧留空间放文字叠加。

| 文件名 | 尺寸 | 设施 | 提示词 |
|--------|------|------|--------|
| `facility_reactor.png` | 480 × 120 | 维生反应堆 | `Cyberpunk underground bio-reactor, glowing green energy tubes and containment vessels, pulsing organic fluid, dark industrial bunker setting, concept art, horizontal banner composition, dark left side fading to detailed right side, moody lighting` |
| `facility_recruit.png` | 480 × 120 | 神经接入舱 | `Cyberpunk neural interface pod, person-sized capsule with holographic brain scan display, cables and electrodes, dark underground lab, concept art, horizontal banner composition, dark left side fading to detailed right side, eerie blue glow` |
| `facility_clinic.png` | 480 × 120 | 义体诊所 | `Cyberpunk prosthetics clinic, surgical table with mechanical arms and cybernetic limbs on display, sterile white-blue light in dark room, concept art, horizontal banner composition, dark left side fading to detailed right side, medical equipment` |
| `facility_market.png` | 480 × 120 | 黑市终端 | `Cyberpunk black market terminal, holographic trade interface with floating price tags, shady underground bazaar, neon red and orange signs, concept art, horizontal banner composition, dark left side fading to detailed right side, secretive atmosphere` |
| `facility_forge.png` | 480 × 120 | 纳米锻造间 | `Cyberpunk nano-forge workshop, anvil-like fabrication platform with particle beams assembling a weapon, sparks and molten metal glow, dark industrial room, concept art, horizontal banner composition, dark left side fading to detailed right side, orange-yellow highlights` |
| `facility_data_lab.png` | 480 × 120 | 数据解析室 | `Cyberpunk data analysis lab, multiple holographic screens showing encrypted data streams, server racks with blinking lights, dark room with purple and cyan glow, concept art, horizontal banner composition, dark left side fading to detailed right side` |

---

## 4. 设施状态遮罩 / 叠加图（2 个）

| 文件名 | 尺寸 | 用途 | 提示词 |
|--------|------|------|--------|
| `overlay_locked.png` | 480 × 120 | 未解锁设施的暗色锁定遮罩 | `Dark semi-transparent overlay with a faint padlock icon in center, digital glitch effect on edges, cyberpunk style, subtle red warning glow, mostly opaque dark layer` |
| `overlay_unbuilt.png` | 480 × 120 | 已解锁但未建造的蓝图样式 | `Semi-transparent blueprint wireframe overlay, cyan-blue grid lines and dotted outlines suggesting construction plan, holographic projection style, dark background` |

---

## 5. 底栏导航图标（5 个）

通用样式：简约填充图标，适配按钮内嵌使用，带微弱发光。

| 文件名 | 尺寸 | 按钮 | 提示词 |
|--------|------|------|--------|
| `nav_hub.png` | 48 × 48 | 枢纽 | `Minimalist icon, underground bunker shelter symbol, flat design, neon red outline glow, dark transparent background` |
| `nav_team.png` | 48 × 48 | 队伍 | `Minimalist icon, three person silhouette group symbol, flat design, neon red outline glow, dark transparent background` |
| `nav_growth.png` | 48 × 48 | 成长 | `Minimalist icon, upward arrow with star level-up symbol, flat design, neon red outline glow, dark transparent background` |
| `nav_expedition.png` | 48 × 48 | 探索 | `Minimalist icon, compass or map waypoint symbol, flat design, neon red outline glow, dark transparent background` |
| `nav_settings.png` | 48 × 48 | 设置 | `Minimalist icon, gear cog symbol, flat design, neon red outline glow, dark transparent background` |

---

## 6. 产出结算浮层素材（3 个）

用于设施产出汇总通知浮层（非阻塞，3 秒自动消失），覆盖在 Hub 页面上方。

| 文件名 | 尺寸 | 用途 | 提示词 |
|--------|------|------|--------|
| `toast_production_bg.png` | 512 × 128 | 产出浮层背景纹理（9-patch 拉伸） | `Dark cyberpunk UI notification panel texture, semi-transparent deep purple-black gradient, subtle circuit board trace patterns with faint red glow along edges, horizontal banner shape, futuristic HUD overlay style, clean minimal surface, grainy texture, suitable for 9-slice scaling, no text, no watermark` |
| `toast_production_divider.png` | 400 × 8 | 浮层标题与内容之间的分割线 | `Futuristic horizontal divider line, thin glowing red-orange center fading to transparent on both ends, tiny data node dots scattered along the line, cyberpunk sci-fi UI separator element, dark transparent background, no text` |
| `toast_production_frame.png` | 512 × 128 | 浮层外框光效装饰（叠加在背景上） | `Cyberpunk notification border frame, thin neon red edge glow lines with energy pulse accents at corners, subtle electric arc effect along top edge, dark transparent interior, holographic tech style, suitable for 9-slice scaling, no text, no watermark` |

---

## 7. 装饰元素

| 文件名 | 尺寸 | 用途 | 提示词 |
|--------|------|------|--------|
| `divider_hub.png` | 600 × 16 | 设施列表标题下方分隔装饰线 | `Cyberpunk horizontal divider line, thin glowing red neon line with circuit board pattern at center, fading to transparent on both ends, dark background` |
| `card_frame.png` | 480 × 120 | 设施卡片边框（9-patch 拉伸） | `Cyberpunk card border frame, thin red neon edge lines with corner accents, dark semi-transparent interior, tech circuit detail at corners, suitable for 9-slice scaling` |
| `vignette_overlay.png` | 1080 × 1920 | 全屏暗角叠加层，增加景深感 | `Dark vignette overlay, black edges fading to transparent center, oval gradient, subtle film grain texture` |

---

## 文件汇总

```
assets/images/hub/
├── bg_hub.png                  # 1080×1920  场景背景
├── icon_bio_electricity.png    # 64×64      生物电图标
├── icon_nano_alloy.png         # 64×64      纳米合金图标
├── icon_hashrate.png           # 64×64      算力图标
├── icon_mental_power.png       # 64×64      精神力图标
├── facility_reactor.png        # 480×120    维生反应堆
├── facility_recruit.png        # 480×120    神经接入舱
├── facility_clinic.png         # 480×120    义体诊所
├── facility_market.png         # 480×120    黑市终端
├── facility_forge.png          # 480×120    纳米锻造间
├── facility_data_lab.png       # 480×120    数据解析室
├── overlay_locked.png          # 480×120    锁定遮罩
├── overlay_unbuilt.png         # 480×120    未建造蓝图遮罩
├── nav_hub.png                 # 48×48      导航-枢纽
├── nav_team.png                # 48×48      导航-队伍
├── nav_growth.png              # 48×48      导航-成长
├── nav_expedition.png          # 48×48      导航-探索
├── nav_settings.png            # 48×48      导航-设置
├── toast_production_bg.png     # 512×128    产出浮层背景(9-patch)
├── toast_production_divider.png # 400×8     产出浮层分割线
├── toast_production_frame.png  # 512×128    产出浮层外框光效(9-patch)
├── divider_hub.png             # 600×16     分隔装饰线
├── card_frame.png              # 480×120    卡片边框(9-patch)
└── vignette_overlay.png        # 1080×1920  暗角叠加层
```

共计 **24** 张图片。
