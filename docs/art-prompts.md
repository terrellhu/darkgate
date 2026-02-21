# 主界面美术资源规格与 AI 生成提示词

> 目标：为主菜单生成 6 张图片素材，放入 `assets/images/menu/` 目录后即可运行。

---

## 全局风格要求

- **游戏类型：** 末日废土 × 赛博朋克 × 克苏鲁恐怖 Roguelite
- **色彩基调：** 极暗底色（接近纯黑）+ 暗红色主色调 + 暖米色文字
- **氛围关键词：** 压抑、危险、衰败、科技废墟、异化瘟疫
- **核心色板：**
  - 背景黑 `#0A0A12`
  - 血红强调 `#B81212`
  - 暗红边框 `#A61414`
  - 亮红高光 `#F23333`
  - 暖米文字 `#F0EBD9`
- **画面方向：** 竖版 720×1280（手机竖屏）
- **风格参考：** Darkest Dungeon 的压抑氛围 + 少女前线/明日方舟 的角色立绘风格

---

## ① bg_main.png — 全屏背景画

| 属性         | 值                                                                            |
| ------------ | ----------------------------------------------------------------------------- |
| **文件名**   | `assets/images/menu/bg_main.png`                                              |
| **尺寸**     | 720 × 1280 px                                                                 |
| **格式**     | PNG 或 JPG（不需要透明）                                                      |
| **用途**     | 铺满全屏的主背景，StretchMode = KEEP_ASPECT_COVERED                           |
| **构图要求** | 上半部分有天空/门的视觉焦点，下半部分自然偏暗（废墟地面），方便叠加角色和按钮 |

### AI 提示词（English — 推荐用于 Midjourney / Stable Diffusion）

```
Dark post-apocalyptic ruined cityscape, vertical portrait composition 9:16 aspect ratio,
a massive ominous black portal gate floating in the crimson sky emitting dark red energy
tendrils and anti-matter particles, collapsed concrete skyscrapers and crumbling buildings
silhouetted against the red sky below, scattered debris ash and twisted metal on the ground,
volumetric red-tinted fog drifting through the ruins, dramatic top-down lighting from the
portal casting long shadows, the lower third of the image shrouded in deep shadow and rubble,
cyberpunk dystopian post-apocalypse atmosphere, muted desaturated color palette dominated by
dark reds deep blacks and cold grays, digital concept art style, highly detailed environment,
no characters no people, cinematic composition, 720x1280
```

### AI 提示词（中文 — 用于国产 AI 工具）

```
末日废土城市废墟全景，竖版构图9:16比例，天空中悬浮着一扇巨大的漆黑传送门（黑门），
散发暗红色能量触须和反物质粒子，下方是坍塌的混凝土摩天楼和碎裂建筑的剪影，地面散落
碎石灰烬和扭曲金属残骸，红色调体积雾在废墟间弥漫，从传送门投下的戏剧性顶光形成长影，
画面下三分之一沉入深邃阴影和瓦砾中，赛博朋克末日氛围，去饱和暗色调为主（深红+纯黑+冷灰），
数字概念艺术风格，高度精细的环境画，不要人物角色，电影感构图
```

### 负面提示词（Negative Prompt）

```
people, characters, text, watermark, logo, bright colors, daylight, sunshine, green vegetation,
happy mood, cartoon style, low quality, blurry
```

---

## ② char_main.png — 角色半身立绘

| 属性         | 值                                                            |
| ------------ | ------------------------------------------------------------- |
| **文件名**   | `assets/images/menu/char_main.png`                            |
| **尺寸**     | 480 × 720 px                                                  |
| **格式**     | PNG（必须透明背景）                                           |
| **用途**     | 叠放在背景上方，居中偏右位置，Y 偏移约 300px                  |
| **构图要求** | 半身像（胸部以上+手部），面朝画面左侧约 15°，人物位于画面中央 |

### AI 提示词（English）

