# 队伍页面 & 角色成长页 UI 图片资源规格与 AI 生成提示词

> 目标：为队伍编成页面和角色成长页生成 UI 图片素材，放入对应目录后即可运行。
> 角色头像 `*_avatar.png` 和全身立绘 `*_full.png` 已在 `docs/character/` 中单独描述并已生成。
> 注意：角色详情页已合并到成长页（growth_panel），点击队伍中角色会跳转到成长Tab。

---

## 全局风格要求

- **游戏类型：** 末日废土 × 赛博朋克 × 克苏鲁恐怖 Roguelite
- **色彩基调：** 极暗底色（接近纯黑）+ 暗红色主色调 + 暖米色文字
- **核心色板：**
  - 背景黑 `#0A0A12`
  - 血红强调 `#B81212`
  - 暗红边框 `#A61414`
  - 亮红高光 `#F23333`
  - 暖米文字 `#F0EBD9`
  - 稀有度绿(R) `#4DB84D` / 蓝(SR) `#4D80E6` / 橙(SSR) `#CC801A`
- **画面方向：** 竖版 720×1280（手机竖屏）
- **风格参考：** Darkest Dungeon 的压抑氛围 + 明日方舟/少女前线 UI 设计

---

## ① team_bg.png — 队伍页面背景

| 属性       | 值                                                |
| ---------- | ------------------------------------------------- |
| **文件名** | `assets/images/team/team_bg.png`                  |
| **尺寸**   | 720 × 1280 px                                    |
| **格式**   | PNG 或 JPG                                        |
| **用途**   | 队伍编成页面全屏背景，StretchMode=KEEP_ASPECT_COVERED |

### AI 提示词（English）

```
Dark underground military bunker interior, vertical portrait composition 9:16 aspect ratio, dimly lit war room with concrete walls covered in tactical maps and old faded blueprints pinned with red string, a large scratched metal table in the center with holographic tactical display casting faint red light upward, scattered ammunition crates and equipment racks along the walls, exposed industrial pipes and cables running across the low ceiling with flickering red emergency lights, dust particles floating in the sparse red light beams, the overall image very dark with emphasis on shadows, subtle dark red and orange accent lighting from screens and warning lights, cyberpunk military underground base aesthetic, post-apocalyptic bunker atmosphere, muted desaturated palette dominated by near-black dark grays cold steel blues and selective dark red highlights, digital concept art style, no characters no people, 720x1280
```

### AI 提示词（中文）

```
暗黑地下军事掩体内部，竖版构图9:16比例，昏暗的作战指挥室混凝土墙面钉满战术地图和褪色蓝图用红线连接，中央一张刮痕斑驳的金属桌面上有全息战术投影散发微弱红光，墙边散落弹药箱和装备架，低矮天花板上暴露的工业管道和电缆配闪烁的红色应急灯，稀疏红色光束中飘浮灰尘粒子，整体画面极暗强调阴影，屏幕和警告灯提供微弱暗红色和橙色环境光，赛博朋克地下军事基地美学，末日掩体氛围，近乎纯黑的深灰+冷钢蓝+暗红点缀的去饱和色调，数字概念艺术风格，不包含人物角色
```

### 负面提示词

```
people, characters, text, watermark, bright colors, daylight, sunshine, clean modern interior, happy mood, cartoon style, low quality, blurry
```

---

## ② card_slot_bg.png — 角色卡槽底图

| 属性       | 值                                                 |
| ---------- | -------------------------------------------------- |
| **文件名** | `assets/images/team/card_slot_bg.png`              |
| **尺寸**   | 640 × 100 px                                      |
| **格式**   | PNG（透明背景）                                    |
| **用途**   | 队伍列表中每个角色卡的背景底板，头像叠在左侧      |
| **构图**   | 横向矩形，左侧留出100px方形区域放头像，微圆角2px  |

### AI 提示词（English）

```
Dark futuristic UI card background panel, horizontal rectangular shape 640x100 pixels, transparent background outside the card, very dark blue-gray metallic base (#14141E) with thin dark red border lines (#A61414) on top and bottom edges, left side has a slightly brighter 100x100 square inset area outlined with a thin red border for avatar placement, subtle hexagonal circuit pattern faintly etched into the surface, small angular tech decorations at the right corners, a faint horizontal dark red gradient stripe running across the middle of the card from left to right fading out, cyberpunk HUD military roster aesthetic, clean minimal dark design, no text no icons no characters, PNG with alpha transparency
```

