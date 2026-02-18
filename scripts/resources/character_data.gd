## 角色数据模板
## 定义角色的基础属性
class_name CharacterData
extends Resource

## 角色职业类型
enum Profession {
	## 女武神系
	ASSAULT,       ## 突击手
	SHIELD,        ## 盾卫
	EXECUTIONER,   ## 处刑人
	## 异格者系
	PLAGUE,        ## 瘟疫使者
	PSION,         ## 脑波术士
	BERSERKER,     ## 狂暴体
}

## 稀有度
enum Rarity { N, R, SR, SSR }

## 角色性别/类型
enum CharType { VALKYRIE, ALTERED }

@export var id: String = ""
@export var display_name: String = ""
@export var char_type: CharType = CharType.VALKYRIE
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

## 成长参数（用于等级/星级成长）
@export_group("成长参数")
@export var hp_growth: float = 10.0
@export var atk_growth: float = 2.0
@export var def_growth: float = 1.0
@export var speed_growth: float = 0.2
@export var star_growth_rate: float = 0.08

## 异格者专属
@export_group("异化属性")
@export var max_aberration: float = 100.0  ## 异化值上限
@export var aberration_per_skill: float = 15.0  ## 每次释放技能累积的异化值

## 技能
@export_group("技能")
@export var skill_ids: Array[String] = []

## 初始运行时数据（招募后写入PlayerData）
@export_group("初始运行时")
@export var initial_level: int = 1
@export var initial_stars: int = 1
@export var initial_equipment_ids: Array[String] = []
@export var initial_equipment_slots: Dictionary = {}
