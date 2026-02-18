# 人物属性系统与战斗数值机制设计（结合当前代码）

本文档基于以下现状编写：
- 玩法与架构：`docs/play-design.md`、`docs/architecture.md`、`docs/game-design.md`、`docs/background.md`
- 当前实现：`scripts/resources/*.gd`、`scripts/autoload/*.gd`、`scenes/combat/combat.gd`、`scenes/expedition/expedition.gd`

目标：在不破坏当前项目结构的前提下，定义一套可迭代落地的角色属性模型与战斗公式体系。

---

## 1. 设计原则

1. 与现有Resource字段兼容：优先复用`base_hp/base_atk/base_def/base_speed/base_crit_rate/base_crit_damage`。
2. 分层计算：模板值、养成值、装备值、战斗临时值分离，避免后续难以调试。
3. 轻Roguelike可调参：关卡深度（黑门层级）、SAN阶段、异化失控都可作为倍率层叠。
4. 公式稳定优先：先控制“可解释性”，再追求复杂机制。

---

## 2. 属性系统设计

## 2.1 属性分层模型

战斗中每个单位的最终属性由4层叠加：

1. 模板层（Template）
- 来源：`CharacterData`/`EnemyData`
- 示例：`base_hp`, `base_atk`, `base_def`, `base_speed`

2. 成长层（Progression）
- 来源：`PlayerData.owned_characters[char_id]`
- 示例：`level`, `stars`, 职业成长系数

3. 装备层（Equipment）
- 来源：`ItemData.equip_*`
- 示例：`equip_hp`, `equip_atk`, `equip_def`, `equip_speed`, `equip_crit_rate`

4. 战斗层（Battle Runtime）
- 来源：Buff/Debuff、SAN阶段、异化状态、技能临时效果
- 示例：攻击提升、护甲破坏、控制抗性、失控增伤

最终计算采用：

```text
FinalStat = floor((Base + Growth + EquipFlat) * (1 + SumPercentBonus)) * RuntimeMultiplier
```

---

## 2.2 核心属性定义

### A. 主属性（单位基础战斗骨架）

- `max_hp`：生命上限
- `atk`：攻击强度
- `def`：防御强度
- `speed`：ATB充能速度

### B. 次属性（输出与稳定性）

- `crit_rate`：暴击率，建议上限`0.75`
- `crit_damage`：暴击伤害倍率，默认`1.5`
- `hit_rate`：命中修正（默认`1.0`）
- `dodge_rate`：闪避概率（默认`0.0`，上限`0.60`）
- `armor_pen`：护甲穿透比例（0~1）
- `heal_power`：治疗加成比例

### C. 异常与控制属性

- `effect_hit`：效果命中（控制/减益施加）
- `effect_resist`：效果抵抗
- `tenacity`：控制时长缩短（0~0.5）

### D. 异化属性（异格者专属）

- `aberration`：当前异化值（战斗态）
- `max_aberration`：异化值上限（来自`CharacterData`）
- `aberration_gain_rate`：异化积累系数（默认1.0）
- `lost_control`：是否失控（bool）

### E. 团队/全局状态属性

- `team_san`：队伍共享SAN（来自`PlayerData.current_san`）
- `mental_link`：精神链接值（来自`PlayerData.current_mental_link`）

---

## 2.3 职业成长系数（建议）

用于把当前静态`base_*`扩展成可成长曲线。

| 职业 | hp_growth | atk_growth | def_growth | speed_growth |
| --- | ---: | ---: | ---: | ---: |
| ASSAULT | 11 | 3.2 | 1.4 | 0.35 |
| SHIELD | 16 | 1.6 | 2.6 | 0.20 |
| EXECUTIONER | 12 | 2.8 | 1.5 | 0.30 |
| PLAGUE | 10 | 3.0 | 1.2 | 0.28 |
| PSION | 9 | 3.4 | 1.1 | 0.33 |
| BERSERKER | 13 | 3.8 | 1.0 | 0.25 |

成长层公式：

```text
GrowthHP    = (level - 1) * hp_growth
GrowthATK   = (level - 1) * atk_growth
GrowthDEF   = (level - 1) * def_growth
GrowthSpeed = (level - 1) * speed_growth
```

星级加成为百分比乘区：

```text
StarBonus = 1 + (stars - 1) * 0.08
```

