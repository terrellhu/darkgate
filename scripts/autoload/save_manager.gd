## 存档管理器
## 负责游戏存档的保存和读取
extends Node

const SAVE_DIR := "user://save/"
const MAX_SLOTS := 3

## 存档版本号 —— 开发阶段保持为 1，不随迭代递增。
## 仅在数据结构正式冻结、需要区分线上旧档时才提升版本号并补写迁移逻辑。
## ⚠️ 禁止在日常开发中自行修改此常量。
const SAVE_VERSION := 1


func _ready() -> void:
	# 确保存档目录存在
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)


## 保存游戏到指定槽位
func save_game(slot: int) -> bool:
	if slot < 0 or slot >= MAX_SLOTS:
		push_error("无效的存档槽位: %d" % slot)
		return false

	var save_data := _collect_save_data()
	var json_str := JSON.stringify(save_data, "\t")
	var file_path := SAVE_DIR + "slot_%d.json" % slot

	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		push_error("无法打开存档文件: %s" % file_path)
		return false

	file.store_string(json_str)
	file.close()
	return true


## 从指定槽位读取存档
func load_game(slot: int) -> bool:
	var file_path := SAVE_DIR + "slot_%d.json" % slot

	if not FileAccess.file_exists(file_path):
		push_error("存档不存在: %s" % file_path)
		return false

	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("无法读取存档: %s" % file_path)
		return false

	var json_str := file.get_as_text()
	file.close()

	var json := JSON.new()
	var error := json.parse(json_str)
	if error != OK:
		push_error("存档解析失败: %s" % json.get_error_message())
		return false

	var save_data: Dictionary = json.data
	var file_version: int = save_data.get("version", 0)
	if file_version != SAVE_VERSION:
		push_warning("SaveManager: 存档版本不匹配（文件=%d，当前=%d），尝试迁移" % [file_version, SAVE_VERSION])
		save_data = _migrate(save_data, file_version)

	_apply_save_data(save_data)
	return true


## 检查槽位是否有存档
func has_save(slot: int) -> bool:
	return FileAccess.file_exists(SAVE_DIR + "slot_%d.json" % slot)


## 删除存档
func delete_save(slot: int) -> void:
	var file_path := SAVE_DIR + "slot_%d.json" % slot
	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(file_path)


## 收集当前游戏数据用于存档
func _collect_save_data() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"timestamp": Time.get_datetime_string_from_system(),
		"player": PlayerData.get_player_save_data(),
		"resources": PlayerData.get_resources_save_data(),
		"team": PlayerData.get_team_save_data(),
		"characters": PlayerData.get_characters_save_data(),
		"inventory": PlayerData.get_inventory_save_data(),
		"player_loadout": PlayerData.get_player_loadout_save_data(),
		"facilities": PlayerData.get_facilities_save_data(),
		"progress": PlayerData.get_progress_save_data(),
	}


## 将存档数据应用到游戏
func _apply_save_data(data: Dictionary) -> void:
	PlayerData.load_from_save_data(data)


## 存档版本迁移框架（开发阶段占位，当前无实际迁移逻辑）
## 使用方式：当 SAVE_VERSION 提升时，在此按版本号补写迁移函数并串联调用。
## 示例：
##   if from_version < 2: data = _migrate_v1_to_v2(data)
##   if from_version < 3: data = _migrate_v2_to_v3(data)
func _migrate(data: Dictionary, from_version: int) -> Dictionary:
	# 开发阶段：版本号未启用，直接透传，不做任何字段变换
	# TODO: 正式发布前在此补写各版本迁移逻辑
	return data
