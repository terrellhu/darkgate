# 职业体系设计

本文档固化职业（Profession）的设计边界、默认数值基准、装备限制规则，以及职业与战斗机制的关系。代码层的实现依据见 [scripts/resources/character_data.gd](../scripts/resources/character_data.gd) 和 [scripts/character/character_config_service.gd](../scripts/character/character_config_service.gd)。

**所有可招募角色均为女性**；主角（玩家）为唯一男性，不参与编队，不在职业枚举内。

---

## 1. 职业（Profession）

职业共 6 个，决定角色的战斗定位、成长曲线与装备白名单。不再区分"类型"——`CharType` 枚举已移除，类型信息改由职业本身和 `max_aberration > 0` 隐式表达。

### 物理职业（稳定型）

进入黑门时受异化环境被动影响，`aberration_per_skill` 较低，`max_aberration` 上限较低（更快触发失控风险，须注意节奏控制）。

| 枚举值 | 中文名 | 战斗定位 | 行为特征 |
| --- | --- | --- | --- |
| `ASSAULT` | 突击手 | 输出 | 攻击速度快，技能带流血/DOT，单体爆发 |
| `SHIELD` | 盾卫 | 坦克 | 高血高防，技能带嘲讽/眩晕，承伤核心 |
| `EXECUTIONER` | 处刑人 | 爆发 | 暴击倍率高，技能穿甲，擅长斩杀低血量目标 |

### 异化职业（高风险型）

已适应异化能量，主动将其转化为战斗力。`aberration_per_skill` 较高，`max_aberration` 上限较高，可承受更多异化积累，且部分技能需要消耗异化值激活。

| 枚举值 | 中文名 | 战斗定位 | 行为特征 |
| --- | --- | --- | --- |
| `PLAGUE` | 瘟疫使者 | 腐蚀/DoT | 技能叠加持续伤害与减益，擅长多目标消耗 |
| `PSION` | 脑波术士 | 控制 | 技能带沉默/控制，消耗异化值释放大技能 |
| `BERSERKER` | 狂暴体 | 失控爆发 | 异化积累最快，失控后攻击与速度大幅提升，伴随随机攻击风险 |

---

## 2. 异化机制（所有职业适用）

**核心设定**：黑门内部弥漫着异化粒子，任何进入黑门的队员都会持续受到异化侵蚀。
物理职业的身体对此缺乏适应性，更容易在达到阈值后失去控制；异化职业则将这种力量转化为可用能量，容量更高，且可以主动消耗。

### 异化值参数基准（各角色 `.tres` 配置）

| 职业分组 | max_aberration | aberration_per_skill | 设计意图 |
| --- | ---: | ---: | --- |
| ASSAULT | 60 | 5 | 被动积累，中等压力 |
| SHIELD | 50 | 4 | 最难失控，但阈值低需谨慎 |
| EXECUTIONER | 65 | 6 | 高爆发伴随高异化风险 |
| PLAGUE | 90 | 15 | 腐蚀能量来自异化，主动驾驭 |
| PSION | 100 | 20 | 以异化为技能燃料，容量最大 |
| BERSERKER | 100 | 25 | 异化积累最激进，失控收益最大 |

### 失控规则（所有职业统一）

```
if aberration >= max_aberration:
    lost_control = true
    攻击+35%，速度+20%，防御-25%
    目标选择随机化（含队友）
```

各职业失控的叙事特征不同：

| 职业 | 失控表现 |
| --- | --- |
| ASSAULT/EXECUTIONER | 陷入战斗狂热，攻击最近的目标 |
| SHIELD | 护盾本能失控，开始推挡所有单位（含队友） |
| PLAGUE | 毒素扩散失控，DoT效果蔓延至队友 |
| PSION | 精神波随机释放，控制效果乱序施加 |
| BERSERKER | 完全兽化，目标全随机，收益最大但风险最高 |

**主角"精神安抚"**可对任意职业角色生效，压制异化值至 `max_aberration * 0.6` 以下时解除失控。

### 战斗后衰减

```
persist_aberration = floor(current_aberration * 0.35)
```

写回 `PlayerData.owned_characters[char_id].current_aberration`，延续到下一场战斗。

---

## 3. 职业成长参数默认基准

