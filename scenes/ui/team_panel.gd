## 队伍编成面板
## 管理出战队伍的编成
extends Control

const CharacterCardScene := preload("res://scenes/ui/character_card.tscn")


func _ready() -> void:
	_refresh()


## 刷新整个面板
func _refresh() -> void:
	_refresh_team_slots()
	_refresh_roster()


## 刷新队伍槽位（上方）
func _refresh_team_slots() -> void:
	for child in %TeamSlots.get_children():
		child.queue_free()

	if PlayerData.team.is_empty():
		var hint := Label.new()
		hint.text = "队伍为空，请从下方添加角色"
		hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		%TeamSlots.add_child(hint)
		return

	for char_id in PlayerData.team:
		var char_data: CharacterData = DataManager.get_character(char_id)
		if char_data == null:
			continue
		var card := CharacterCardScene.instantiate()
		%TeamSlots.add_child(card)
		var runtime: Dictionary = PlayerData.get_character_runtime(char_id)
		card.setup(char_id, char_data, runtime)
		card.card_pressed.connect(_on_team_card_pressed)


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


## 点击队伍中的角色卡 → 移出队伍
func _on_team_card_pressed(char_id: String) -> void:
	PlayerData.remove_from_team(char_id)
	_refresh()


## 点击候选角色卡 → 加入队伍
func _on_roster_card_pressed(char_id: String) -> void:
	if PlayerData.add_to_team(char_id):
		_refresh()


