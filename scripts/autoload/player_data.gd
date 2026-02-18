## 玩家运行时数据
## 所有玩家动态数据的唯一来源
extends Node

# ========== 常量 ==========
const MAX_TEAM_SIZE := 4
const MAX_MENTAL_POWER := 100.0
const MAX_SAN := 100.0
const CharacterConfigService := preload("res://scripts/character/character_config_service.gd")
const EquipmentService := preload("res://scripts/character/equipment_service.gd")

# ========== 主角数据 ==========
var player_name: String = ""
var player_level: int = 1
var mental_power: float = MAX_MENTAL_POWER  ## 精神力
var gene_crack: int = 0  ## 基因链裂痕（影响结局）

# ========== 资源 ==========
var bio_electricity: int = 500  ## 生物电
var nano_alloy: int = 100  ## 纳米合金
var chips: int = 50  ## 废弃芯片
var hashrate: int = 1000  ## 算力
var credits: int = 0  ## 信用点

# ========== 队伍 ==========
var team: Array[String] = []  ## 当前出战队伍的角色ID列表
var owned_characters: Dictionary = {}  ## 已拥有角色 { id: { level, stars, current_hp, current_aberration, equipment, skill_ids } }
var inventory: Dictionary = {}  ## 物品背包 { item_id: count }
var player_loadout: Dictionary = {  ## 主角装备（预留）
	"command_core": "",
	"relay_chip": "",
	"mental_amplifier": "",
}

# ========== 设施 ==========
var facilities: Dictionary = {
	"reactor": { "level": 1, "workers": 2 },
	"recruit": { "level": 1, "workers": 0 },
	"clinic": { "level": 1, "workers": 0 },
	"market": { "level": 0, "workers": 0 },
	"forge": { "level": 0, "workers": 0 },
	"data_lab": { "level": 0, "workers": 0 },
}

# ========== 进度 ==========
var current_gate: int = 1  ## 当前所在黑门
var gates_cleared: Array[int] = []  ## 已通关黑门
var explored_nodes: Dictionary = {}  ## 已探索节点 { "gate_N": [node_ids] }

# ========== 探索状态（临时） ==========
var current_san: float = MAX_SAN
var current_mental_link: float = 100.0


## 修改资源并发送信号
func modify_resource(resource_type: String, amount: int) -> void:
	match resource_type:
		"bio_electricity":
			bio_electricity = maxi(0, bio_electricity + amount)
			EventBus.resource_changed.emit(resource_type, bio_electricity)
		"nano_alloy":
			nano_alloy = maxi(0, nano_alloy + amount)
			EventBus.resource_changed.emit(resource_type, nano_alloy)
		"chips":
			chips = maxi(0, chips + amount)
			EventBus.resource_changed.emit(resource_type, chips)
		"hashrate":
			hashrate = maxi(0, hashrate + amount)
			EventBus.resource_changed.emit(resource_type, hashrate)
		"credits":
			credits = maxi(0, credits + amount)
			EventBus.resource_changed.emit(resource_type, credits)


## 修改SAN值
func modify_san(amount: float) -> void:
	current_san = clampf(current_san + amount, 0.0, MAX_SAN)
	EventBus.san_updated.emit(current_san)


## 修改精神链接值
func modify_mental_link(amount: float) -> void:
	current_mental_link = clampf(current_mental_link + amount, 0.0, 100.0)
	EventBus.mental_link_updated.emit(current_mental_link)


# ========== 队伍管理 ==========

## 初始化新游戏（给予初始角色）
func init_new_game() -> void:
	player_name = "指挥官"
	player_level = 1
	mental_power = MAX_MENTAL_POWER
	gene_crack = 0
	bio_electricity = 500
	nano_alloy = 100
	chips = 50
	hashrate = 1000
	credits = 0
	team.clear()
	owned_characters.clear()
	inventory.clear()
	player_loadout = _create_empty_player_loadout()
	gates_cleared.clear()
	explored_nodes.clear()
	current_gate = 1
	current_san = MAX_SAN
	current_mental_link = 100.0

	# 给予3个初始角色
	var starter_ids := ["char_assault_01", "char_shield_01", "char_psion_01"]
	for char_id in starter_ids:
		add_character(char_id)
	# 默认前两个编入队伍
	add_to_team("char_assault_01")
	add_to_team("char_shield_01")

	_grant_starter_items()


## 添加角色到已拥有列表
func add_character(char_id: String) -> void:
	if owned_characters.has(char_id):
		return
	owned_characters[char_id] = CharacterConfigService.build_new_runtime(char_id)
	EventBus.character_recruited.emit(char_id)


## 将角色加入出战队伍
func add_to_team(char_id: String) -> bool:
	if team.size() >= MAX_TEAM_SIZE:
		return false
	if char_id in team:
		return false
	if not owned_characters.has(char_id):
		return false
	team.append(char_id)
	return true


