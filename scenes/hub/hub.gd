## 枢纽经营场景
extends Control

const TeamPanelScene := preload("res://scenes/ui/team_panel.tscn")
const PreparationPanelScene := preload("res://scenes/ui/preparation_panel.tscn")
const FacilityPanelScene := preload("res://scenes/ui/facility_panel.tscn")
const GrowthPanelScene := preload("res://scenes/ui/growth_panel.tscn")
const ToastNotification := preload("res://scenes/ui/toast_notification.gd")

const FACILITY_SLOT_MAP := {
	"ReactorSlot": "reactor",
	"RecruitSlot": "recruit",
	"ClinicSlot": "clinic",
	"MarketSlot": "market",
	"ForgeSlot": "forge",
	"DataLabSlot": "data_lab",
}

var _prev_resources: Dictionary = {}


func _ready() -> void:
	_collect_facility_production()
	_update_resource_display()
	_update_facility_display()
	_snapshot_resources()
	EventBus.resource_changed.connect(_on_resource_changed)
	EventBus.facility_upgraded.connect(_on_facility_upgraded)

	%BtnExpedition.pressed.connect(_on_expedition)
	%BtnTeam.pressed.connect(_on_team)
	%BtnGrowth.pressed.connect(_on_growth)

	# 连接设施槽点击
	for slot_name: String in FACILITY_SLOT_MAP:
		var slot_node: PanelContainer = %FacilityList.get_node(slot_name)
		if slot_node:
			slot_node.gui_input.connect(_on_facility_slot_input.bind(FACILITY_SLOT_MAP[slot_name]))


## 收集设施产出（每次进入枢纽时结算）
func _collect_facility_production() -> void:
	var production := FacilityService.collect_all_production()
	if production.is_empty():
		return
	var summary := "设施产出："
	for resource_type: String in production:
		var amount: int = int(production[resource_type])
		PlayerData.modify_resource(resource_type, amount)
		summary += "\n  %s +%d" % [_resource_display_name(resource_type), amount]
	_show_message(summary)


## 更新资源显示
func _update_resource_display() -> void:
	%LblBioElectricity.text = "生物电: %d" % PlayerData.bio_electricity
	%LblNanoAlloy.text = "合金: %d" % PlayerData.nano_alloy
	%LblHashrate.text = "算力: %d" % PlayerData.hashrate
	%LblMentalPower.text = "精神力: %d" % int(PlayerData.mental_power)


## 更新设施列表显示
func _update_facility_display() -> void:
	for slot_name: String in FACILITY_SLOT_MAP:
		var facility_id: String = FACILITY_SLOT_MAP[slot_name]
		var slot_node: PanelContainer = %FacilityList.get_node(slot_name)
		if slot_node == null:
			continue
		var label: Label = slot_node.get_node("Label")
		if label == null:
			continue
		var config: FacilityData = DataManager.get_facility(facility_id)
		var state: Dictionary = PlayerData.facilities.get(facility_id, {})
		var level: int = int(state.get("level", 0))

		if config == null:
			label.text = "%s  [配置缺失]" % facility_id
		elif level <= 0:
			if FacilityService.is_unlocked(config):
				label.text = "%s  [未建造]" % config.display_name
			else:
				label.text = "%s  [未解锁 - 需通过第%d扇黑门]" % [config.display_name, config.unlock_gate]
		else:
			var workers: int = int(state.get("workers", 0))
			label.text = "%s  Lv.%d  工人:%d" % [config.display_name, level, workers]


func _snapshot_resources() -> void:
	_prev_resources = {
		"bio_electricity": PlayerData.bio_electricity,
		"nano_alloy": PlayerData.nano_alloy,
		"hashrate": PlayerData.hashrate,
		"chips": PlayerData.chips,
		"credits": PlayerData.credits,
	}


func _on_resource_changed(resource_type: String, new_value: int) -> void:
	_update_resource_display()
	var prev: int = _prev_resources.get(resource_type, new_value)
	var delta: int = new_value - prev
	_prev_resources[resource_type] = new_value
	if delta == 0:
		return
	var sign_str := "+" if delta > 0 else ""
	var color := Color.GREEN_YELLOW if delta > 0 else Color.TOMATO
	ToastNotification.show_toast(self, "%s %s%d" % [_resource_display_name(resource_type), sign_str, delta], color)


func _on_facility_upgraded(facility_id: String, new_level: int) -> void:
	_update_facility_display()
	_update_resource_display()
	var config: FacilityData = DataManager.get_facility(facility_id)
	var name: String = config.display_name if config else facility_id
	ToastNotification.show_toast(self, "%s 升级至 Lv.%d" % [name, new_level], Color.GOLD)


func _on_facility_slot_input(event: InputEvent, facility_id: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_open_facility_panel(facility_id)


func _open_facility_panel(facility_id: String) -> void:
	var config: FacilityData = DataManager.get_facility(facility_id)
	if config == null:
		return
	var state: Dictionary = PlayerData.facilities.get(facility_id, {})
	var level: int = int(state.get("level", 0))
	# 未解锁设施不可打开
	if level <= 0 and not FacilityService.is_unlocked(config):
		_show_message("需要通过第%d扇黑门才能解锁此设施。" % config.unlock_gate)
		return
	var panel := FacilityPanelScene.instantiate()
	%PopupLayer.add_child(panel)
	panel.setup(facility_id)


func _on_expedition() -> void:
	if PlayerData.team.is_empty():
		_show_message("请先编组队伍再出发探索")
		return
	var panel := PreparationPanelScene.instantiate()
	%PopupLayer.add_child(panel)


func _on_team() -> void:
	var panel := TeamPanelScene.instantiate()
	%PopupLayer.add_child(panel)


func _on_growth() -> void:
	if PlayerData.owned_characters.is_empty():
		_show_message("暂无可培养的角色")
		return
	var panel := GrowthPanelScene.instantiate()
	%PopupLayer.add_child(panel)


## 显示简单提示信息
func _show_message(text: String) -> void:
	var dialog := AcceptDialog.new()
	dialog.dialog_text = text
	dialog.title = "提示"
	%PopupLayer.add_child(dialog)
	dialog.popup_centered()
	dialog.confirmed.connect(dialog.queue_free)


func _resource_display_name(resource_type: String) -> String:
	match resource_type:
		"bio_electricity": return "生物电"
		"nano_alloy": return "合金"
		"chips": return "芯片"
		"hashrate": return "算力"
		"credits": return "信用点"
		_: return resource_type
