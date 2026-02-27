## 队伍编成面板
## 管理出战队伍的编成，点击队伍中的角色可查看详情
extends Control

signal character_detail_requested(char_id: String)

const CharacterCardScene := preload("res://scenes/ui/character_card.tscn")


func _ready() -> void:
	_refresh()


## 外部调用：从详情页返回时刷新
func refresh() -> void:
	_refresh()


## 刷新整个面板
func _refresh() -> void:
	_refresh_team_slots()
	_refresh_roster()


## 刷新队伍槽位（上方）
func _refresh_team_slots() -> void:
	for child in %TeamSlots.get_children():
		child.queue_free()

	# 显示已编入队伍的角色
	for char_id in PlayerData.team:
		var char_data: CharacterData = DataManager.get_character(char_id)
		if char_data == null:
			continue
		var card := CharacterCardScene.instantiate()
		%TeamSlots.add_child(card)
		var runtime: Dictionary = PlayerData.get_character_runtime(char_id)
		card.setup(char_id, char_data, runtime)
		card.card_pressed.connect(_on_team_card_pressed)

	# 空槽位提示
	var empty_slots := PlayerData.MAX_TEAM_SIZE - PlayerData.team.size()
	for i in empty_slots:
		var slot := _create_empty_slot()
		%TeamSlots.add_child(slot)


## 刷新可用角色列表（下方）
func _refresh_roster() -> void:
	for child in %RosterList.get_children():
		child.queue_free()

	var has_available := false
	for char_id: String in PlayerData.owned_characters:
		if PlayerData.is_in_team(char_id):
			continue
		var char_data: CharacterData = DataManager.get_character(char_id)
		if char_data == null:
			continue
		has_available = true
		var card := CharacterCardScene.instantiate()
		%RosterList.add_child(card)
		var runtime: Dictionary = PlayerData.get_character_runtime(char_id)
		card.setup(char_id, char_data, runtime)
		card.card_pressed.connect(_on_roster_card_pressed)

	if not has_available:
		var hint := Label.new()
		hint.text = "没有更多可用角色"
		hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		%RosterList.add_child(hint)


## 点击队伍中的角色卡 → 打开角色详情
func _on_team_card_pressed(char_id: String) -> void:
	character_detail_requested.emit(char_id)


## 点击候选角色卡 → 加入队伍
func _on_roster_card_pressed(char_id: String) -> void:
	if PlayerData.add_to_team(char_id):
		_refresh()


## 创建空卡槽占位
func _create_empty_slot() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 88)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.04, 0.08, 0.3)
	style.border_color = Color(0.65, 0.08, 0.08, 0.25)
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	# 虚线效果用透明度模拟
	panel.add_theme_stylebox_override("panel", style)

	var lbl := Label.new()
	lbl.text = "＋ 空位"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 0.5))
	panel.add_child(lbl)

	return panel