## 将角色移出队伍
func remove_from_team(char_id: String) -> void:
	team.erase(char_id)


## 角色是否在队伍中
func is_in_team(char_id: String) -> bool:
	return char_id in team


## 获取角色运行时数据
func get_character_runtime(char_id: String) -> Dictionary:
	return owned_characters.get(char_id, {})


## 获取角色装备槽位字典
func get_character_equipment(char_id: String) -> Dictionary:
	if not owned_characters.has(char_id):
		return EquipmentService.create_empty_hero_equipment()
	var runtime: Dictionary = owned_characters[char_id]
	return EquipmentService.normalize_hero_equipment(runtime.get("equipment", {}))


## 给角色装备物品
func equip_item_to_character(char_id: String, slot: String, item_id: String) -> bool:
	if not owned_characters.has(char_id):
		return false
	if get_item_count(item_id) <= 0:
		return false
	var item: ItemData = DataManager.get_item(item_id)
	if item == null:
		return false
	var char_data: CharacterData = DataManager.get_character(char_id)
	if char_data == null:
		return false

	var runtime: Dictionary = owned_characters[char_id]
	var reason := EquipmentService.get_equip_block_reason(
		char_data,
		runtime,
		item,
		slot,
		owned_characters,
		char_id
	)
	if not reason.is_empty():
		return false

	var equipment := EquipmentService.normalize_hero_equipment(runtime.get("equipment", {}))
	var current_item_id := String(equipment.get(slot, ""))
	if current_item_id == item_id:
		return true

	if not current_item_id.is_empty():
		add_item_to_inventory(current_item_id, 1)

	if not remove_item_from_inventory(item_id, 1):
		return false

	equipment[slot] = item_id
	runtime["equipment"] = equipment
	owned_characters[char_id] = runtime
	EventBus.equipment_changed.emit(char_id, slot, item_id)
	return true


## 从角色指定槽位卸下装备
func unequip_item_from_character(char_id: String, slot: String) -> bool:
	if not owned_characters.has(char_id):
		return false
	var runtime: Dictionary = owned_characters[char_id]
	var equipment := EquipmentService.normalize_hero_equipment(runtime.get("equipment", {}))
	var item_id := String(equipment.get(slot, ""))
	if item_id.is_empty():
		return false

	equipment[slot] = ""
	runtime["equipment"] = equipment
	owned_characters[char_id] = runtime
	add_item_to_inventory(item_id, 1)
	EventBus.equipment_changed.emit(char_id, slot, "")
	return true


## 获取背包中物品数量
func get_item_count(item_id: String) -> int:
	return int(inventory.get(item_id, 0))


## 获取背包拷贝
func get_inventory_items() -> Dictionary:
	return inventory.duplicate(true)


## 增加背包物品
func add_item_to_inventory(item_id: String, count: int = 1) -> void:
	if item_id.is_empty() or count <= 0:
		return
	var new_count := get_item_count(item_id) + count
	inventory[item_id] = new_count
	EventBus.inventory_changed.emit(item_id, new_count)


## 减少背包物品
func remove_item_from_inventory(item_id: String, count: int = 1) -> bool:
	if item_id.is_empty() or count <= 0:
		return false
	var current := get_item_count(item_id)
	if current < count:
		return false
	var new_count := current - count
	if new_count <= 0:
		inventory.erase(item_id)
		EventBus.inventory_changed.emit(item_id, 0)
	else:
		inventory[item_id] = new_count
		EventBus.inventory_changed.emit(item_id, new_count)
	return true


## 获取角色最终属性（由配置 + 运行时数据计算）
func get_character_stats(char_id: String) -> Dictionary:
	var char_data: CharacterData = DataManager.get_character(char_id)
	if char_data == null:
		return {}
	var runtime := get_character_runtime(char_id)
	return CharacterConfigService.calculate_stats(char_data, runtime)


## 获取角色技能配置列表
func get_character_skills(char_id: String) -> Array[SkillData]:
	return CharacterConfigService.get_skills(char_id, get_character_runtime(char_id))


## 设置角色当前生命值
func set_character_hp(char_id: String, hp: int) -> void:
	if not owned_characters.has(char_id):
		return
	var runtime: Dictionary = owned_characters[char_id]
	var stats := get_character_stats(char_id)
	var max_hp := int(stats.get("max_hp", 1))
	runtime["current_hp"] = clampi(hp, 0, max_hp)
	owned_characters[char_id] = runtime


