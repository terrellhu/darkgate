## 设施逻辑服务
## 纯静态函数，计算产出、升级费用、工人上限等
class_name FacilityService
extends RefCounted


## 计算单个设施的资源产出
static func calculate_output(config: FacilityData, level: int, workers: int) -> int:
	if config.produces_resource.is_empty() or workers <= 0 or level <= 0:
		return 0
	var level_bonus := 1.0 + (level - 1) * config.output_per_level_bonus
	return int(floor(config.base_output_per_worker * workers * level_bonus))


## 计算设施当前等级的升级费用
static func get_upgrade_cost(config: FacilityData, current_level: int) -> Dictionary:
	var scale := pow(config.upgrade_cost_scale, maxf(0, current_level - 1))
	return {
		"nano_alloy": int(ceil(config.upgrade_base_nano * scale)),
		"chips": int(ceil(config.upgrade_base_chips * scale)),
	}


## 检查玩家是否负担得起升级
static func can_afford_upgrade(config: FacilityData, current_level: int) -> bool:
	var cost := get_upgrade_cost(config, current_level)
	return (PlayerData.nano_alloy >= cost["nano_alloy"]
		and PlayerData.chips >= cost["chips"])


## 获取指定等级的最大工人数
static func get_max_workers(config: FacilityData, level: int) -> int:
	return level * config.max_workers_per_level


## 检查设施是否已解锁
static func is_unlocked(config: FacilityData) -> bool:
	if config.unlock_gate <= 0:
		return true
	return config.unlock_gate <= PlayerData.current_gate or config.unlock_gate in PlayerData.gates_cleared


## 收集所有设施的产出 { resource_type: total_amount }
static func collect_all_production() -> Dictionary:
	var totals: Dictionary = {}
	for facility_id: String in PlayerData.facilities:
		var config: FacilityData = DataManager.get_facility(facility_id)
		if config == null:
			continue
		var state: Dictionary = PlayerData.facilities[facility_id]
		var level: int = int(state.get("level", 0))
		var workers: int = int(state.get("workers", 0))
		var output := calculate_output(config, level, workers)
		if output > 0:
			totals[config.produces_resource] = int(totals.get(config.produces_resource, 0)) + output
	return totals
