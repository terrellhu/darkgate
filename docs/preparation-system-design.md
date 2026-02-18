# 准备系统设计文档（英雄部位装备 + 主角装备预留）

本文档用于指导“出发前准备系统（Preparation）”的实现，明确主角与英雄采用不同装备体系。

---

## 1. 目标与范围

## 1.1 目标

1. 在枢纽中提供完整的“出发前准备”流程：编队、装备、确认出征。
2. 英雄采用“按身体部位穿戴”的经典装备体系，支持后续数值扩展。
3. 主角（玩家）装备体系独立设计，本期仅做数据结构预留，不进入正式玩法。

## 1.2 本期范围（P1）

1. 英雄部位装备系统：可穿戴、可卸下、属性即时生效。
2. 背包与已装备状态联动（同一件装备不能同时装给多人）。
3. 与现有角色配置系统对接（`CharacterData` + `PlayerData` + `CharacterConfigService`）。
4. 准备界面流程定义与交互状态定义（文档级，不含UI美术细节）。

## 1.3 暂不实现（P2+）

1. 主角装备具体玩法（团队光环、指挥芯片等）。
2. 套装效果、词条重铸、强化升阶。
3. 战斗内换装、耐久、损坏。

---

## 2. 双装备体系设计

## 2.1 英雄装备体系（本期实现）

英雄装备 = 角色级、部位制、显式穿戴。

建议部位：

- `WEAPON`（主武器）
- `HEAD`（头部）
- `BODY`（躯干）
- `ARMS`（手臂）
- `LEGS`（腿部）
- `ACCESSORY_A`（饰品位1）
- `ACCESSORY_B`（饰品位2）

设计理由：

1. 兼容“女武神/异格者”的义体题材，可映射人体部位。
2. 易于做职业差异（盾卫可双防具、突击手偏武器收益）。
3. 便于后续扩展“套装”与“部位破坏”机制。

## 2.2 主角装备体系（本期预留）

主角装备不走部位制，走“指挥增益模块”。

预留槽位（暂不启用）：

- `command_core`
- `relay_chip`
- `mental_amplifier`

预期效果方向（后续）：

1. 全队增益（ATB速度、抗性、掉落加成）。
2. 与精神力/精神链接联动。
3. 不与英雄装备池直接竞争，单独成长线。

---

## 3. 数据结构设计

## 3.1 `ItemData` 扩展

当前`ItemData`已有基础属性字段（`equip_hp/equip_atk/...`），新增以下字段：

```gdscript
enum EquipSlot {
	SLOT_WEAPON,
	SLOT_HEAD,
	SLOT_BODY,
	SLOT_ARMS,
	SLOT_LEGS,
	SLOT_ACCESSORY,
}

@export var equip_slot: EquipSlot = EquipSlot.SLOT_WEAPON
@export var min_level: int = 1
@export var profession_whitelist: Array[int] = [] # CharacterData.Profession
@export var char_type_whitelist: Array[int] = []  # CharacterData.CharType
@export var unique_equip: bool = false            # 是否唯一（全队仅1件生效）
```

说明：

1. `ACCESSORY`用于支持两饰品位复用同类物品。
2. 白名单为空表示“所有职业/类型可穿戴”。
3. `unique_equip`为后续高稀有装备预留。

## 3.2 `PlayerData` 英雄装备存储

当前`owned_characters[char_id].equipment`为数组，改为“槽位字典”：

```json
{
  "equipment": {
    "WEAPON": "item_weapon_001",
    "HEAD": "",
    "BODY": "",
    "ARMS": "",
    "LEGS": "",
    "ACCESSORY_A": "item_acc_003",
    "ACCESSORY_B": ""
  }
}
```

同时保留背包池（若当前未实现需新增）：

```json
{
  "inventory": {
    "item_weapon_001": 1,
    "item_head_002": 2
  }
}
```

## 3.3 主角装备预留数据

```json
{
  "player_loadout": {
    "command_core": "",
    "relay_chip": "",
    "mental_amplifier": ""
  }
}
```

本期只存储，不计算数值。

---

## 4. 数值与结算规则

## 4.1 英雄属性结算

沿用现有`CharacterConfigService.calculate_stats()`：

