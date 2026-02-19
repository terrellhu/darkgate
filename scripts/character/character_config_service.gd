## 角色配置服务
## 从角色配置 + 运行时数据构建可用属性与技能
class_name CharacterConfigService
extends RefCounted

const EquipmentService := preload("res://scripts/character/equipment_service.gd")

## 各职业的推荐成长参数默认基准（参考 docs/profession-system-design.md §3）
## 用于：①新角色配置时的参考 ②旧档职业字段补齐（当角色配置缺失时回退）
## 不作为强制约束，每个角色 .tres 文件可独立覆盖
const PROFESSION_DEFAULTS := {
	CharacterData.Profession.ASSAULT:     { "hp_growth": 11.0, "atk_growth": 3.2, "def_growth": 1.4, "speed_growth": 0.35, "base_crit_rate": 0.10 },
	CharacterData.Profession.SHIELD:      { "hp_growth": 16.0, "atk_growth": 1.6, "def_growth": 2.6, "speed_growth": 0.20, "base_crit_rate": 0.03 },
	CharacterData.Profession.EXECUTIONER: { "hp_growth": 12.0, "atk_growth": 2.8, "def_growth": 1.5, "speed_growth": 0.30, "base_crit_rate": 0.15 },
	CharacterData.Profession.PLAGUE:      { "hp_growth": 10.0, "atk_growth": 3.0, "def_growth": 1.2, "speed_growth": 0.28, "base_crit_rate": 0.07 },
	CharacterData.Profession.PSION:       { "hp_growth":  9.0, "atk_growth": 3.4, "def_growth": 1.1, "speed_growth": 0.33, "base_crit_rate": 0.09 },
	CharacterData.Profession.BERSERKER:   { "hp_growth": 13.0, "atk_growth": 3.8, "def_growth": 1.0, "speed_growth": 0.25, "base_crit_rate": 0.11 },
}


## 为新获得角色构建运行时初始数据
static func build_new_runtime(char_id: String) -> Dictionary:
	var char_data: CharacterData = DataManager.get_character(char_id)
	if char_data == null:
		return {
			"level": 1,
			"stars": 1,
			"current_hp": -1,
			"current_aberration": 0.0,
			"equipment": EquipmentService.create_empty_hero_equipment(),
			"skill_ids": [],
			"xp": 0,
			"enhancements": {},
			"tree_unlocks": [],
		}

	var initial_equipment := EquipmentService.assign_items_to_slots(
		char_data.initial_equipment_ids,
		char_data.initial_equipment_slots
	)

	var runtime := {
		"level": maxi(1, char_data.initial_level),
		"stars": maxi(1, char_data.initial_stars),
		"current_hp": -1,
		"current_aberration": 0.0,
		"equipment": initial_equipment,
		"skill_ids": char_data.skill_ids.duplicate(),
		"xp": 0,
		"enhancements": {},
		"tree_unlocks": [],
	}

	var stats := calculate_stats(char_data, runtime)
	runtime["current_hp"] = int(stats.get("max_hp", char_data.base_hp))
	return runtime


## 规范化旧存档角色数据（补齐新字段）
static func normalize_runtime(char_id: String, runtime: Dictionary) -> Dictionary:
	var normalized: Dictionary = runtime.duplicate(true)
	var char_data: CharacterData = DataManager.get_character(char_id)

	if not normalized.has("level"):
		normalized["level"] = 1 if char_data == null else maxi(1, char_data.initial_level)
	else:
		normalized["level"] = maxi(1, int(normalized["level"]))

	if not normalized.has("stars"):
		normalized["stars"] = 1 if char_data == null else maxi(1, char_data.initial_stars)
	else:
		normalized["stars"] = maxi(1, int(normalized["stars"]))

	if not normalized.has("equipment"):
		if char_data == null:
			normalized["equipment"] = EquipmentService.create_empty_hero_equipment()
		else:
			normalized["equipment"] = EquipmentService.assign_items_to_slots(
				char_data.initial_equipment_ids,
				char_data.initial_equipment_slots
			)
	else:
		normalized["equipment"] = EquipmentService.normalize_hero_equipment(normalized["equipment"])

	if not normalized.has("skill_ids"):
		normalized["skill_ids"] = [] if char_data == null else char_data.skill_ids.duplicate()
	else:
		normalized["skill_ids"] = Array(normalized["skill_ids"], TYPE_STRING, "", null)

	if not normalized.has("current_aberration"):
		normalized["current_aberration"] = 0.0
	else:
		normalized["current_aberration"] = float(normalized["current_aberration"])

	if not normalized.has("xp"):
		normalized["xp"] = 0
	else:
		normalized["xp"] = maxi(0, int(normalized["xp"]))

	if not normalized.has("enhancements"):
		normalized["enhancements"] = {}

	if not normalized.has("tree_unlocks"):
		normalized["tree_unlocks"] = []

	var stats := calculate_stats(char_data, normalized)
	var max_hp := int(stats.get("max_hp", 1))
	if not normalized.has("current_hp") or int(normalized["current_hp"]) <= 0:
		normalized["current_hp"] = max_hp
	else:
		normalized["current_hp"] = clampi(int(normalized["current_hp"]), 1, max_hp)

	return normalized