## 设置角色当前异化值
func set_character_aberration(char_id: String, value: float) -> void:
	if not owned_characters.has(char_id):
		return
	var runtime: Dictionary = owned_characters[char_id]
	var char_data: CharacterData = DataManager.get_character(char_id)
	var max_ab := 100.0
	if char_data != null:
		max_ab = maxf(0.0, char_data.max_aberration)
	runtime["current_aberration"] = clampf(value, 0.0, max_ab)
	owned_characters[char_id] = runtime
	EventBus.aberration_updated.emit(char_id, float(runtime["current_aberration"]))


## 重置探索状态（进入新探索时调用）
func reset_expedition_state() -> void:
	current_san = MAX_SAN
	current_mental_link = 100.0


## 消耗精神力（主角能力代价）
func consume_mental_power(amount: float) -> bool:
	if mental_power < amount:
		return false
	mental_power -= amount
	gene_crack += 1  # 每次使用能力，基因链裂痕+1
	return true


# ========== 存档接口 ==========

func get_player_save_data() -> Dictionary:
	return {
		"name": player_name,
		"level": player_level,
		"mental_power": mental_power,
		"gene_crack": gene_crack,
	}

func get_resources_save_data() -> Dictionary:
	return {
		"bio_electricity": bio_electricity,
		"nano_alloy": nano_alloy,
		"chips": chips,
		"hashrate": hashrate,
		"credits": credits,
	}

func get_inventory_save_data() -> Dictionary:
	return inventory.duplicate(true)

func get_player_loadout_save_data() -> Dictionary:
	return player_loadout.duplicate(true)

func get_team_save_data() -> Array:
	return team.duplicate()

func get_characters_save_data() -> Dictionary:
	return owned_characters.duplicate(true)

func get_facilities_save_data() -> Dictionary:
	return facilities.duplicate(true)

func get_progress_save_data() -> Dictionary:
	return {
		"current_gate": current_gate,
		"gates_cleared": gates_cleared.duplicate(),
		"explored_nodes": explored_nodes.duplicate(true),
	}

func load_from_save_data(data: Dictionary) -> void:
	var p: Dictionary = data.get("player", {})
	player_name = p.get("name", "")
	player_level = p.get("level", 1)
	mental_power = p.get("mental_power", MAX_MENTAL_POWER)
	gene_crack = p.get("gene_crack", 0)

	var r: Dictionary = data.get("resources", {})
	bio_electricity = r.get("bio_electricity", 500)
	nano_alloy = r.get("nano_alloy", 100)
	chips = r.get("chips", 50)
	hashrate = r.get("hashrate", 1000)
	credits = r.get("credits", 0)

	team = Array(data.get("team", []), TYPE_STRING, "", null)
	owned_characters = data.get("characters", {})
	var inventory_raw: Variant = data.get("inventory", {})
	inventory = inventory_raw if inventory_raw is Dictionary else {}
	player_loadout = _normalize_player_loadout(data.get("player_loadout", {}))
	var normalized_characters := {}
	for char_id: String in owned_characters:
		var runtime: Dictionary = owned_characters.get(char_id, {})
		normalized_characters[char_id] = CharacterConfigService.normalize_runtime(char_id, runtime)
	owned_characters = normalized_characters
	var valid_team: Array[String] = []
	for char_id in team:
		if owned_characters.has(char_id):
			valid_team.append(char_id)
	team = valid_team
	facilities = data.get("facilities", facilities)

	var prog: Dictionary = data.get("progress", {})
	current_gate = prog.get("current_gate", 1)
	gates_cleared = Array(prog.get("gates_cleared", []), TYPE_INT, "", null)
	explored_nodes = prog.get("explored_nodes", {})
	_normalize_inventory_data()


func _grant_starter_items() -> void:
	var starter_items := {
		"item_weapon_rifle_01": 1,
		"item_weapon_tower_shield_01": 1,
		"item_weapon_aberration_core_01": 1,  ## PLAGUE/PSION/BERSERKER 共用武器（初始 PSION 需要）
		"item_head_sensor_01": 1,
		"item_body_armor_01": 1,
		"item_arms_stim_01": 1,
		"item_legs_servo_01": 1,
		"item_acc_link_01": 2,
	}
	for item_id in starter_items:
		add_item_to_inventory(item_id, int(starter_items[item_id]))


func _create_empty_player_loadout() -> Dictionary:
	return {
		"command_core": "",
		"relay_chip": "",
		"mental_amplifier": "",
	}


func _normalize_player_loadout(raw: Variant) -> Dictionary:
	var normalized := _create_empty_player_loadout()
	if raw is Dictionary:
		var dict_raw: Dictionary = raw
		for key in normalized.keys():
			normalized[key] = String(dict_raw.get(key, ""))
	return normalized


func _normalize_inventory_data() -> void:
	var normalized := {}
	for item_id in inventory:
		var count := int(inventory[item_id])
		if count > 0:
			normalized[String(item_id)] = count
	inventory = normalized