### AI 提示词（中文）

```
深色未来感UI角色卡背景面板，横向矩形640x100像素，外部透明，极深蓝灰金属底色(#14141E)+上下边缘细暗红边框线(#A61414)，左侧有略亮的100x100方形内嵌区域红色细边框用于放置头像，表面微弱六边形电路纹理蚀刻，右侧角落小型棱角科技装饰，中间有微弱的暗红色水平渐变条纹从左向右渐隐，赛博朋克HUD军事花名册美学，干净极简暗色设计，不包含文字图标人物，PNG透明底
```

### 负面提示词

```
text, icons, characters, 3D, glossy, bright colors, rounded, shadow, complex patterns
```

---

## ③ card_slot_empty.png — 空卡槽占位图

| 属性       | 值                                                |
| ---------- | ------------------------------------------------- |
| **文件名** | `assets/images/team/card_slot_empty.png`          |
| **尺寸**   | 640 × 100 px                                     |
| **格式**   | PNG（透明背景）                                   |
| **用途**   | 队伍中未填充的空位，虚线边框+加号提示             |
| **构图**   | 与card_slot_bg相同尺寸，虚线边框，中央有加号符号  |

### AI 提示词（English）

```
Dark empty UI card slot placeholder, horizontal rectangular shape 640x100 pixels, transparent background, dashed thin dark red border lines (#A61414 at 50% opacity) forming the outline of the card, a small plus sign (+) icon in the center made of thin dark red lines, very subtle dark hexagonal grid pattern barely visible in the background fill (#14141E at 30% opacity), minimalist cyberpunk placeholder aesthetic, muted and subdued indicating an empty available slot, no text besides the plus symbol, no other icons, PNG with alpha transparency
```

### AI 提示词（中文）

```
深色空置UI卡槽占位图，横向矩形640x100像素，透明背景，暗红色虚线细边框(#A61414 50%透明度)勾勒卡片轮廓，中央有暗红色细线条组成的小加号(+)图标，极微弱的深色六边形网格纹理作为底纹(#14141E 30%透明度)，极简赛博朋克占位符美学，暗淡低调表示空置可用槽位，除加号外不包含文字，不包含其他图标，PNG透明底
```

### 负面提示词

```
text, characters, bright colors, solid fill, 3D, glossy, complex decorations
```

---

## ④ detail_bg.png — 角色成长页背景

| 属性       | 值                                                |
| ---------- | ------------------------------------------------- |
| **文件名** | `assets/images/team/detail_bg.png`                |
| **尺寸**   | 720 × 1280 px                                    |
| **格式**   | PNG 或 JPG                                        |
| **用途**   | 角色成长页全屏背景(growth_panel)，立绘叠放在上方  |
| **构图**   | 上半部留出人物立绘空间（纯暗色渐变），下半部有信息面板的暗色区域 |

### AI 提示词（English）

```
Dark atmospheric character showcase background, vertical portrait composition 9:16 aspect ratio 720x1280, the upper two-thirds is a very dark gradient area suitable for overlaying character art — starting from near-black (#0A0A12) at the top with subtle dark red volumetric fog wisps and faint particle effects, a dramatic spotlight cone of dim dark red light from above illuminating the center area where a character portrait would be placed, the lower third transitions into a darker panel area with subtle dark metallic texture (#14141E) separated by a thin horizontal dark red line (#A61414) with small tech ornaments at the endpoints — this lower area will hold text info panels, very subtle hexagonal grid pattern in the lower panel area, overall extremely dark composition with atmospheric red lighting, cyberpunk character inspection screen aesthetic, no characters no text, 720x1280
```

### AI 提示词（中文）

```
暗色氛围角色展示背景，竖版构图9:16比例720x1280，上方三分之二是极深渐变区域适合叠放角色立绘——从顶部近纯黑(#0A0A12)开始带微弱暗红色体积雾和粒子效果，从上方投下暗红色聚光灯锥形光照亮中央角色立绘位置，下方三分之一过渡为更深的面板区域带微妙深色金属质感(#14141E)以细暗红色水平线(#A61414)分隔端点有小型科技装饰——此区域将放置文字信息面板，下方面板区有极微弱六边形网格纹理，整体极暗构图带氛围感红色照明，赛博朋克角色检阅界面美学，不包含人物和文字
```