应用建议：
- `HP`吃满`StarBonus`
- `ATK/DEF`吃`StarBonus * 0.8`
- `Speed`仅吃`StarBonus * 0.3`

---

## 2.4 与现有Resource字段映射

已存在字段可直接使用：
- `CharacterData`: `base_hp/base_atk/base_def/base_speed/base_crit_rate/base_crit_damage/max_aberration/aberration_per_skill`
- `EnemyData`: `hp/atk/def/speed`
- `SkillData`: `base_damage/damage_multiplier/cooldown/bleed_chance/stun_chance/silence_chance/dot_damage/dot_duration`
- `ItemData`: `equip_hp/equip_atk/equip_def/equip_speed/equip_crit_rate`

建议新增字段（第一版最小可用）：

### CharacterData（建议增加）
- `base_hit_rate: float = 1.0`
- `base_dodge_rate: float = 0.02`
- `base_armor_pen: float = 0.0`
- `base_effect_hit: float = 0.0`
- `base_effect_resist: float = 0.0`
- `base_heal_power: float = 0.0`

### EnemyData（建议增加）
- `crit_rate: float = 0.05`
- `crit_damage: float = 1.5`
- `hit_rate: float = 1.0`
- `dodge_rate: float = 0.0`
- `effect_resist: float = 0.0`

### SkillData（建议增加）
- `accuracy_bonus: float = 0.0`
- `ignore_def_ratio: float = 0.0`
- `heal_multiplier: float = 0.0`
- `shield_multiplier: float = 0.0`
- `duration: int = 0`（Buff/Control持续时间）
- `priority: int = 0`（Gambit用）

### PlayerData（建议增加运行时字段）
- `owned_characters[char_id].current_aberration: float`
- `owned_characters[char_id].current_hp: int`（已有，初始化可改为`max_hp`）

---

## 3. 战斗数值计算机制

## 3.1 战斗快照生成（进入战斗时）

对每个我方角色生成`BattleUnitState`：

```text
base <- CharacterData
lvl/star <- PlayerData.owned_characters[char_id]
equip <- item stats aggregation

max_hp = floor((base_hp + GrowthHP + equip_hp) * StarHPBonus)
atk    = floor((base_atk + GrowthATK + equip_atk) * StarAtkBonus)
def    = floor((base_def + GrowthDEF + equip_def) * StarDefBonus)
speed  = floor((base_speed + GrowthSpeed + equip_speed) * StarSpdBonus)

current_hp = clamp(saved_current_hp, 1, max_hp) or max_hp
atb = 0
cooldowns = {}
status_list = []
```

敌方快照：

```text
enemy_scale = 1 + (gate - 1) * 0.18

max_hp = floor(enemy.hp * enemy_scale)
atk    = floor(enemy.atk * (1 + (gate - 1) * 0.12))
def    = floor(enemy.def * (1 + (gate - 1) * 0.10))
speed  = floor(enemy.speed * (1 + (gate - 1) * 0.06))
```

---

## 3.2 ATB机制

建议ATB槽：
- `ATB_MAX = 1000`
- 每帧充能：`atb += speed * ATB_SPEED_FACTOR * delta`
- 初始`ATB_SPEED_FACTOR = 100`

角色可行动条件：

```text
if atb >= ATB_MAX and not stunned and alive:
    take_action()
    atb -= ATB_MAX
```

行动顺序：
1. 先比较`atb`溢出值
2. 再比较`speed`
3. 再比较随机微扰（防止完全同速锁死）

---

## 3.3 命中与闪避

命中判定：

```text
HitChance = clamp(0.90 * attacker.hit_rate + skill.accuracy_bonus - defender.dodge_rate, 0.10, 0.99)
```

未命中直接输出`MISS`，不触发伤害与大部分附加效果（可配置“擦伤效果”除外）。

---

## 3.4 暴击判定

```text
CritChance = clamp(attacker.crit_rate - defender.crit_resist, 0.0, 0.75)
CritMul = attacker.crit_damage if crit else 1.0
```

若暂不引入`crit_resist`，默认0。

---

## 3.5 伤害公式（统一）

用于普通攻击、物理技能、异化技能、DoT跳字：

