## 设置面板
## 音量、游戏选项、存档管理
extends Control

signal close_requested

const TEXT_SPEED_OPTIONS := [
	{"label": "慢速 (0.5x)", "value": 0.5},
	{"label": "正常 (1x)", "value": 1.0},
	{"label": "快速 (2x)", "value": 2.0},
]


## 从主菜单打开时隐藏存档管理和返回主菜单按钮
var _from_main_menu := false
## 嵌入Tab页时隐藏关闭按钮
var _embedded := false


func _ready() -> void:
	_init_text_speed_options()
	_load_current_settings()
	_connect_signals()
	if _from_main_menu:
		%BtnSave.visible = false
		%BtnDeleteSave.visible = false
		%BtnBackToMenu.visible = false
	if _embedded:
		%BtnClose.visible = false


## 设置为主菜单模式（隐藏存档/返回按钮），必须在 add_child 之前调用
func set_main_menu_mode() -> void:
	_from_main_menu = true


## 设置为嵌入模式（隐藏关闭按钮），必须在 add_child 之前调用
func set_embedded_mode() -> void:
	_embedded = true


## ========== 初始化 ==========

func _init_text_speed_options() -> void:
	%OptTextSpeed.clear()
	for opt: Dictionary in TEXT_SPEED_OPTIONS:
		%OptTextSpeed.add_item(opt["label"])


func _load_current_settings() -> void:
	# 音量
	%SliderMaster.value = SettingsManager.get_master_volume()
	%SliderBgm.value = SettingsManager.get_bgm_volume()
	%SliderSfx.value = SettingsManager.get_sfx_volume()
	_update_volume_labels()

	# 游戏选项
	%ChkShake.button_pressed = SettingsManager.is_screen_shake_enabled()
	%ChkDmgNum.button_pressed = SettingsManager.is_damage_numbers_enabled()
	%ChkAutoSave.button_pressed = SettingsManager.is_auto_save_enabled()

	# 文字速度
	var speed: float = SettingsManager.get_text_speed()
	for i: int in TEXT_SPEED_OPTIONS.size():
		if absf(TEXT_SPEED_OPTIONS[i]["value"] - speed) < 0.01:
			%OptTextSpeed.selected = i
			break


func _connect_signals() -> void:
	%SliderMaster.value_changed.connect(_on_master_changed)
	%SliderBgm.value_changed.connect(_on_bgm_changed)
	%SliderSfx.value_changed.connect(_on_sfx_changed)
	%ChkShake.toggled.connect(_on_shake_toggled)
	%ChkDmgNum.toggled.connect(_on_dmg_num_toggled)
	%ChkAutoSave.toggled.connect(_on_auto_save_toggled)
	%OptTextSpeed.item_selected.connect(_on_text_speed_selected)
	%BtnSave.pressed.connect(_on_save_pressed)
	%BtnDeleteSave.pressed.connect(_on_delete_save_pressed)
	%BtnBackToMenu.pressed.connect(_on_back_to_menu_pressed)
	%BtnClose.pressed.connect(_on_close_pressed)


## ========== 音量回调 ==========

func _on_master_changed(value: float) -> void:
	SettingsManager.set_master_volume(value)
	_update_volume_labels()


func _on_bgm_changed(value: float) -> void:
	SettingsManager.set_bgm_volume(value)
	_update_volume_labels()


func _on_sfx_changed(value: float) -> void:
	SettingsManager.set_sfx_volume(value)
	_update_volume_labels()


func _update_volume_labels() -> void:
	%LblMasterVal.text = "%d%%" % int(%SliderMaster.value * 100)
	%LblBgmVal.text = "%d%%" % int(%SliderBgm.value * 100)
	%LblSfxVal.text = "%d%%" % int(%SliderSfx.value * 100)


## ========== 游戏选项回调 ==========

func _on_shake_toggled(on: bool) -> void:
	SettingsManager.set_setting("screen_shake", on)


func _on_dmg_num_toggled(on: bool) -> void:
	SettingsManager.set_setting("show_damage_numbers", on)


func _on_auto_save_toggled(on: bool) -> void:
	SettingsManager.set_setting("auto_save", on)


func _on_text_speed_selected(index: int) -> void:
	if index >= 0 and index < TEXT_SPEED_OPTIONS.size():
		SettingsManager.set_setting("text_speed", TEXT_SPEED_OPTIONS[index]["value"])


## ========== 数据管理 ==========

func _on_save_pressed() -> void:
	SaveManager.save_game(0)
	_show_toast("存档成功")


func _on_delete_save_pressed() -> void:
	var dialog := ConfirmationDialog.new()
	dialog.dialog_text = "确定要删除存档吗？此操作不可撤销。"
	dialog.title = "删除存档"
	add_child(dialog)
	dialog.popup_centered()
	dialog.confirmed.connect(func() -> void:
		SaveManager.delete_save(0)
		_show_toast("存档已删除")
		dialog.queue_free()
	)
	dialog.canceled.connect(dialog.queue_free)


func _on_back_to_menu_pressed() -> void:
	var dialog := ConfirmationDialog.new()
	dialog.dialog_text = "返回主菜单？未保存的进度将丢失。"
	dialog.title = "返回主菜单"
	add_child(dialog)
	dialog.popup_centered()
	dialog.confirmed.connect(func() -> void:
		dialog.queue_free()
		SettingsManager.save_settings()
		GameManager.change_state(GameManager.GameState.MAIN_MENU)
	)
	dialog.canceled.connect(dialog.queue_free)


func _on_close_pressed() -> void:
	SettingsManager.save_settings()
	close_requested.emit()


func _show_toast(text: String) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_color_override("font_color", Color.GREEN_YELLOW)
	lbl.set_anchors_preset(PRESET_CENTER_TOP)
	lbl.position.y = 60
	add_child(lbl)
	var tw := create_tween()
	tw.tween_interval(1.0)
	tw.tween_property(lbl, "modulate:a", 0.0, 0.5)
	tw.tween_callback(lbl.queue_free)