### 负面提示词

```
people, characters, text, watermark, bright colors, daylight, happy mood, cartoon style, low quality, blurry
```

---

## ⑤ detail_info_panel.png — 角色信息面板底图

| 属性       | 值                                                |
| ---------- | ------------------------------------------------- |
| **文件名** | `assets/images/team/detail_info_panel.png`        |
| **尺寸**   | 680 × 500 px                                     |
| **格式**   | PNG（透明背景）                                   |
| **用途**   | 角色成长页下半部信息区域的半透明底板（备用，当前用StyleBoxFlat）|
| **构图**   | 圆角矩形(4px)，半透明深色底+红色细边框           |

### AI 提示词（English）

```
Dark semi-transparent UI information panel, rectangular shape 680x500 pixels with slightly rounded corners (4px radius), transparent background outside the panel, dark blue-black base fill (#0A0A12 at 85% opacity) creating a frosted glass dark effect, thin dark red border (#A61414) around all edges, subtle inner glow of very dark red at the top edge, faint hexagonal circuit texture etched into the surface at very low opacity, small angular tech decorations at the four corners with tiny red indicator dots, a thin horizontal divider line at approximately 80px from the top (for header section), cyberpunk HUD data display panel aesthetic, clean and elegant dark design, no text no icons, PNG with alpha transparency
```

### AI 提示词（中文）

```
深色半透明UI信息面板，矩形680x500像素微圆角(4px)，面板外部透明，暗蓝黑色底色(#0A0A12 85%透明度)呈现磨砂玻璃暗色效果，四周细暗红色边框(#A61414)，顶部边缘极微弱的暗红色内发光，表面极低透明度的六边形电路纹理蚀刻，四角小型棱角科技装饰带微小红色指示点，距顶部约80px处有一条细水平分隔线（用于标题区域），赛博朋克HUD数据显示面板美学，干净优雅的暗色设计，不包含文字图标，PNG透明底
```

### 负面提示词

```
text, icons, 3D, glossy, bright colors, gradient fills, complex patterns, shadows outside panel
```

---

## ⑥ tab_bg_active.png — 成长页标签激活态

| 属性       | 值                                                |
| ---------- | ------------------------------------------------- |
| **文件名** | `assets/images/team/tab_bg_active.png`            |
| **尺寸**   | 200 × 48 px                                      |
| **格式**   | PNG（透明背景）                                   |
| **用途**   | 角色成长页下方Tab（属性/装备/技能/天赋）激活状态底图 |

### AI 提示词（English）

```
Dark futuristic UI tab button ACTIVE state, rectangular shape 200x48 pixels with slightly rounded top corners (4px), transparent background, dark red-tinted base (#2E0A0A) with bright vivid red border on top edge only (#F23333 2px thick), bottom edge has no border (connects to content below), subtle angular tech circuit decorations at top-left and top-right corners glowing faintly, very subtle inner red glow at the top, cyberpunk HUD tab interface activated state, no text no icons, PNG with alpha transparency
```

### AI 提示词（中文）

```
深色未来感UI标签按钮【激活状态】，矩形200x48像素顶部微圆角(4px)，透明背景，偏红深色底(#2E0A0A)+仅顶部边缘明亮鲜红边框(#F23333 2px粗)，底部无边框（与下方内容连接），左上和右上角微弱发光的棱角科技装饰，顶部极微弱红色内发光，赛博朋克HUD标签界面激活状态，不包含文字图标，PNG透明底
```

---

## ⑦ tab_bg_inactive.png — 成长页标签未激活态

| 属性       | 值                                                |
| ---------- | ------------------------------------------------- |
| **文件名** | `assets/images/team/tab_bg_inactive.png`          |
| **尺寸**   | 200 × 48 px                                      |
| **格式**   | PNG（透明背景）                                   |
| **用途**   | 角色成长页下方Tab未选中状态底图                   |

### AI 提示词（English）

```
Dark futuristic UI tab button INACTIVE state, rectangular shape 200x48 pixels with slightly rounded top corners (4px), transparent background, very dark blue-gray base (#14141E) with thin dim dark red border on top edge only (#A61414 at 60% opacity 1px), bottom edge has a thin dark separator line, minimal angular tech decoration at corners (not glowing), overall muted and subdued compared to active state, cyberpunk HUD tab interface inactive state, no text no icons, PNG with alpha transparency
```

