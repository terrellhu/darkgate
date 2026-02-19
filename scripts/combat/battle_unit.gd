## 战斗单位实体
## 战斗期间的运行时快照，同时用于友方和敌方
class_name BattleUnit
extends RefCounted

const CharacterConfigService := preload("res://scripts/character/character_config_service.gd")

## ========== 身份 ==========
var unit_id: String = ""       ## 战斗内唯一标识，如 "ally_char_assault_01" / "enemy_0_enemy_abomination_01"
var source_id: String = ""     ## 原始数据 ID
var display_name: String = ""
var is_ally: bool = true

## ========== 核心属性（快照） ==========
var max_hp: int = 1
var current_hp: int = 1
var atk: int = 1
var def_stat: int = 0
var speed: int = 1
var crit_rate: float = 0.05
var crit_damage: float = 1.5
var hit_rate: float = 1.0
var dodge_rate: float = 0.0
var armor_pen: float = 0.0
var effect_hit: float = 0.0
var effect_resist: float = 0.0
var heal_power: float = 0.0

## ========== ATB ==========
var atb: float = 0.0

## ========== 异化（友方专用） ==========
var max_aberration: float = 0.0
var current_aberration: float = 0.0
var aberration_per_skill: float = 0.0
var lost_control: bool = false

## ========== 状态效果 ==========
var status_effects: Array[StatusEffect] = []

## ========== 技能与冷却 ==========
var skills: Array[SkillData] = []
var cooldowns: Dictionary = {}  ## { skill_id: 剩余回合数 }

## ========== 存活 / 护盾 ==========
var alive: bool = true
var shield_hp: int = 0

## ========== 掉落（敌方专用） ==========
var drop_xp: int = 0
var drop_bio_electricity: int = 0
var drop_nano_alloy: int = 0
var drop_hashrate: int = 0
var drop_item_ids: Array[String] = []
var drop_item_rates: Array[float] = []

## ========== 失控恢复用基准 ==========
var _base_atk: int = 0
var _base_def_stat: int = 0
var _base_speed: int = 0


## 保存失控前的基准属性
func snapshot_base_stats() -> void:
	_base_atk = atk
	_base_def_stat = def_stat
	_base_speed = speed


## 进入失控状态
func enter_lost_control() -> void:
	if lost_control:
		return
	lost_control = true
	atk = int(_base_atk * (1.0 + CombatConfig.LOST_CONTROL_ATK_BONUS))
	speed = int(_base_speed * (1.0 + CombatConfig.LOST_CONTROL_SPD_BONUS))
	def_stat = int(_base_def_stat * (1.0 - CombatConfig.LOST_CONTROL_DEF_PENALTY))


## 退出失控状态
func exit_lost_control() -> void:
	if not lost_control:
		return
	lost_control = false
	atk = _base_atk
	def_stat = _base_def_stat
	speed = _base_speed


## 判断是否被眩晕
func is_stunned() -> bool:
	for e in status_effects:
		if e.type == StatusEffect.Type.STUN:
			return true
	return false


## 判断是否被沉默
func is_silenced() -> bool:
	for e in status_effects:
		if e.type == StatusEffect.Type.SILENCE:
			return true
	return false


## 获取嘲讽强制目标（无嘲讽返回空字符串）
func get_taunt_target() -> String:
	for e in status_effects:
		if e.type == StatusEffect.Type.TAUNT:
			return e.taunt_target_id
	return ""


# ========== 工厂方法 ==========

