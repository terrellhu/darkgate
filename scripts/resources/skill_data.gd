## 技能数据模板
class_name SkillData
extends Resource

## 技能类型
enum SkillType {
	PHYSICAL,       ## 物理攻击
	ABERRATION,     ## 异化技能（异格者专属）
	HEAL,           ## 治疗
	BUFF,           ## 增益
	DEBUFF,         ## 减益
	CONTROL,        ## 控制
	PASSIVE,        ## 被动
}

## 目标类型
enum TargetType {
	SINGLE_ENEMY,   ## 单体敌人
	ALL_ENEMIES,    ## 全体敌人
	SINGLE_ALLY,    ## 单体队友
	ALL_ALLIES,     ## 全体队友
	SELF,           ## 自身
}

@export var id: String = ""
@export var display_name: String = ""
@export var skill_type: SkillType = SkillType.PHYSICAL
@export var target_type: TargetType = TargetType.SINGLE_ENEMY
@export_multiline var description: String = ""

@export_group("数值")
@export var base_damage: int = 0        ## 基础伤害/治疗量
@export var damage_multiplier: float = 1.0  ## 攻击力倍率
@export var cooldown: int = 0           ## 冷却回合数
@export var aberration_cost: float = 0.0    ## 异化值消耗（异格者）

@export_group("特效")
@export var bleed_chance: float = 0.0   ## 流血概率
@export var stun_chance: float = 0.0    ## 眩晕概率
@export var silence_chance: float = 0.0 ## 沉默概率
@export var dot_damage: int = 0         ## 持续伤害
@export var dot_duration: int = 0       ## 持续回合数
