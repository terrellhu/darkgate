## 枢纽经营场景
extends Control

const TeamPanelScene := preload("res://scenes/ui/team_panel.tscn")
const PreparationPanelScene := preload("res://scenes/ui/preparation_panel.tscn")


func _ready() -> void:
	_update_resource_display()
	EventBus.resource_changed.connect(_on_resource_changed)

	%BtnExpedition.pressed.connect(_on_expedition)
	%BtnTeam.pressed.connect(_on_team)


## 更新资源显示
func _update_resource_display() -> void:
	%LblBioElectricity.text = "生物电: %d" % PlayerData.bio_electricity
	%LblNanoAlloy.text = "合金: %d" % PlayerData.nano_alloy
	%LblHashrate.text = "算力: %d" % PlayerData.hashrate
	%LblMentalPower.text = "精神力: %d" % int(PlayerData.mental_power)


func _on_resource_changed(_resource_type: String, _new_value: int) -> void:
	_update_resource_display()


func _on_expedition() -> void:
	if PlayerData.team.is_empty():
		_show_message("请先编组队伍再出发探索")
		return
	var panel := PreparationPanelScene.instantiate()
	%PopupLayer.add_child(panel)


func _on_team() -> void:
	var panel := TeamPanelScene.instantiate()
	%PopupLayer.add_child(panel)


## 显示简单提示信息
func _show_message(text: String) -> void:
	var dialog := AcceptDialog.new()
	dialog.dialog_text = text
	dialog.title = "提示"
	%PopupLayer.add_child(dialog)
	dialog.popup_centered()
	dialog.confirmed.connect(dialog.queue_free)