## 从友方角色构建
static func from_ally(char_id: String) -> BattleUnit:
	var char_data: CharacterData = DataManager.get_character(char_id)
	if char_data == null:
		push_error("BattleUnit: character not found: %s" % char_id)
		return null
	var runtime: Dictionary = PlayerData.get_character_runtime(char_id)
	var stats: Dictionary = PlayerData.get_character_stats(char_id)
	var skill_list: Array[SkillData] = PlayerData.get_character_skills(char_id)

	var unit := BattleUnit.new()
	unit.unit_id = "ally_%s" % char_id
	unit.source_id = char_id
	unit.display_name = char_data.display_name
	unit.is_ally = true

	unit.max_hp = maxi(1, int(stats.get("max_hp", 1)))
	var saved_hp: int = int(runtime.get("current_hp", unit.max_hp))
	unit.current_hp = clampi(saved_hp, 1, unit.max_hp)
	unit.atk = maxi(1, int(stats.get("atk", 1)))
	unit.def_stat = maxi(0, int(stats.get("def", 0)))
	unit.speed = maxi(CombatConfig.MIN_SPEED, int(stats.get("speed", 1)))
	unit.crit_rate = float(stats.get("crit_rate", 0.05))
	unit.crit_damage = float(stats.get("crit_damage", 1.5))
	unit.hit_rate = float(stats.get("hit_rate", 1.0))
	unit.dodge_rate = float(stats.get("dodge_rate", 0.0))
	unit.armor_pen = float(stats.get("armor_pen", 0.0))
	unit.effect_hit = float(stats.get("effect_hit", 0.0))
	unit.effect_resist = float(stats.get("effect_resist", 0.0))
	unit.heal_power = float(stats.get("heal_power", 0.0))

	unit.max_aberration = char_data.max_aberration
	unit.current_aberration = float(runtime.get("current_aberration", 0.0))
	unit.aberration_per_skill = char_data.aberration_per_skill

	unit.skills = skill_list
	for skill in skill_list:
		unit.cooldowns[skill.id] = 0

	unit.snapshot_base_stats()
	return unit


## 从敌人配置 + 黑门缩放构建
static func from_enemy(enemy_id: String, gate: int, index: int) -> BattleUnit:
	var enemy_data: EnemyData = DataManager.get_enemy(enemy_id)
	if enemy_data == null:
		push_error("BattleUnit: enemy not found: %s" % enemy_id)
		return null

	var hp_scale := 1.0 + maxf(0, gate - 1) * CombatConfig.ENEMY_HP_SCALE_PER_GATE
	var atk_scale := 1.0 + maxf(0, gate - 1) * CombatConfig.ENEMY_ATK_SCALE_PER_GATE
	var def_scale := 1.0 + maxf(0, gate - 1) * CombatConfig.ENEMY_DEF_SCALE_PER_GATE
	var spd_scale := 1.0 + maxf(0, gate - 1) * CombatConfig.ENEMY_SPEED_SCALE_PER_GATE

	var unit := BattleUnit.new()
	unit.unit_id = "enemy_%d_%s" % [index, enemy_id]
	unit.source_id = enemy_id
	unit.display_name = enemy_data.display_name
	unit.is_ally = false

	unit.max_hp = maxi(1, int(floor(enemy_data.hp * hp_scale)))
	unit.current_hp = unit.max_hp
	unit.atk = maxi(1, int(floor(enemy_data.atk * atk_scale)))
	unit.def_stat = maxi(0, int(floor(enemy_data.def * def_scale)))
	unit.speed = maxi(CombatConfig.MIN_SPEED, int(floor(enemy_data.speed * spd_scale)))
	unit.crit_rate = enemy_data.crit_rate
	unit.crit_damage = enemy_data.crit_damage
	unit.hit_rate = enemy_data.hit_rate
	unit.dodge_rate = enemy_data.dodge_rate
	unit.effect_resist = enemy_data.effect_resist

	unit.skills = DataManager.get_skills_by_ids(enemy_data.skill_ids)
	for skill in unit.skills:
		unit.cooldowns[skill.id] = 0

	unit.drop_xp = enemy_data.drop_xp
	unit.drop_bio_electricity = enemy_data.drop_bio_electricity
	unit.drop_nano_alloy = enemy_data.drop_nano_alloy
	unit.drop_hashrate = enemy_data.drop_hashrate
	unit.drop_item_ids = enemy_data.drop_item_ids.duplicate()
	unit.drop_item_rates = enemy_data.drop_item_rates.duplicate()

	unit.snapshot_base_stats()
	return unit