1. 基础属性 + 成长属性。
2. 汇总所有已装备部位的`equip_*`加值。
3. 统一乘星级系数。

公式不变，变化点仅在“装备来源”：

- 从“装备ID数组求和”改为“槽位字典求和”。

## 4.2 装备合法性校验

给角色装备时按以下顺序校验：

1. 物品存在且是装备类型（`WEAPON/ARMOR/ACCESSORY`）。
2. 角色等级满足`min_level`。
3. 职业/角色类型满足白名单。
4. 目标槽位兼容（饰品可落`ACCESSORY_A/B`）。
5. 若`unique_equip=true`，全队不能重复装备同ID。

## 4.3 卸下与替换规则

1. 槽位有装备 -> 卸下后返还背包`+1`。
2. 装备新物品 -> 自动卸下旧装备并返还背包。
3. 同一角色不能在`ACCESSORY_A/B`重复装备同一件唯一物品。

---

## 5. 准备系统流程设计

## 5.1 入口

枢纽`BtnExpedition`前增加“准备确认”流程：

1. 点击“出征”。
2. 打开准备面板（队伍与装备总览）。
3. 玩家确认后进入探索。

## 5.2 准备面板结构

建议页面结构：

1. 左侧：队伍列表（最多4人）。
2. 中间：选中英雄的部位槽（可点击替换）。
3. 右侧：背包筛选列表（按槽位、品质、职业可用）。
4. 底部：总战力摘要（HP/ATK/DEF总和）与“确认出征”。

## 5.3 交互细节

1. 点击部位槽 -> 右侧只显示该槽位可装备物品。
2. 已装备物品标注“已装备于XXX”。
3. 不可装备项显示灰态并给出原因（等级不足/职业不符）。
4. 切换英雄时实时刷新属性面板。

---

## 6. 与现有代码的对接建议

## 6.1 新增脚本职责

1. `scripts/character/equipment_service.gd`
- 统一处理：可装备判定、装卸、槽位映射、背包增减。

2. `scripts/ui/preparation_panel.gd`
- 准备界面状态机与交互。

## 6.2 修改点

1. `scripts/resources/item_data.gd`
- 增加槽位/限制字段。

2. `scripts/autoload/player_data.gd`
- 角色`equipment`结构改为槽位字典。
- 新增`inventory`与基础操作接口。
- 预留`player_loadout`结构。

3. `scripts/character/character_config_service.gd`
- 装备汇总从数组遍历改为槽位字典遍历。

4. `scenes/hub/hub.gd`
- `BtnExpedition`进入准备面板，而不是直接切`EXPEDITION`。

## 6.3 事件信号（建议）

在`EventBus`新增：

```gdscript
signal equipment_changed(char_id: String, slot: String, item_id: String)
signal inventory_changed(item_id: String, new_count: int)
signal preparation_confirmed(team: Array[String])
```

---

## 7. 存档兼容策略

旧存档兼容迁移：

1. 若`equipment`是数组，迁移为槽位字典（按规则自动分配）。
2. 若无法判定槽位，全部回退到背包。
3. 缺失`inventory`则初始化为空字典。
4. 缺失`player_loadout`则初始化空槽位。

---

## 8. 配置示例（英雄装备）

示例：头部防具

```text
id = "item_head_sensor_01"
display_name = "战术感知头盔"
item_type = ARMOR
quality = BLUE
equip_slot = HEAD
equip_hp = 40
equip_def = 8
equip_speed = 1
min_level = 4
profession_whitelist = [0, 1, 2] # ASSAULT/SHIELD/EXECUTIONER
char_type_whitelist = []         # 全类型可用
```

---

## 9. 分期计划

## P1（当前）

1. 英雄部位装备 + 准备面板 + 背包联动。
2. 主角装备数据预留但不启用。

## P2

1. 主角“指挥模块”上线（团队增益）。
2. 套装效果、词条筛选、强化。

## P3

1. 与精神链接/异化系统深度耦合（装备触发战斗事件）。

---

## 10. 验收标准（P1）

1. 新增角色或装备仅通过配置文件即可生效，无需改计算逻辑。
2. 每个英雄的部位装备可独立管理，属性即时刷新。
3. 存档读写后装备状态不丢失，旧档可自动迁移。
4. 主角装备字段存在但不影响当前战斗平衡。
