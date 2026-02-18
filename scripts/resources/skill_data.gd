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
@export var priority: int = 0   ## Gambit AI 优先级（数值越高越优先选用；0 为默认）

@export_group("数值")
@export var base_damage: int = 0            ## 基础伤害/治疗量
@export var damage_multiplier: float = 1.0  ## 攻击力倍率（伤害类）
@export var heal_multiplier: float = 0.0    ## 攻击力倍率（治疗类，HEAL 技能填此项）
@export var shield_multiplier: float = 0.0  ## 攻击力倍率（护盾类，暂预留）
@export var cooldown: int = 0               ## 冷却回合数
@export var aberration_cost: float = 0.0    ## 异化值消耗（异格者）
@export var accuracy_bonus: float = 0.0     ## 命中加成（叠加到施法者 hit_rate 之上）
@export var ignore_def_ratio: float = 0.0   ## 护甲忽视比例（0~1，叠加到施法者 armor_pen 之上）

@export_group("特效")
@export var bleed_chance: float = 0.0   ## 流血概率
@export var stun_chance: float = 0.0    ## 眩晕概率
@export var silence_chance: float = 0.0 ## 沉默概率
@export var taunt_chance: float = 0.0   ## 嘲讽概率（使被命中目标下回合强制攻击施法者）
@export var dot_damage: int = 0         ## 持续伤害
@export var dot_duration: int = 0       ## 持续回合数（DoT/控制/Buff/嘲讽 共用）