### AI 提示词（中文）

```
深色未来感UI标签按钮【未激活状态】，矩形200x48像素顶部微圆角(4px)，透明背景，极深蓝灰底(#14141E)+仅顶部暗淡暗红细边框(#A61414 60%透明度 1px)，底部有细暗色分隔线，角落极简科技装饰（不发光），整体比激活状态更暗淡低调，赛博朋克HUD标签界面未激活状态，不包含文字图标，PNG透明底
```

---

## ⑧ btn_back.png — 返回按钮（备用）

| 属性       | 值                                                |
| ---------- | ------------------------------------------------- |
| **文件名** | `assets/images/team/btn_back.png`                 |
| **尺寸**   | 48 × 48 px                                       |
| **格式**   | PNG（透明背景）                                   |
| **用途**   | 备用导航按钮（详情页已合并到成长Tab，暂未使用）   |

### AI 提示词（English）

```
Dark futuristic UI back button icon, square 48x48 pixels, transparent background, a left-pointing angular chevron arrow (<) made of thin bright red lines (#F23333) centered in the square, subtle dark red circular border around the arrow at low opacity (#A61414 40%), minimalist cyberpunk HUD navigation icon, clean sharp lines, no text, PNG with alpha transparency
```

### AI 提示词（中文）

```
深色未来感UI返回按钮图标，方形48x48像素，透明背景，中央一个由细亮红线条(#F23333)组成的左指棱角箭头(<)，箭头周围有低透明度暗红色圆形边框(#A61414 40%)，极简赛博朋克HUD导航图标，干净锐利的线条，不包含文字，PNG透明底
```

---

## ⑨ equip_slot_bg.png — 装备槽位底图

| 属性       | 值                                                |
| ---------- | ------------------------------------------------- |
| **文件名** | `assets/images/team/equip_slot_bg.png`            |
| **尺寸**   | 80 × 80 px                                       |
| **格式**   | PNG（透明背景）                                   |
| **用途**   | 角色详情页装备栏每个装备槽的底板                  |

### AI 提示词（English）

```
Dark futuristic equipment slot icon background, square 80x80 pixels, transparent background, dark metallic base (#14141E) with thin dark red border (#A61414), slightly rounded corners (2px), subtle inner bevel effect giving a recessed inset look, very faint hexagonal grid pattern on the surface, small angular tech marks at two opposing corners (top-left and bottom-right), center area slightly lighter to indicate drop zone for equipment icon, cyberpunk inventory slot aesthetic, no text no icons no items, PNG with alpha transparency
```

### AI 提示词（中文）

```
深色未来感装备槽位图标底板，方形80x80像素，透明背景，深色金属底(#14141E)+细暗红边框(#A61414)，微圆角(2px)，微弱内斜面效果呈现内凹嵌入感，表面极微弱六边形网格纹理，左上和右下对角有小型棱角科技标记，中心区域略亮表示装备图标放置区，赛博朋克物品栏槽位美学，不包含文字图标物品，PNG透明底
```

---

## ⑩ rarity_frame_r.png / rarity_frame_sr.png / rarity_frame_ssr.png — 稀有度头像边框

| 属性       | 值                                                           |
| ---------- | ------------------------------------------------------------ |
| **文件名** | `assets/images/team/rarity_frame_r.png` (绿色)              |
|            | `assets/images/team/rarity_frame_sr.png` (蓝色)             |
|            | `assets/images/team/rarity_frame_ssr.png` (橙色)            |
| **尺寸**   | 100 × 100 px（每个）                                        |
| **格式**   | PNG（透明背景，中央镂空供头像显示）                          |
| **用途**   | 叠在角色头像外层，通过边框颜色区分稀有度                    |
| **构图**   | 中央84x84px镂空（完全透明），外圈8px宽度的装饰边框          |

### AI 提示词 — R 级（绿色）（English）

```
Futuristic UI avatar frame border, square 100x100 pixels, transparent background with a transparent center cutout (84x84 inner area), the frame border is 8px wide around all edges, dark metallic base with green accent color (#4DB84D), thin inner and outer green glowing lines, small angular tech decorations at the four corners with tiny green indicator lights, subtle circuit line patterns running along the frame edges, cyberpunk military rank frame aesthetic, the center must be completely transparent for avatar overlay, PNG with alpha transparency
```

