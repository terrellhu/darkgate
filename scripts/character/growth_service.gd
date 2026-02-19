## 成长计算服务
## 纯静态函数，计算经验、升级、强化、星升等
class_name GrowthService
extends RefCounted

const XP_BASE := 100         ## 1级升2级所需XP
const XP_SCALE := 1.25       ## 每级XP倍率
const MAX_LEVEL := 30
const MAX_STARS := 5
const MAX_ENHANCE_LEVEL := 10


## 计算指定等级升到下一级所需的经验值
static func xp_to_next_level(current_level: int) -> int:
	if current_level >= MAX_LEVEL:
		return 0
	return int(ceil(XP_BASE * pow(XP_SCALE, current_level - 1)))


## 尝试连续升级，返回升了几级
static func try_level_up(char_id: String) -> int:
	var runtime: Dictionary = PlayerData.owned_characters.get(char_id, {})
	if runtime.is_empty():
		return 0
	var levels_gained := 0
	while int(runtime.get("level", 1)) < MAX_LEVEL:
		var needed := xp_to_next_level(int(runtime["level"]))
		if needed <= 0 or int(runtime.get("xp", 0)) < needed:
			break
		runtime["xp"] = int(runtime["xp"]) - needed
		runtime["level"] = int(runtime["level"]) + 1
		levels_gained += 1
	if levels_gained > 0:
		recalculate_stats(char_id)
	return levels_gained


## 重新计算角色属性（等级/装备/星级变动后调用）
static func recalculate_stats(char_id: String) -> void:
	var char_data: CharacterData = DataManager.get_character(char_id)
	if char_data == null:
		return
	var runtime: Dictionary = PlayerData.owned_characters.get(char_id, {})
	if runtime.is_empty():
		return
	var stats := CharacterConfigService.calculate_stats(char_data, runtime)
	var max_hp := int(stats.get("max_hp", 1))
	# 升级后按比例恢复HP（保持当前HP百分比，但不低于当前值）
	var old_hp := int(runtime.get("current_hp", max_hp))
	if old_hp > 0:
		runtime["current_hp"] = clampi(old_hp, 1, max_hp)
	else:
		runtime["current_hp"] = max_hp


## 计算装备强化费用
static func get_enhance_cost(current_level: int) -> Dictionary:
	return {
		"nano_alloy": 10 + current_level * 8,
		"bio_electricity": 5 + current_level * 4,
	}


## 计算装备强化后的属性倍率
static func get_enhance_stat_multiplier(enhance_level: int) -> float:
	return 1.0 + enhance_level * 0.08


## 计算星级突破费用
static func get_star_upgrade_cost(current_stars: int) -> Dictionary:
	var factor := int(pow(2, current_stars - 1))
	return {
		"chips": 30 * factor,
		"nano_alloy": 40 * factor,
	}
