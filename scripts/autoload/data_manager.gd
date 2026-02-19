## 数据管理器
## 负责加载和缓存所有静态游戏数据
extends Node

## 数据缓存
var _characters: Dictionary = {}
var _enemies: Dictionary = {}
var _items: Dictionary = {}
var _skills: Dictionary = {}
var _events: Dictionary = {}
var _facilities: Dictionary = {}
var _skill_trees: Dictionary = {}

## 数据目录路径
const DATA_PATHS := {
	"characters": "res://data/characters/",
	"enemies": "res://data/enemies/",
	"items": "res://data/items/",
	"skills": "res://data/skills/",
	"events": "res://data/events/",
	"facilities": "res://data/facilities/",
	"skill_trees": "res://data/skill_trees/",
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
	_facilities = _load_resources_from_dir(DATA_PATHS["facilities"])
	_skill_trees = _load_resources_from_dir(DATA_PATHS["skill_trees"])


## 重新加载所有静态配置（调试/热更新时可调用）
func reload_all_data() -> void:
	_load_all_data()


## 从目录加载所有 .tres 资源
func _load_resources_from_dir(dir_path: String) -> Dictionary:
	var result := {}
	var dir := DirAccess.open(dir_path)
	if dir == null:
		push_error("DataManager: 找不到数据目录 %s" % dir_path)
		return result
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var full_path := dir_path + file_name
			var res := load(full_path)
			if res == null:
				push_error("DataManager: 加载资源失败 %s" % full_path)
				file_name = dir.get_next()
				continue
			var res_id := ""
			if _has_property(res, "id"):
				res_id = String(res.get("id"))
			if not res_id.is_empty():
				result[res_id] = res
			else:
				# id 字段缺失或为空，降级使用文件名，需补全配置
				var key := file_name.get_basename()
				push_warning("DataManager: 资源缺少 id 字段，降级使用文件名作为 key（%s）" % full_path)
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
	var res: Resource = _characters.get(id)
	if res == null:
		push_error("DataManager: 找不到角色配置 id=%s（检查 %s）" % [id, DATA_PATHS["characters"]])
	return res


## 获取敌人数据
func get_enemy(id: String) -> Resource:
	var res: Resource = _enemies.get(id)
	if res == null:
		push_error("DataManager: 找不到敌人配置 id=%s（检查 %s）" % [id, DATA_PATHS["enemies"]])
	return res


## 获取物品数据
func get_item(id: String) -> Resource:
	var res: Resource = _items.get(id)
	if res == null:
		push_error("DataManager: 找不到物品配置 id=%s（检查 %s）" % [id, DATA_PATHS["items"]])
	return res


## 获取技能数据
func get_skill(id: String) -> Resource:
	var res: Resource = _skills.get(id)
	if res == null:
		push_error("DataManager: 找不到技能配置 id=%s（检查 %s）" % [id, DATA_PATHS["skills"]])
	return res


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


## 获取设施数据
func get_facility(id: String) -> FacilityData:
	var res: Resource = _facilities.get(id)
	if res == null:
		push_error("DataManager: 找不到设施配置 id=%s（检查 %s）" % [id, DATA_PATHS["facilities"]])
		return null
	return res as FacilityData


## 获取所有设施
func get_all_facilities() -> Dictionary:
	return _facilities


## 获取技能树数据
func get_skill_tree(id: String) -> ProfessionTreeData:
	var res: Resource = _skill_trees.get(id)
	if res == null:
		push_error("DataManager: 找不到技能树配置 id=%s（检查 %s）" % [id, DATA_PATHS["skill_trees"]])
		return null
	return res as ProfessionTreeData


## 获取指定职业的技能树
func get_skill_tree_for_profession(profession: CharacterData.Profession) -> ProfessionTreeData:
	for tree_id: String in _skill_trees:
		var tree: ProfessionTreeData = _skill_trees[tree_id] as ProfessionTreeData
		if tree != null and tree.profession == profession:
			return tree
	return null


## 获取所有技能树
func get_all_skill_trees() -> Dictionary:
	return _skill_trees


## 根据ID列表批量获取技能（缺失的 id 会通过 get_skill 输出错误并跳过）
func get_skills_by_ids(skill_ids: Array[String]) -> Array[SkillData]:
	var result: Array[SkillData] = []
	for skill_id in skill_ids:
		var skill: SkillData = get_skill(skill_id)
		if skill != null:
			result.append(skill)
	return result


## 获取事件数据
func get_event(id: String) -> Resource:
	var res: Resource = _events.get(id)
	if res == null:
		push_error("DataManager: 找不到事件配置 id=%s（检查 %s）" % [id, DATA_PATHS["events"]])
	return res


## 获取所有事件
func get_all_events() -> Dictionary:
	return _events
