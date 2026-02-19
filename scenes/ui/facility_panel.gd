## 设施管理面板
## 显示设施信息并提供升级和工人分配操作
extends PanelContainer

var _facility_id: String = ""


func setup(facility_id: String) -> void:
	_facility_id = facility_id
	_refresh()


func _ready() -> void:
	%BtnClose.pressed.connect(queue_free)
	%BtnUpgrade.pressed.connect(_on_upgrade)
	%BtnWorkerPlus.pressed.connect(_on_worker_change.bind(1))
	%BtnWorkerMinus.pressed.connect(_on_worker_change.bind(-1))


func _refresh() -> void:
	var config: FacilityData = DataManager.get_facility(_facility_id)
	if config == null:
		return
	var state: Dictionary = PlayerData.facilities.get(_facility_id, {})
	var level: int = int(state.get("level", 0))
	var workers: int = int(state.get("workers", 0))
	var max_workers := FacilityService.get_max_workers(config, level)
	var output := FacilityService.calculate_output(config, level, workers)

	%LblName.text = "%s  Lv.%d" % [config.display_name, level]
	%LblDescription.text = config.description
	%LblWorkers.text = "工人: %d / %d" % [workers, max_workers]

	if output > 0:
		%LblOutput.text = "产出: %s +%d / 周期" % [_resource_display_name(config.produces_resource), output]
	else:
		%LblOutput.text = "无资源产出"

	# 升级按钮
	if level >= config.max_level:
		%BtnUpgrade.text = "已满级"
		%BtnUpgrade.disabled = true
	else:
		var cost := FacilityService.get_upgrade_cost(config, level)
		%BtnUpgrade.text = "升级 (合金:%d 芯片:%d)" % [cost["nano_alloy"], cost["chips"]]
		%BtnUpgrade.disabled = not FacilityService.can_afford_upgrade(config, level)

	# 工人按钮
	var pool_available := PlayerData.get_max_workers() - PlayerData.get_total_assigned_workers()
	%BtnWorkerPlus.disabled = workers >= max_workers or pool_available <= 0
	%BtnWorkerMinus.disabled = workers <= 0

	%LblWorkerPool.text = "可用工人: %d / %d" % [pool_available + workers, PlayerData.get_max_workers()]


func _on_upgrade() -> void:
	if PlayerData.upgrade_facility(_facility_id):
		_refresh()
		SaveManager.save_game(0)


func _on_worker_change(delta: int) -> void:
	var state: Dictionary = PlayerData.facilities.get(_facility_id, {})
	var current: int = int(state.get("workers", 0))
	PlayerData.set_facility_workers(_facility_id, current + delta)
	_refresh()
	SaveManager.save_game(0)


func _resource_display_name(resource_type: String) -> String:
	match resource_type:
		"bio_electricity": return "生物电"
		"nano_alloy": return "合金"
		"chips": return "芯片"
		"hashrate": return "算力"
		"credits": return "信用点"
		_: return resource_type
