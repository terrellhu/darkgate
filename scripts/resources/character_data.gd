## 角色数据模板
## 定义角色的基础属性
class_name CharacterData
extends Resource

## 角色职业
## 前三项（ASSAULT/SHIELD/EXECUTIONER）战斗风格稳定，异化积累速度较慢
## 后三项（PLAGUE/PSION/BERSERKER）主动利用异化能力，积累速度快、上限高
enum Profession {
	ASSAULT,       ## 突击手
	SHIELD,        ## 盾卫
	EXECUTIONER,   ## 处刑人
	PLAGUE,        ## 瘟疫使者
	PSION,         ## 脑波术士
	BERSERKER,     ## 狂暴体
}

## 稀有度
enum Rarity { N, R, SR, SSR }

@export var id: String = ""
@export var display_name: String = ""
@export var profession: Profession = Profession.ASSAULT
@export var rarity: Rarity = Rarity.N
@export_multiline var description: String = ""

## 基础属性
@export_group("基础属性")
@export var base_hp: int = 100
@export var base_atk: int = 10
@export var base_def: int = 5
@export var base_speed: int = 10
@export var base_crit_rate: float = 0.05
@export var base_crit_damage: float = 1.5

## 次属性（战斗公式用，默认值覆盖大多数职业，详见 docs/profession-system-design.md §4）
@export var base_hit_rate: float = 1.0       ## 命中修正（默认1.0，不建议低于0.85）
@export var base_dodge_rate: float = 0.02    ## 闪避概率（上限0.60）
@export var base_armor_pen: float = 0.0      ## 护甲穿透比例（0~1）
@export var base_effect_hit: float = 0.0     ## 效果命中（影响控制/减益施加概率）
@export var base_effect_resist: float = 0.0  ## 效果抵抗（影响控制/减益承受概率）
@export var base_heal_power: float = 0.0     ## 治疗加成比例（PSION 职业建议 0.1）

## 成长参数（用于等级/星级成长）
@export_group("成长参数")
@export var hp_growth: float = 10.0
@export var atk_growth: float = 2.0
@export var def_growth: float = 1.0
@export var speed_growth: float = 0.2
@export var star_growth_rate: float = 0.08

## 异化属性（所有角色在黑门中均受异化影响，详见 docs/profession-system-design.md）
## ASSAULT/SHIELD/EXECUTIONER：环境被动积累，积累速度慢，上限低
## PLAGUE/PSION/BERSERKER：主动利用异化能力，积累速度快，上限高
@export_group("异化属性")
@export var max_aberration: float = 60.0    ## 异化值上限（异化系职业建议 100.0）
@export var aberration_per_skill: float = 5.0  ## 每次释放技能累积的异化值（异化系职业建议 15~25）

## 技能
@export_group("技能")
@export var skill_ids: Array[String] = []

## 初始运行时数据（招募后写入PlayerData）
@export_group("初始运行时")
@export var initial_level: int = 1
@export var initial_stars: int = 1
@export var initial_equipment_ids: Array[String] = []
@export var initial_equipment_slots: Dictionary = {}
