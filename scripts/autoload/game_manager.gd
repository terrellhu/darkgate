## 游戏主管理器
## 负责游戏状态机和场景切换
extends Node

enum GameState {
	MAIN_MENU,
	HUB,
	EXPEDITION,
	COMBAT,
}

var current_state: GameState = GameState.MAIN_MENU
var previous_state: GameState = GameState.MAIN_MENU
var pending_combat_enemy_ids: Array[String] = []

## 场景路径映射
const SCENE_PATHS := {
	GameState.MAIN_MENU: "res://scenes/main/main.tscn",
	GameState.HUB: "res://scenes/hub/hub.tscn",
	GameState.EXPEDITION: "res://scenes/expedition/expedition.tscn",
	GameState.COMBAT: "res://scenes/combat/combat.tscn",
}


func _ready() -> void:
	pass


## 切换游戏状态并加载对应场景
func change_state(new_state: GameState) -> void:
	previous_state = current_state
	current_state = new_state
	EventBus.scene_change_requested.emit(SCENE_PATHS[new_state])
	_load_scene(SCENE_PATHS[new_state])


## 返回上一个状态
func go_back() -> void:
	change_state(previous_state)


## 加载目标场景
func _load_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)


## 进入战斗并携带敌人配置ID
func start_combat(enemy_ids: Array[String]) -> void:
	pending_combat_enemy_ids = enemy_ids.duplicate()
	change_state(GameState.COMBAT)


## 读取并清空待处理敌人列表（Combat场景消费）
func consume_pending_combat_enemy_ids() -> Array[String]:
	var ids := pending_combat_enemy_ids.duplicate()
	pending_combat_enemy_ids.clear()
	return ids


## 暂停游戏
func pause_game() -> void:
	get_tree().paused = true


## 恢复游戏
func resume_game() -> void:
	get_tree().paused = false