```
Female warrior half-body portrait, transparent background, dark tactical combat bodysuit
with subtle glowing red cybernetic enhancements on arms and neck, short asymmetric dark
hair with one side shaved, determined cold piercing eyes, battle-scarred face with a thin
scar across left cheek, one hand gripping a faintly glowing crimson energy blade at her
side, dark red accent rim lighting on armor edges and cybernetic joints, post-apocalyptic
military aesthetic, anime-influenced semi-realistic art style (similar to Arknights or
Girls Frontline character art), muted dark palette with selective red highlights,
character facing slightly to the left, upper body head and one hand visible, dramatic
lighting from upper right, PNG with alpha transparency, 480x720
```

### AI 提示词（中文）

```
女战士半身立绘，透明背景，深色战术紧身作战服，手臂和颈部有发出暗红色微光的精密机械
改造部件，不对称短发（一侧剃短），冷峻凌厉的眼神，脸上有一道细小战斗伤疤横过左颊，
一只手握着微微发光的绯红能量战刃垂于身侧，护甲边缘和机械关节处有暗红色轮廓光，
末日军事美学，半写实日系画风（类似明日方舟/少女前线角色立绘风格），暗色调配色仅红色
作为点缀高光，人物微微面向左侧，可见上半身头部和一只手，右上方打光的戏剧性光影，
PNG透明底
```

### 负面提示词

```
background, scenery, full body, legs, feet, bright colors, smile, happy expression,
oversized weapons, excessive armor, cartoon chibi style, low quality, watermark
```

---

## ③ title_glow.png — 标题光效底图

| 属性         | 值                                                     |
| ------------ | ------------------------------------------------------ |
| **文件名**   | `assets/images/menu/title_glow.png`                    |
| **尺寸**     | 600 × 140 px                                           |
| **格式**     | PNG（必须透明背景）                                    |
| **用途**     | 放在标题文字 "九重黑门" 下方作为光效衬底，增强视觉厚度 |
| **构图要求** | 中心最亮，向四周渐隐到完全透明，横向拉长的椭圆形光晕   |

### AI 提示词（English）

```
Abstract dark red energy glow effect, transparent background, horizontal elliptical shape,
concentrated bright crimson-red light in the center gradually fading to fully transparent
edges, subtle dark particle trails and wispy energy tendrils extending from the glow,
mystical dark portal energy aesthetic, ominous supernatural atmosphere, no text no letters
no symbols, soft diffused light, 600x140, PNG with alpha transparency
```

### AI 提示词（中文）

```
抽象暗红色能量光效，透明背景，水平椭圆形状，中心集中的明亮绯红色光芒向四周逐渐渐隐
至完全透明，带有细微的暗色粒子拖尾和飘渺能量触须从光芒中延伸，神秘黑暗传送门能量美学，
不祥超自然氛围，不包含任何文字字母符号，柔和漫射光
```

### 负面提示词

```
text, letters, symbols, numbers, solid background, white background, sharp edges,
geometric shapes, bright cheerful colors
```

---

## ④ divider_ornament.png — 装饰分隔线

| 属性         | 值                                                              |
| ------------ | --------------------------------------------------------------- |
| **文件名**   | `assets/images/menu/divider_ornament.png`                       |
| **尺寸**     | 500 × 24 px                                                     |
| **格式**     | PNG（必须透明背景）                                             |
| **用途**     | 替代原 1px 红色分隔线，放在标题与副标题之间                     |
| **构图要求** | 左右完全对称，中心有小型装饰元素（菱形/六边形），线条向两端渐隐 |

### AI 提示词（English）

```
Ornamental horizontal divider line, transparent background, dark oxidized metal style,
thin elegant red line with a small diamond-shaped crystal ornament in the exact center,
the line gradually fades to transparent at both ends, subtle dark red glow emanating from
the center piece, gothic industrial cyberpunk aesthetic, perfectly symmetrical left-right
design, minimalist and elegant, no text, 500x24, PNG with alpha transparency
```

### AI 提示词（中文）

```
装饰水平分隔线，透明背景，氧化深色金属质感，纤细优雅的红色线条中央有一个小菱形水晶
装饰元素，线条向两端逐渐渐隐至透明，中心装饰散发微弱暗红色辉光，哥特工业赛博朋克美学，
完全左右对称设计，极简而优雅，不包含文字
```

### 负面提示词

```
text, thick lines, colorful, bright, asymmetric, complex patterns, floral, organic shapes
```

---