## 计算角色最终属性（配置驱动）
static func calculate_stats(char_data: CharacterData, runtime: Dictionary) -> Dictionary:
	if char_data == null:
		return {}

	var level: int = maxi(1, int(runtime.get("level", char_data.initial_level)))
	var stars: int = maxi(1, int(runtime.get("stars", char_data.initial_stars)))
	var equipment_raw: Variant = runtime.get("equipment", null)
	if equipment_raw == null:
		equipment_raw = EquipmentService.assign_items_to_slots(
			char_data.initial_equipment_ids,
			char_data.initial_equipment_slots
		)
	var equip_ids := EquipmentService.get_equipped_item_ids(
		EquipmentService.normalize_hero_equipment(equipment_raw)
	)

	var enhancements: Dictionary = runtime.get("enhancements", {})
	var equip_hp := 0
	var equip_atk := 0
	var equip_def := 0
	var equip_speed := 0
	var equip_crit_rate := 0.0

	for item_id in equip_ids:
		var item: ItemData = DataManager.get_item(item_id)
		if item == null:
			continue
		var enhance_level: int = int(enhancements.get(item_id, 0))
		var enhance_mult := 1.0 + enhance_level * 0.08
		equip_hp += int(floor(item.equip_hp * enhance_mult))
		equip_atk += int(floor(item.equip_atk * enhance_mult))
		equip_def += int(floor(item.equip_def * enhance_mult))
		equip_speed += int(floor(item.equip_speed * enhance_mult))
		equip_crit_rate += item.equip_crit_rate

	# 星级加成：HP满额，ATK/DEF 80%，Speed 30%（详见 docs/profession-system-design.md §3）
	var sgr := char_data.star_growth_rate
	var star_extra := float(stars - 1)
	var hp_star  := 1.0 + star_extra * sgr
	var ad_star  := 1.0 + star_extra * sgr * 0.8
	var spd_star := 1.0 + star_extra * sgr * 0.3
	var lv := float(level - 1)

	var max_hp := int(floor((char_data.base_hp  + lv * char_data.hp_growth  + equip_hp)    * hp_star))
	var atk    := int(floor((char_data.base_atk + lv * char_data.atk_growth + equip_atk)   * ad_star))
	var def    := int(floor((char_data.base_def + lv * char_data.def_growth + equip_def)   * ad_star))
	var speed  := int(floor((char_data.base_speed + lv * char_data.speed_growth + equip_speed) * spd_star))

	return {
		## 主属性
		"max_hp":      maxi(1, max_hp),
		"atk":         maxi(1, atk),
		"def":         maxi(0, def),
		"speed":       maxi(1, speed),
		## 暴击
		"crit_rate":   clampf(char_data.base_crit_rate + equip_crit_rate, 0.0, 0.75),
		"crit_damage": maxf(1.1, char_data.base_crit_damage),
		## 次属性（直接来自角色配置，不参与成长/装备加成，战斗层Buff再叠加）
		"hit_rate":      clampf(char_data.base_hit_rate, 0.0, 1.0),
		"dodge_rate":    clampf(char_data.base_dodge_rate, 0.0, 0.60),
		"armor_pen":     clampf(char_data.base_armor_pen, 0.0, 1.0),
		"effect_hit":    char_data.base_effect_hit,
		"effect_resist": char_data.base_effect_resist,
		"heal_power":    char_data.base_heal_power,
	}


## 获取角色技能ID（优先运行时配置）
static func get_skill_ids(char_id: String, runtime: Dictionary = {}) -> Array[String]:
	var char_data: CharacterData = DataManager.get_character(char_id)
	if char_data == null:
		return []
	if runtime.has("skill_ids"):
		return _to_string_array(runtime["skill_ids"])
	return char_data.skill_ids.duplicate()


## 获取角色技能配置对象
static func get_skills(char_id: String, runtime: Dictionary = {}) -> Array[SkillData]:
	var skill_ids := get_skill_ids(char_id, runtime)
	return DataManager.get_skills_by_ids(skill_ids)


static func _to_string_array(value: Variant) -> Array[String]:
	if value is Array:
		return Array(value, TYPE_STRING, "", null)
	return []
