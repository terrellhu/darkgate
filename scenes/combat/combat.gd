## 战斗场景
extends Control

## 战斗状态
enum CombatState {
	PREPARING,  ## 准备阶段
	RUNNING,    ## 战斗进行中
	PAUSED,     ## 玩家手动干预
	VICTORY,    ## 胜利
	DEFEAT,     ## 失败
}

var _state: CombatState = CombatState.PREPARING
var _enemy_ids: Array = []


func _ready() -> void:
	%BtnAuto.pressed.connect(_on_toggle_auto)
	%BtnRetreat.pressed.connect(_on_retreat)
	setup_combat(GameManager.consume_pending_combat_enemy_ids())


## 初始化战斗
func setup_combat(enemy_ids: Array) -> void:
	_enemy_ids = enemy_ids
	_state = CombatState.PREPARING
	_clear_unit_views()
	_log("遭遇敌人！")
	_setup_allies_from_config()
	_setup_enemies_from_config()
	_state = CombatState.RUNNING


## 写入战斗日志
func _log(text: String) -> void:
	%BattleLog.append_text(text + "\n")


## ATB系统更新
func _process(delta: float) -> void:
	if _state != CombatState.RUNNING:
		return
	# TODO: 更新所有单位的行动条
	# 当某单位行动条满时，执行其战术预设


## 切换自动/手动模式
func _on_toggle_auto() -> void:
	if _state == CombatState.PAUSED:
		_state = CombatState.RUNNING
		%BtnAuto.text = "手动"
	elif _state == CombatState.RUNNING:
		_state = CombatState.PAUSED
		%BtnAuto.text = "自动"


## 战斗结束处理
func _end_combat(result: String) -> void:
	match result:
		"victory":
			_state = CombatState.VICTORY
			_log("战斗胜利！")
			EventBus.combat_ended.emit("victory")
		"defeat":
			_state = CombatState.DEFEAT
			_log("队伍全灭...")
			EventBus.combat_ended.emit("defeat")


func _on_retreat() -> void:
	# 撤退回探索场景
	GameManager.change_state(GameManager.GameState.EXPEDITION)


func _setup_allies_from_config() -> void:
	for char_id in PlayerData.team:
		var char_data: CharacterData = DataManager.get_character(char_id)
		if char_data == null:
			continue
		var stats := PlayerData.get_character_stats(char_id)
		var skills: Array[SkillData] = PlayerData.get_character_skills(char_id)
		var skill_names: Array[String] = []
		for skill in skills:
			skill_names.append(skill.display_name)
		var stat_text := "HP:%d ATK:%d DEF:%d SPD:%d" % [
			int(stats.get("max_hp", 1)),
			int(stats.get("atk", 1)),
			int(stats.get("def", 0)),
			int(stats.get("speed", 1)),
		]
		_add_unit_label(%AllyList, "%s\n%s" % [char_data.display_name, stat_text])
		_log("%s 技能: %s" % [char_data.display_name, " / ".join(skill_names)])


func _setup_enemies_from_config() -> void:
	if _enemy_ids.is_empty():
		_add_unit_label(%EnemyList, "未知敌人")
		_log("未指定敌人配置，使用占位敌人。")
		return

	for enemy_id: String in _enemy_ids:
		var enemy: EnemyData = DataManager.get_enemy(enemy_id)
		if enemy == null:
			_add_unit_label(%EnemyList, enemy_id)
			continue
		var stat_text := "HP:%d ATK:%d DEF:%d SPD:%d" % [enemy.hp, enemy.atk, enemy.def, enemy.speed]
		_add_unit_label(%EnemyList, "%s\n%s" % [enemy.display_name, stat_text])


func _add_unit_label(container: Node, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(label)


func _clear_unit_views() -> void:
	for child in %AllyList.get_children():
		child.queue_free()
	for child in %EnemyList.get_children():
		child.queue_free()
	%BattleLog.clear()