### AI 提示词 — SR 级（蓝色）（English）

```
Futuristic UI avatar frame border, square 100x100 pixels, transparent background with a transparent center cutout (84x84 inner area), the frame border is 8px wide, dark metallic base with blue accent color (#4D80E6), thin inner and outer blue glowing lines, angular tech corner decorations with blue indicator lights, more elaborate circuit patterns than R-rank, subtle blue energy pulse glow effect, cyberpunk elite rank frame, center completely transparent, PNG with alpha transparency
```

### AI 提示词 — SSR 级（橙色）（English）

```
Futuristic UI avatar frame border, square 100x100 pixels, transparent background with a transparent center cutout (84x84 inner area), the frame border is 8px wide, dark metallic base with orange-gold accent color (#CC801A), thin inner and outer orange glowing lines with subtle golden shimmer, elaborate angular tech decorations at all four corners with bright orange indicator lights, intricate circuit and energy flow patterns along the frame, faint orange particle effect aura, cyberpunk legendary rank frame with premium feel, center completely transparent, PNG with alpha transparency
```

### AI 提示词 — 稀有度边框（中文统一）

```
R级(绿): 未来感UI头像边框，方形100x100像素，透明背景中央84x84镂空，8px宽边框暗金属底+绿色(#4DB84D)发光线条，四角小型科技装饰绿色指示灯，边框沿线路纹理，赛博朋克军衔边框，中央完全透明，PNG透明底

SR级(蓝): 同上但蓝色(#4D80E6)发光线条，更精致的电路纹理，微弱蓝色能量脉冲光效，精英等级边框

SSR级(橙): 同上但橙金色(#CC801A)发光线条带金色微光，精致的四角装饰明亮橙色指示灯，复杂电路和能量流纹理，微弱橙色粒子光晕，传奇等级高级质感边框
```

### 负面提示词（通用）

```
text, icons, portrait, face, character, solid center, opaque center, bright background, cartoon style, low quality
```

---

## 生成建议

### 推荐工具

- **背景图 (①④):** Midjourney V6+ / Stable Diffusion XL（擅长环境概念画）
- **UI元素 (②③⑤⑥⑦⑧⑨):** Stable Diffusion + ControlNet 或 Figma/Photoshop 手工制作更可控
- **稀有度边框 (⑩):** 建议用 Figma/Photoshop 手工制作确保精准镂空

### 后处理注意事项

1. **②③⑤⑥⑦⑧⑨⑩ 必须是透明背景 PNG**，AI 生成后需手动抠图
2. **⑩ 稀有度边框中央必须完全镂空**，AI 难以精确控制，推荐手工制作
3. **①④ 背景图** 需确保足够暗（下半部分），方便叠加UI元素
4. 所有图片生成后放入 `assets/images/team/` 目录

### 资源清单与使用状态

| # | 文件名 | 尺寸 | 透明 | 使用状态 |
|---|--------|------|------|----------|
| ① | team_bg.png | 720×1280 | 否 | ✅ team_panel 背景 |
| ② | card_slot_bg.png | 640×100 | 是 | 备用（当前用 StyleBoxFlat） |
| ③ | card_slot_empty.png | 640×100 | 是 | ✅ team_panel 空槽位 |
| ④ | detail_bg.png | 720×1280 | 否 | ✅ growth_panel 背景 |
| ⑤ | detail_info_panel.png | 680×500 | 是 | 备用（当前用 StyleBoxFlat） |
| ⑥ | tab_bg_active.png | 200×48 | 是 | ⚠️ 尺寸/透明度不适配，改用代码StyleBoxFlat |
| ⑦ | tab_bg_inactive.png | 200×48 | 是 | ⚠️ 同上，改用代码StyleBoxFlat |
| ⑧ | btn_back.png | 48×48 | 是 | 备用（详情已合并到成长Tab） |
| ⑨ | equip_slot_bg.png | 80×80 | 是 | 备用（装备槽用文本列表） |
| ⑩ | rarity_frame_r/sr/ssr.png | 100×100 | 是 | ⚠️ 中心非全透明，改用代码绘制RarityBorder |
| — | **合计** | — | — | **12张（3张已接入，4张备用，5张改用代码）** |
