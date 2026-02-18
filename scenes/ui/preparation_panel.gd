## 出征准备面板
## 用于队伍成员换装与确认出征
extends PanelContainer

const EquipmentService := preload("res://scripts/character/equipment_service.gd")

var _selected_char_id: String = ""
var _selected_slot: String = EquipmentService.SLOT_WEAPON


func _ready() -> void:
	%BtnClose.pressed.connect(_on_close)
	%BtnConfirm.pressed.connect(_on_confirm)
	_refresh()


func _refresh() -> void:
	if PlayerData.team.is_empty():
		%BtnConfirm.disabled = true
		%LblSelected.text = "队伍为空"
		_clear_container(%TeamList)
		_clear_container(%SlotList)
		_clear_container(%InventoryList)
		return

	if _selected_char_id.is_empty() or not (_selected_char_id in PlayerData.team):
		_selected_char_id = PlayerData.team[0]

	_refresh_team_list()
	_refresh_character_header()
	_refresh_slot_list()
	_refresh_inventory_list()
	%BtnConfirm.disabled = false


func _refresh_team_list() -> void:
	_clear_container(%TeamList)
	for char_id in PlayerData.team:
		var char_data: CharacterData = DataManager.get_character(char_id)
		if char_data == null:
			continue
		var btn := Button.new()
		btn.text = char_data.display_name
		btn.toggle_mode = true
		btn.button_pressed = (char_id == _selected_char_id)
		btn.pressed.connect(_on_team_selected.bind(char_id))
		%TeamList.add_child(btn)


func _refresh_character_header() -> void:
	var char_data: CharacterData = DataManager.get_character(_selected_char_id)
	if char_data == null:
		%LblSelected.text = "未选择角色"
		return
	var stats := PlayerData.get_character_stats(_selected_char_id)
	%LblSelected.text = "%s  HP:%d  ATK:%d  DEF:%d  SPD:%d" % [
		char_data.display_name,
		int(stats.get("max_hp", 1)),
		int(stats.get("atk", 1)),
		int(stats.get("def", 0)),
		int(stats.get("speed", 1)),
	]


func _refresh_slot_list() -> void:
	_clear_container(%SlotList)
	var equipment := PlayerData.get_character_equipment(_selected_char_id)

	for slot in EquipmentService.HERO_EQUIP_SLOTS:
		var row := HBoxContainer.new()
		var btn_slot := Button.new()
		var item_id := String(equipment.get(slot, ""))
		var item_name := "空"
		if not item_id.is_empty():
			var item: ItemData = DataManager.get_item(item_id)
			if item != null:
				item_name = item.display_name
			else:
				item_name = item_id
		btn_slot.text = "%s: %s" % [EquipmentService.get_slot_display_name(slot), item_name]
		btn_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_slot.toggle_mode = true
		btn_slot.button_pressed = (slot == _selected_slot)
		btn_slot.pressed.connect(_on_slot_selected.bind(slot))

		var btn_remove := Button.new()
		btn_remove.text = "卸下"
		btn_remove.disabled = item_id.is_empty()
		btn_remove.pressed.connect(_on_unequip_slot.bind(slot))

		row.add_child(btn_slot)
		row.add_child(btn_remove)
		%SlotList.add_child(row)


func _refresh_inventory_list() -> void:
	_clear_container(%InventoryList)
	var char_data: CharacterData = DataManager.get_character(_selected_char_id)
	if char_data == null:
		return
	var runtime := PlayerData.get_character_runtime(_selected_char_id)

	var inventory_items := PlayerData.get_inventory_items()
	var has_item := false
	for raw_item_id in inventory_items:
		var item_id := String(raw_item_id)
		var count := int(inventory_items[item_id])
		if count <= 0:
			continue
		var item: ItemData = DataManager.get_item(item_id)
		if item == null:
			continue
		if not EquipmentService.is_equip_item(item):
			continue
		if not EquipmentService.slot_accepts_item(_selected_slot, item):
			continue

		var reason := EquipmentService.get_equip_block_reason(
			char_data,
			runtime,
			item,
			_selected_slot,
			PlayerData.owned_characters,
			_selected_char_id
		)

		var btn := Button.new()
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.text = "%s  x%d  (+HP%d +ATK%d +DEF%d +SPD%d)" % [
			item.display_name,
			count,
			item.equip_hp,
			item.equip_atk,
			item.equip_def,
			item.equip_speed,
		]
		if reason.is_empty():
			btn.pressed.connect(_on_equip_item.bind(item_id))
		else:
			btn.disabled = true
			btn.tooltip_text = reason
		%InventoryList.add_child(btn)
		has_item = true

	if not has_item:
		var hint := Label.new()
		hint.text = "该槽位暂无可装备物品"
		hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hint.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		%InventoryList.add_child(hint)


func _on_confirm() -> void:
	PlayerData.reset_expedition_state()
	EventBus.preparation_confirmed.emit(PlayerData.team.duplicate())
	GameManager.change_state(GameManager.GameState.EXPEDITION)
	queue_free()


func _on_close() -> void:
	queue_free()


func _on_team_selected(char_id: String) -> void:
	_selected_char_id = char_id
	_refresh()


func _on_slot_selected(slot: String) -> void:
	_selected_slot = slot
	_refresh_slot_list()
	_refresh_inventory_list()


func _on_unequip_slot(slot: String) -> void:
	if PlayerData.unequip_item_from_character(_selected_char_id, slot):
		_refresh()


func _on_equip_item(item_id: String) -> void:
	if PlayerData.equip_item_to_character(_selected_char_id, _selected_slot, item_id):
		_refresh()


func _clear_container(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()
