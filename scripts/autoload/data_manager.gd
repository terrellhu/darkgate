## 数据管理器
## 负责加载和缓存所有静态游戏数据
extends Node

## 数据缓存
var _characters: Dictionary = {}
var _enemies: Dictionary = {}
var _items: Dictionary = {}
var _skills: Dictionary = {}
var _events: Dictionary = {}

## 数据目录路径
const DATA_PATHS := {
	"characters": "res://data/characters/",
	"enemies": "res://data/enemies/",
	"items": "res://data/items/",
	"skills": "res://data/skills/",
	"events": "res://data/events/",
}


func _ready() -> void:
	_load_all_data()


## 加载所有静态数据
func _load_all_data() -> void:
	_characters = _load_resources_from_dir(DATA_PATHS["characters"])
	_enemies = _load_resources_from_dir(DATA_PATHS["enemies"])
	_items = _load_resources_from_dir(DATA_PATHS["items"])
	_skills = _load_resources_from_dir(DATA_PATHS["skills"])
	_events = _load_resources_from_dir(DATA_PATHS["events"])


## 重新加载所有静态配置（调试/热更新时可调用）
func reload_all_data() -> void:
	_load_all_data()


## 从目录加载所有 .tres 资源
func _load_resources_from_dir(dir_path: String) -> Dictionary:
	var result := {}
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return result
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var res := load(dir_path + file_name)
			var res_id := ""
			if res and _has_property(res, "id"):
				res_id = String(res.get("id"))
			if not res_id.is_empty():
				result[res_id] = res
			else:
				# 用文件名作为key
				var key := file_name.get_basename()
				result[key] = res
		file_name = dir.get_next()
	return result


func _has_property(obj: Object, property_name: String) -> bool:
	for prop in obj.get_property_list():
		if String(prop.get("name", "")) == property_name:
			return true
	return false


## 获取角色数据
func get_character(id: String) -> Resource:
	return _characters.get(id)


## 获取敌人数据
func get_enemy(id: String) -> Resource:
	return _enemies.get(id)


## 获取物品数据
func get_item(id: String) -> Resource:
	return _items.get(id)


## 获取技能数据
func get_skill(id: String) -> Resource:
	return _skills.get(id)


## 获取所有角色
func get_all_characters() -> Dictionary:
	return _characters


## 获取所有敌人
func get_all_enemies() -> Dictionary:
	return _enemies


## 获取所有物品
func get_all_items() -> Dictionary:
	return _items


## 获取所有技能
func get_all_skills() -> Dictionary:
	return _skills


## 根据ID列表批量获取技能
func get_skills_by_ids(skill_ids: Array[String]) -> Array[SkillData]:
	var result: Array[SkillData] = []
	for skill_id in skill_ids:
		var skill: SkillData = get_skill(skill_id)
		if skill != null:
			result.append(skill)
	return result


## 获取事件数据
func get_event(id: String) -> Resource:
	return _events.get(id)


## 获取所有事件
func get_all_events() -> Dictionary:
	return _events
