# 项目架构文档：BlackGate

## 1. 技术栈

- **引擎**：Godot 4.6
- **语言**：GDScript
- **渲染**：GL Compatibility（移动端兼容）
- **物理**：Jolt Physics
- **目标平台**：移动端（竖屏 720x1280）
- **最低适配**：Android 8.0 / iOS 14

---

## 2. 项目目录结构

```text
res://
├── assets/                  # 静态资源
│   ├── fonts/               # 字体文件（.ttf/.otf）
│   ├── icons/               # UI 图标（.svg/.png）
│   ├── audio/
│   │   ├── bgm/             # 背景音乐（.ogg）
│   │   └── sfx/             # 音效（.wav/.ogg）
│   └── themes/              # Godot UI Theme（.tres）
│
├── data/                    # 游戏静态数据
│   ├── characters/          # 角色定义（.tres）
│   ├── enemies/             # 敌人定义（.tres）
│   ├── items/               # 物品/装备定义（.tres）
│   ├── skills/              # 技能定义（.tres）
│   ├── maps/                # 地图节点配置（.json）
│   ├── events/              # 探索事件脚本（.json）
│   └── dialogues/           # 对话/叙事文本（.json）
│
├── scenes/                  # 场景文件（.tscn）
│   ├── main/                # 入口场景、主菜单
│   ├── hub/                 # 枢纽经营界面
│   ├── expedition/          # 探索地图界面
│   ├── combat/              # 战斗界面
│   ├── ui/                  # 可复用 UI 组件
│   └── common/              # 通用场景节点
│
├── scripts/                 # GDScript 脚本
│   ├── autoload/            # 全局单例（Autoload）
│   ├── core/                # 核心工具类
│   ├── hub/                 # 枢纽经营逻辑
│   ├── expedition/          # 探索系统逻辑
│   ├── combat/              # 战斗系统逻辑
│   ├── character/           # 角色/队伍管理
│   ├── resources/           # 自定义 Resource 类
│   └── ui/                  # UI 控制脚本
│
└── docs/                    # 设计文档（不打包）
```

---

## 3. 全局单例（Autoload）

系统通过 Autoload 注册全局单例，各单例职责如下：

### GameManager
- 游戏主状态机：`MAIN_MENU → HUB → EXPEDITION → COMBAT`
- 管理场景切换（带过渡动画）
- 暂停/恢复控制

### DataManager
- 启动时加载并缓存所有静态数据（Resource / JSON）
- 提供数据查询接口：`get_character(id)`, `get_enemy(id)` 等
- 数据只读，运行时不修改

### SaveManager
- 存档/读档：序列化 PlayerData 到 `user://save/`
- 支持多存档槽位
- 自动保存（切换场景时）

### EventBus
- 全局信号总线，解耦模块间通信
- 定义所有跨模块信号（如 `resource_changed`, `combat_started`, `san_updated`）
- 各模块通过 EventBus 收发信号，避免直接引用

### AudioManager
- BGM 播放（支持淡入淡出切换）
- SFX 播放（支持同时多个音效）
- 音量分组控制（Master / BGM / SFX）

### PlayerData
- 运行时玩家动态数据的唯一来源
- 包含：资源存量、队伍编成、探索进度、主角状态、设施等级等
- 所有数据修改通过方法调用，自动触发 EventBus 信号

---

## 4. 数据模型（Resource 类）

使用 Godot 的 `Resource` 系统定义数据结构，可在编辑器中直接编辑：

| 类名 | 文件 | 描述 |
| --- | --- | --- |
| CharacterData | `scripts/resources/character_data.gd` | 角色模板：名称、职业、稀有度、基础属性、技能列表 |
| EnemyData | `scripts/resources/enemy_data.gd` | 敌人模板：名称、类型、属性、掉落表 |
| ItemData | `scripts/resources/item_data.gd` | 物品/装备：名称、类型、品质、基础属性、词条池 |
| SkillData | `scripts/resources/skill_data.gd` | 技能：名称、类型、消耗、伤害公式、特效 |
| MapNodeData | `scripts/resources/map_node_data.gd` | 地图节点：类型、坐标、连接关系、事件ID |
| EventData | `scripts/resources/event_data.gd` | 探索事件：描述文本、选项列表、结果 |

---

## 5. 场景树结构

### 5.1 主场景 (main.tscn)

```text
Main (Control)
├── Background (TextureRect)
├── TitleScreen (Control)          # 标题画面
│   ├── Logo (TextureRect)
│   ├── BtnNewGame (Button)
│   ├── BtnContinue (Button)
│   └── BtnSettings (Button)
└── TransitionLayer (ColorRect)    # 场景切换遮罩
```

### 5.2 枢纽场景 (hub.tscn)

