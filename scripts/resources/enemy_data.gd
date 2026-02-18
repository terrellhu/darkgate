## 敌人数据模板
class_name EnemyData
extends Resource

## 敌人类型
enum EnemyType {
	ABOMINATION,    ## 初级孽体（丧尸化男性）
	MUTANT_BEAST,   ## 变异野兽
	MECH_ABOM,      ## 机械孽体
	MIND_CONTROLLER,## 精神控制者
	ELDRITCH,       ## 不可名状之物
	BOSS,           ## BOSS
}

@export var id: String = ""
@export var display_name: String = ""
@export var enemy_type: EnemyType = EnemyType.ABOMINATION
@export_multiline var description: String = ""

## 出现在哪些黑门（1-9）
@export var gate_range: Array[int] = []

## 基础属性
@export_group("属性")
@export var hp: int = 50
@export var atk: int = 8
@export var def: int = 3
@export var speed: int = 8

## 掉落
@export_group("掉落")
@export var drop_bio_electricity: int = 0
@export var drop_nano_alloy: int = 0
@export var drop_hashrate: int = 0
@export var drop_item_ids: Array[String] = []
@export var drop_item_rates: Array[float] = []

## 技能
@export_group("技能")
@export var skill_ids: Array[String] = []