以下参数是各职业的**推荐填写范围**，不作硬性约束（每个角色 `.tres` 文件可自定义）。
代码中 `CharacterConfigService.PROFESSION_DEFAULTS` 存储此表，供配置者参考和旧档补齐使用。

| 职业 | base_hp | hp_growth | atk_growth | def_growth | speed_growth | base_crit_rate |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| ASSAULT | 110~130 | 11.0 | 3.2 | 1.4 | 0.35 | 0.08~0.12 |
| SHIELD | 180~220 | 16.0 | 1.6 | 2.6 | 0.20 | 0.02~0.05 |
| EXECUTIONER | 100~120 | 12.0 | 2.8 | 1.5 | 0.30 | 0.12~0.18 |
| PLAGUE | 90~110 | 10.0 | 3.0 | 1.2 | 0.28 | 0.05~0.10 |
| PSION | 75~95 | 9.0 | 3.4 | 1.1 | 0.33 | 0.06~0.12 |
| BERSERKER | 120~140 | 13.0 | 3.8 | 1.0 | 0.25 | 0.08~0.15 |

**星级加成差异化规则（代码层固定）：**

```text
hp_star_factor    = 1 + (stars - 1) * star_growth_rate          # 满额加成
atk_star_factor   = 1 + (stars - 1) * star_growth_rate * 0.8   # 80%
def_star_factor   = 1 + (stars - 1) * star_growth_rate * 0.8   # 80%
speed_star_factor = 1 + (stars - 1) * star_growth_rate * 0.3   # 30%
```

---

## 4. 次属性默认基准

次属性在 `CharacterData` 中以 `base_*` 形式配置，各职业建议值：

| 职业 | hit_rate | dodge_rate | armor_pen | effect_hit | effect_resist | heal_power |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| ASSAULT | 1.00 | 0.04 | 0.05 | 0.0 | 0.0 | 0.0 |
| SHIELD | 0.95 | 0.01 | 0.0 | 0.0 | 0.10 | 0.0 |
| EXECUTIONER | 1.00 | 0.03 | 0.15 | 0.0 | 0.0 | 0.0 |
| PLAGUE | 0.95 | 0.02 | 0.0 | 0.15 | 0.0 | 0.0 |
| PSION | 0.95 | 0.03 | 0.0 | 0.20 | 0.05 | 0.10 |
| BERSERKER | 0.90 | 0.02 | 0.05 | 0.0 | 0.05 | 0.0 |

---

## 5. 装备限制规则

`ItemData` 中通过 `profession_whitelist` 限制职业：

- `profession_whitelist: Array[int]` — 允许穿戴的职业枚举值列表；空数组表示不限制职业

**典型装备限制示例：**

| 装备类别 | 限制逻辑 |
| --- | --- |
| 重型护甲 | `profession_whitelist = [SHIELD]` |
| 异化催化核心 | `profession_whitelist = [PLAGUE, PSION, BERSERKER]` |
| 通用武器 | `profession_whitelist = []`（不限制） |

---

## 6. 职业与技能类型的关系

职业对可用技能没有代码强制限制（技能在角色 `skill_ids` 里配置即可）。
以下为设计规范，配置时遵守：

| 职业 | 推荐技能类型 | 不建议使用 |
| --- | --- | --- |
| ASSAULT | PHYSICAL | HEAL、BUFF |
| SHIELD | PHYSICAL、BUFF | ABERRATION |
| EXECUTIONER | PHYSICAL | HEAL、ABERRATION |
| PLAGUE | DEBUFF、PHYSICAL | — |
| PSION | CONTROL、ABERRATION、HEAL | — |
| BERSERKER | ABERRATION、PHYSICAL | HEAL |

---

## 7. 未来扩展预留

以下内容当前不实现，列出作为后续模块6的接口预留：

- **转职**：ASSAULT → EXECUTIONER 的分支专精
- **职业被动**：职业层面的全局效果（如 SHIELD 携带时全队防御+X%）
- **Gambit 优先级**：`SkillData.priority` 字段已实现（`int`，数值越高越优先），AI 决策排序逻辑待模块6实现
- **职业克制表**：各职业对敌人类型的属性克制系数（P2 阶段实现）
- **异化阶段收益**：异化职业在达到特定阈值（如 60%/80%）时获得阶段性增益，而非只有失控一个节点