```text
Hub (Control)
├── TopBar (HBoxContainer)         # 资源显示栏
│   ├── BioElectricity (Label)
│   ├── NanoAlloy (Label)
│   ├── Hashrate (Label)
│   └── MentalPower (Label)
├── FacilityList (VBoxContainer)   # 设施列表
│   ├── ReactorSlot (PanelContainer)
│   ├── RecruitSlot (PanelContainer)
│   ├── ClinicSlot (PanelContainer)
│   ├── MarketSlot (PanelContainer)
│   ├── ForgeSlot (PanelContainer)
│   └── DataLabSlot (PanelContainer)
├── BottomNav (HBoxContainer)      # 底部导航
│   ├── BtnHub (Button)
│   ├── BtnTeam (Button)
│   ├── BtnExpedition (Button)
│   └── BtnSettings (Button)
└── PopupLayer (CanvasLayer)       # 弹窗层
```

### 5.3 探索场景 (expedition.tscn)

```text
Expedition (Control)
├── MapContainer (Control)         # 地图网格区域
│   └── MapGrid (GridContainer)    # 格子节点动态生成
├── SanBar (ProgressBar)           # SAN值显示
├── LinkBar (ProgressBar)          # 精神链接值
├── TeamInfo (HBoxContainer)       # 队伍简要状态
├── NarrativePanel (PanelContainer)# 文字叙事面板
│   ├── NarrativeText (RichTextLabel)
│   └── ChoiceList (VBoxContainer) # 事件选项
└── ActionButtons (HBoxContainer)  # 操作按钮
    ├── BtnMove (Button)
    ├── BtnRest (Button)
    └── BtnRetreat (Button)
```

### 5.4 战斗场景 (combat.tscn)

```text
Combat (Control)
├── EnemyArea (VBoxContainer)      # 敌方区域
│   └── EnemyList (HBoxContainer)
├── BattleLog (RichTextLabel)      # 战斗文字日志
├── AllyArea (VBoxContainer)       # 我方区域
│   └── AllyList (HBoxContainer)
├── ATBBars (VBoxContainer)        # 行动条显示
├── ActionPanel (PanelContainer)   # 手动干预面板
│   ├── BtnAttack (Button)
│   ├── BtnSkill (Button)
│   ├── BtnItem (Button)
│   └── BtnAuto (Button)
└── ResultPopup (PopupPanel)       # 战斗结果
```

---

## 6. 游戏状态流转

```text
┌─────────┐
│MAIN_MENU│
└────┬────┘
     │ 新游戏/继续
     ▼
┌─────────┐
│   HUB   │◄──────────────┐
└────┬────┘               │
     │ 选择黑门出发        │ 撤退/探索完成
     ▼                    │
┌──────────┐              │
│EXPEDITION│──────────────┘
└────┬─────┘
     │ 遭遇敌人
     ▼
┌─────────┐
│ COMBAT  │───► 胜利 → 返回 EXPEDITION
└─────────┘───► 全灭 → 返回 HUB
```

---

## 7. 信号通信（EventBus）

关键全局信号定义：

```gdscript
# 资源变化
signal resource_changed(resource_type: String, new_value: int)
# SAN值变化
signal san_updated(new_value: float)
# 精神链接变化
signal mental_link_updated(new_value: float)
# 战斗事件
signal combat_started(enemies: Array)
signal combat_ended(result: String)  # "victory" / "defeat"
# 探索事件
signal exploration_event(event_data: EventData)
# 角色事件
signal character_recruited(character: CharacterData)
signal character_died(character_id: String)
# 场景切换
signal scene_change_requested(scene_name: String)
# 异化值
signal aberration_updated(character_id: String, value: float)
```

---

## 8. 存档结构

存档保存到 `user://save/slot_X.json`：

```json
{
  "version": 1,
  "timestamp": "2026-02-14T12:00:00",
  "player": {
    "name": "...",
    "level": 5,
    "mental_power": 80,
    "gene_crack": 3
  },
  "resources": {
    "bio_electricity": 1200,
    "nano_alloy": 340,
    "chips": 120,
    "hashrate": 5600,
    "credits": 200
  },
  "team": ["char_001", "char_005", "char_012"],
  "characters": {
    "char_001": { "level": 10, "stars": 3, "equipment": [...] }
  },
  "facilities": {
    "reactor": { "level": 3, "workers": 5 },
    "recruit": { "level": 2, "workers": 1 }
  },
  "progress": {
    "current_gate": 2,
    "gates_cleared": [1],
    "map_explored": { "gate_2": [0, 1, 5, 6, 7] }
  }
}
```

---

## 9. 编码规范

- **文件命名**：`snake_case`（如 `game_manager.gd`, `character_data.gd`）
- **类命名**：`PascalCase`（如 `CharacterData`, `GameManager`）
- **信号命名**：`snake_case`（如 `resource_changed`）
- **常量命名**：`UPPER_SNAKE_CASE`（如 `MAX_TEAM_SIZE = 4`）
- **缩进**：Tab（Godot 默认）
- **注释语言**：中文注释，英文标识符
