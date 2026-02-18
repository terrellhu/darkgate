## 角色配置服务
## 从角色配置 + 运行时数据构建可用属性与技能
class_name CharacterConfigService
extends RefCounted

const EquipmentService := preload("res://scripts/character/equipment_service.gd")


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

	var equip_hp := 0
	var equip_atk := 0
	var equip_def := 0
	var equip_speed := 0
	var equip_crit_rate := 0.0

	for item_id in equip_ids:
		var item: ItemData = DataManager.get_item(item_id)
		if item == null:
			continue
		equip_hp += item.equip_hp
		equip_atk += item.equip_atk
		equip_def += item.equip_def
		equip_speed += item.equip_speed
		equip_crit_rate += item.equip_crit_rate

	var star_bonus := 1.0 + float(stars - 1) * char_data.star_growth_rate
	var lv := float(level - 1)

	var max_hp := int(floor((char_data.base_hp + lv * char_data.hp_growth + equip_hp) * star_bonus))
	var atk := int(floor((char_data.base_atk + lv * char_data.atk_growth + equip_atk) * star_bonus))
	var def := int(floor((char_data.base_def + lv * char_data.def_growth + equip_def) * star_bonus))
	var speed := int(floor((char_data.base_speed + lv * char_data.speed_growth + equip_speed)))

	return {
		"max_hp": maxi(1, max_hp),
		"atk": maxi(1, atk),
		"def": maxi(0, def),
		"speed": maxi(1, speed),
		"crit_rate": clampf(char_data.base_crit_rate + equip_crit_rate, 0.0, 0.95),
		"crit_damage": maxf(1.1, char_data.base_crit_damage),
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