## ⑤ btn_normal.png — 按钮常态底图

| 属性         | 值                                                         |
| ------------ | ---------------------------------------------------------- |
| **文件名**   | `assets/images/menu/btn_normal.png`                        |
| **尺寸**     | 624 × 64 px                                                |
| **格式**     | PNG（必须透明背景）                                        |
| **用途**     | TextureButton 的 texture_normal，按钮文字叠加在上方        |
| **构图要求** | 矩形，微圆角(2px)，深色底+红色细边框，角落可有小科技感装饰 |

### AI 提示词（English）

```
Dark futuristic UI button background, rectangular shape with very slightly rounded corners,
transparent background outside the button, very dark blue-gray base color (#14141E) with
thin bright red border lines (#A61414), small angular tech circuit decorations at the four
corners, subtle hexagonal circuit pattern faintly etched into the button surface, cyberpunk
HUD interface aesthetic, clean and minimal, no text no icons, 624x64, PNG with alpha
transparency
```

### AI 提示词（中文）

```
深色未来感UI按钮底图，矩形微圆角，按钮外部透明，极深蓝灰色底(#14141E)+细亮红色边框线
(#A61414)，四个角落有棱角分明的小科技电路装饰，按钮表面有微弱的六边形电路纹理蚀刻，
赛博朋克HUD界面美学，干净极简，不包含文字和图标
```

### 负面提示词

```
text, icons, 3D, glossy, gradient, bright colors, rounded pill shape, shadow, drop shadow
```

---

## ⑥ btn_pressed.png — 按钮按下态底图

| 属性         | 值                                                                     |
| ------------ | ---------------------------------------------------------------------- |
| **文件名**   | `assets/images/menu/btn_pressed.png`                                   |
| **尺寸**     | 624 × 64 px                                                            |
| **格式**     | PNG（必须透明背景）                                                    |
| **用途**     | TextureButton 的 texture_pressed，按下时切换                           |
| **构图要求** | 与 btn_normal 相同构图，但整体更亮，边框更亮红，表面有更明显的能量纹理 |

### AI 提示词（English）

```
Dark futuristic UI button background PRESSED/ACTIVE state, rectangular shape with very
slightly rounded corners, transparent background outside the button, dark red-tinted base
color (#2E0A0A) with bright vivid red border lines (#F23333), small angular tech circuit
decorations at corners now glowing brighter, hexagonal circuit pattern on surface now
clearly visible and faintly illuminated in red, subtle inner red glow effect, cyberpunk
HUD interface aesthetic, activated state, no text no icons, 624x64, PNG with alpha
transparency
```

### AI 提示词（中文）

```
深色未来感UI按钮底图【按下/激活状态】，矩形微圆角，按钮外部透明，偏红的深色底(#2E0A0A)
+明亮鲜红边框线(#F23333)，四角科技装饰现在发出更亮的光，表面六边形电路纹理清晰可见且
被红光微微照亮，内部有微弱红色辉光效果，赛博朋克HUD界面美学，激活状态，不包含文字图标
```

### 负面提示词

```
text, icons, 3D, glossy, bright colors, rounded pill shape, inactive, dim, dark
```

---

## 生成建议

### 推荐工具

- **背景画 (①):** Midjourney V6+ / Stable Diffusion XL（擅长环境概念画）
- **角色立绘 (②):** NovelAI / Stable Diffusion（擅长日系半写实角色+透明底）
- **UI元素 (③④⑤⑥):** Stable Diffusion + ControlNet 或手动设计工具更可控

### 后处理注意事项

1. **②③④⑤⑥ 必须是透明背景 PNG**，AI 生成后可能需要手动抠图
2. **① 背景画** 下半部分如果不够暗，可用 Photoshop/GIMP 叠加一层从透明到黑色的渐变
3. **⑤⑥ 按钮** 如果 AI 生成效果不理想，推荐用 Figma/Photoshop 手工制作更精准
4. 所有图片生成后放入 `assets/images/menu/` 目录，Godot 会自动导入

### 分辨率说明

- 游戏视口 720×1280，以上尺寸为 1x 分辨率
- 如需高清适配，可生成 2x 尺寸（1440×2560 等）然后在 Godot 导入设置中配置