```text
Raw = (attacker.atk * skill.damage_multiplier + skill.base_damage)
Variance = rand(0.95, 1.05)
PenetratedDEF = defender.def * (1 - attacker.armor_pen) * (1 - skill.ignore_def_ratio)
DefFactor = 100.0 / (100.0 + max(0, PenetratedDEF))

SanFactor = get_san_attack_factor(attacker_side_san, attacker_is_enemy)
LinkFactor = get_mental_link_factor(team_mental_link, attacker_is_enemy)
TypeFactor = get_type_counter_factor(attacker_profession, defender_type)  # 初版可固定1.0

Damage = floor(Raw * DefFactor * CritMul * Variance * SanFactor * LinkFactor * TypeFactor)
FinalDamage = max(1, Damage)
```

说明：
- `DefFactor`避免“纯减法”导致高防0伤害问题。
- `Variance`控制手感波动，不宜超过5%。
- `SanFactor/LinkFactor`实现文档中的“理智影响战斗强弱”。

---

## 3.6 治疗与护盾公式

治疗：

```text
HealRaw = caster.atk * skill.heal_multiplier + skill.base_damage
Heal = floor(HealRaw * (1 + caster.heal_power) * rand(0.97, 1.03))
```

护盾（若后续实现）：

```text
Shield = floor((caster.atk * skill.shield_multiplier + skill.base_damage) * (1 + caster.heal_power))
```

---

## 3.7 异常状态与控制概率

状态命中（流血、沉默、眩晕等）统一：

```text
ApplyChance = clamp(BaseChance + attacker.effect_hit - defender.effect_resist, 0.05, 0.95)
```

控制时长受`tenacity`影响：

```text
FinalDuration = max(1, ceil(BaseDuration * (1 - defender.tenacity)))
```

---

## 3.8 DoT/HoT结算

回合末触发（建议每次行动后触发“半回合tick”，实现更平滑也可）：

```text
DotDamage = floor((source.atk * dot_ratio + dot_flat) * (1 - target.dot_resist))
DotDamage = max(1, DotDamage)
```

优先级：
1. 结算当前到期状态
2. 扣减持续回合
3. 清理0回合状态

---

## 3.9 SAN与精神链接对战斗的倍率

结合`play-design`中SAN分段：

| SAN区间 | 我方影响 | 敌方影响 |
| --- | --- | --- |
| 70~100 | 无惩罚 | 无增益 |
| 40~69 | 我方命中`-5%` | 敌方攻击`+8%` |
| 10~39 | 我方命中`-12%`，暴击`-10%` | 敌方攻击`+18%`，控制命中`+10%` |
| 0~9 | 我方攻击`-20%`，20%概率“拒绝行动/误伤队友” | 敌方攻击`+30%` |

精神链接值（`mental_link`）补充修正：

| Mental Link | 我方加成 |
| --- | --- |
| 80~100 | 暴击率`+5%` |
| 50~79 | 无额外加成 |
| 20~49 | 闪避`-5%` |
| 0~19 | 受到伤害`+15%` |

---

## 3.10 异化值与失控机制

适用对象：`CharacterData.char_type == ALTERED`

异化增长：

```text
On skill cast:
ab_gain = character.aberration_per_skill * skill_aberration_factor * aberration_gain_rate
aberration = clamp(aberration + ab_gain, 0, max_aberration)
EventBus.aberration_updated.emit(character_id, aberration)
```

失控阈值：

```text
if aberration >= max_aberration:
    lost_control = true
    EventBus.character_lost_control.emit(character_id)
```

失控收益/代价建议：
- 攻击`+35%`
- 速度`+20%`
- 防御`-25%`
- 目标选择改为“随机任何单位（含队友）”

安抚技能（主角/术士）：

```text
aberration = max(0, aberration - soothe_value)
if aberration < max_aberration * 0.6:
    lost_control = false
```

战斗后衰减：

```text
persist_aberration = floor(current_aberration * 0.35)
```

并写回`PlayerData.owned_characters[char_id].current_aberration`。

---

## 4. 战斗流程（实现顺序）

## 4.1 开战

1. `Combat.setup_combat(enemy_ids)`接收敌人组。
2. 组装我方单位（从`PlayerData.team`读取角色，结合`DataManager.get_character`）。
3. 组装敌方单位（`DataManager.get_enemy`，按黑门层级缩放）。
4. 初始化ATB、冷却、状态、战斗日志。

## 4.2 每帧更新

1. 所有存活单位ATB充能。
2. 出现可行动单位时进入行动结算。
3. 执行Gambit决策，若手动介入则覆盖AI。
4. 结算技能效果、状态、死亡、触发事件信号。
5. 检查胜负。

## 4.3 回合末/行动后结算

1. 扣减技能冷却。
2. DoT/HoT跳字。
3. 异常回合递减。
4. SAN导致的“拒绝行动/误伤”判定。

## 4.4 战斗结束

1. 胜利：掉落计算、经验、异化衰减回写、`EventBus.combat_ended("victory")`
2. 失败：队伍HP归零处理、可能死亡判定、`EventBus.combat_ended("defeat")`
3. 返回`Expedition/Hub`由`GameManager`流转。

---

## 5. 掉落与收益计算（建议）

基础掉落来自`EnemyData.drop_*`，并受关卡与SAN影响：

```text
DropMultiplier = 1 + (gate - 1) * 0.08
RiskBonus = 1.0
if min_san_during_battle < 40: RiskBonus += 0.10
if min_san_during_battle < 10: RiskBonus += 0.15

final_drop = floor(base_drop * DropMultiplier * RiskBonus)
```

稀有物品概率：

```text
FinalRate = clamp(base_rate * (1 + gate * 0.03), 0, 0.85)
```

---

## 6. 代码落地改造清单（按优先级）

### P0（必须）

1. `scripts/autoload/data_manager.gd`
- 修复技能加载：当前`_skills`已定义但未加载路径和接口。
- 增加`DATA_PATHS["skills"] = "res://data/skills/"`。
- 增加`get_skill(id)`、`get_all_skills()`。

2. `scenes/combat/combat.gd`
- 新增战斗单位容器：`_allies`, `_enemies`, `_turn_queue`。
- 实现ATB充能、行动触发、结算调用。
- 接入`EventBus.atb_ready`、`aberration_updated`、`character_lost_control`日志输出。

3. `scripts/autoload/player_data.gd`
- 在`owned_characters`中补`current_aberration`默认值。
- 增加接口：`set_character_hp`、`set_character_aberration`。

### P1（强烈建议）

4. 新增`scripts/combat/combat_calculator.gd`
- 集中放置公式：命中、暴击、伤害、治疗、状态概率、SAN修正。
- 使`combat.gd`只负责流程，不直接写公式。

5. 新增`scripts/combat/battle_unit.gd`
- 封装战斗实体状态（属性快照、状态列表、ATB、冷却、是否失控）。

6. 扩展`scripts/resources/skill_data.gd`
- 增加精度、穿透、持续回合等字段，减少硬编码。

### P2（迭代优化）

7. Gambit条件系统（低血量保护、目标选择策略）
8. 属性克制表（职业分支相性）
9. 战斗回放日志结构化（便于调试与自动化测试）

---

## 7. 参数校准建议（首轮）

1. 角色TTK（击杀时间）
- 普通战：我方单体3~5次行动击杀一名同级敌人。
- BOSS战：核心敌人约20~30次总行动击杀。

2. 生存压力
- 盾卫承伤占比建议`35%~45%`。
- 无治疗阵容可打通普通战，但连续战斗会显著亏损。

3. 异化风险收益
- 异格者满异化后DPS提升明显（>25%），但失控概率必须真实威胁队伍。

4. SAN影响强度
- SAN惩罚应“可感知但非立刻崩盘”，把崩盘留给`SAN<10`区间。

---

## 8. 当前版本可直接实现的最小闭环（MVP）

1. 只用现有字段实现ATB+伤害+暴击+失控：
- `CharacterData`已有字段足够跑通第一版。
- `SkillData`先用`base_damage + damage_multiplier`。

2. 先不做复杂Buff系统，仅做：
- `stun`, `silence`, `bleed(dot)`三种状态。

3. SAN影响先做两档：
- `SAN>=40`正常
- `SAN<40`敌方攻击`+15%`，我方命中`-10%`

4. 角色异化先实现：
- 异格者施放技能加异化
- 达阈值触发失控并随机攻击
- 战后异化衰减写回

---

以上方案可以直接对接当前项目结构，并支持后续扩展到完整的“职业流派+Gambit+状态生态”。
