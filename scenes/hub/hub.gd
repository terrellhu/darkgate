## 枢纽经营场景
extends Control

const TeamPanelScene := preload("res://scenes/ui/team_panel.tscn")
const CharacterDetailScene := preload("res://scenes/ui/character_detail_panel.tscn")
const PreparationPanelScene := preload("res://scenes/ui/preparation_panel.tscn")
const FacilityPanelScene := preload("res://scenes/ui/facility_panel.tscn")
const GrowthPanelScene := preload("res://scenes/ui/growth_panel.tscn")
const SettingsPanelScene := preload("res://scenes/ui/settings_panel.tscn")
const ToastNotification := preload("res://scenes/ui/toast_notification.gd")
const ProductionToast := preload("res://scenes/ui/production_toast.gd")

## 图片资源路径
const IMG_BG := "res://assets/images/hub/bg_hub.png"
const IMG_VIGNETTE := "res://assets/images/hub/vignette_overlay.png"
const IMG_DIVIDER := "res://assets/images/hub/divider_hub.png"
const IMG_OVERLAY_LOCKED := "res://assets/images/hub/overlay_locked.png"
const IMG_OVERLAY_UNBUILT := "res://assets/images/hub/overlay_unbuilt.png"

const FACILITY_IMAGES := {
	"reactor": "res://assets/images/hub/facility_reactor.png",
	"recruit": "res://assets/images/hub/facility_recruit.png",
	"clinic": "res://assets/images/hub/facility_clinic.png",
	"market": "res://assets/images/hub/facility_market.png",
	"forge": "res://assets/images/hub/facility_forge.png",
	"data_lab": "res://assets/images/hub/facility_data_lab.png",
}

const RESOURCE_ICONS := {
	"bio_electricity": "res://assets/images/hub/icon_bio_electricity.png",
	"nano_alloy": "res://assets/images/hub/icon_nano_alloy.png",
	"hashrate": "res://assets/images/hub/icon_hashrate.png",
	"mental_power": "res://assets/images/hub/icon_mental_power.png",
}

const RESOURCE_ICON_NODES := {
	"bio_electricity": "TopBar/TopBarBg/HBox/BioElectricity/Icon",
	"nano_alloy": "TopBar/TopBarBg/HBox/NanoAlloy/Icon",
	"hashrate": "TopBar/TopBarBg/HBox/Hashrate/Icon",
	"mental_power": "TopBar/TopBarBg/HBox/MentalPower/Icon",
}

const FACILITY_SLOT_MAP := {
	"ReactorSlot": "reactor",
	"RecruitSlot": "recruit",
	"ClinicSlot": "clinic",
	"MarketSlot": "market",
	"ForgeSlot": "forge",
	"DataLabSlot": "data_lab",
}

## Tab 名称常量
const TAB_HUB := "hub"
const TAB_TEAM := "team"
const TAB_GROWTH := "growth"
const TAB_EXPEDITION := "expedition"
const TAB_SETTINGS := "settings"

var _prev_resources: Dictionary = {}
var _tex_overlay_locked: Texture2D = null
var _tex_overlay_unbuilt: Texture2D = null
var _current_tab: String = TAB_HUB
var _tab_initialized: Dictionary = {}  # tab_name → bool，标记是否已初始化内容

## Tab 按钮与页面映射
var _tab_buttons: Dictionary = {}  # tab_name → Button
var _tab_pages: Dictionary = {}    # tab_name → Control


func _ready() -> void:
	_load_textures()
	_collect_facility_production()
	_update_resource_display()
	_update_facility_display()
	_snapshot_resources()
	EventBus.resource_changed.connect(_on_resource_changed)
	EventBus.facility_upgraded.connect(_on_facility_upgraded)

	# 连接设施槽点击
	for slot_name: String in FACILITY_SLOT_MAP:
		var slot_node: PanelContainer = %FacilityList.get_node(slot_name)
		if slot_node:
			slot_node.gui_input.connect(_on_facility_slot_input.bind(FACILITY_SLOT_MAP[slot_name]))

	# 初始化 Tab 系统
	_setup_tabs()


## ========== Tab 切换系统 ==========

func _setup_tabs() -> void:
	_tab_buttons = {
		TAB_HUB: %BtnHub,
		TAB_TEAM: %BtnTeam,
		TAB_GROWTH: %BtnGrowth,
		TAB_EXPEDITION: %BtnExpedition,
		TAB_SETTINGS: %BtnSettings,
	}
	_tab_pages = {
		TAB_HUB: %HubPage,
		TAB_TEAM: %TeamPage,
		TAB_GROWTH: %GrowthPage,
		TAB_EXPEDITION: %ExpeditionPage,
		TAB_SETTINGS: %SettingsPage,
	}

	# 连接按钮信号
	for tab_name: String in _tab_buttons:
		var btn: Button = _tab_buttons[tab_name]
		btn.pressed.connect(_switch_tab.bind(tab_name))

	# Hub 页面默认已初始化
	_tab_initialized[TAB_HUB] = true

	# 初始化按钮高亮
	_update_tab_buttons()


func _switch_tab(tab_name: String) -> void:
	if tab_name == _current_tab:
		return

	# 隐藏当前页面
	if _tab_pages.has(_current_tab):
		_tab_pages[_current_tab].visible = false

	# 惰性初始化目标页面内容
	if not _tab_initialized.get(tab_name, false):
		_init_tab_content(tab_name)
		_tab_initialized[tab_name] = true

	# 显示目标页面
	_tab_pages[tab_name].visible = true
	_current_tab = tab_name
	_update_tab_buttons()


func _init_tab_content(tab_name: String) -> void:
	var page: Control = _tab_pages[tab_name]
	match tab_name:
		TAB_TEAM:
			var panel := TeamPanelScene.instantiate()
			page.add_child(panel)
			panel.set_anchors_preset(Control.PRESET_FULL_RECT)
			panel.character_detail_requested.connect(_open_character_detail)
		TAB_GROWTH:
			var panel := GrowthPanelScene.instantiate()
			page.add_child(panel)
			panel.set_anchors_preset(Control.PRESET_FULL_RECT)
			panel.set_offsets_preset(Control.PRESET_FULL_RECT)
		TAB_EXPEDITION:
			if PlayerData.team.is_empty():
				var hint := Label.new()
				hint.text = "请先编组队伍再出发探索"
				hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
				hint.set_anchors_preset(Control.PRESET_FULL_RECT)
				page.add_child(hint)
			else:
				var panel := PreparationPanelScene.instantiate()
				page.add_child(panel)
				panel.set_anchors_preset(Control.PRESET_FULL_RECT)
				panel.set_offsets_preset(Control.PRESET_FULL_RECT)
		TAB_SETTINGS:
			var panel := SettingsPanelScene.instantiate()
			panel.set_embedded_mode()
			page.add_child(panel)
			panel.set_anchors_preset(Control.PRESET_FULL_RECT)
			panel.set_offsets_preset(Control.PRESET_FULL_RECT)


## 切换到探索页时，如果队伍状态变了需要重新初始化
func _refresh_expedition_page() -> void:
	var page: Control = _tab_pages[TAB_EXPEDITION]
	for child in page.get_children():
		child.queue_free()
	_tab_initialized[TAB_EXPEDITION] = false
	if _current_tab == TAB_EXPEDITION:
		_init_tab_content(TAB_EXPEDITION)
		_tab_initialized[TAB_EXPEDITION] = true


func _update_tab_buttons() -> void:
	for tab_name: String in _tab_buttons:
		var btn: Button = _tab_buttons[tab_name]
		if tab_name == _current_tab:
			btn.disabled = true
			btn.modulate = Color(1.0, 0.8, 0.8, 1.0)
		else:
			btn.disabled = false
			btn.modulate = Color(1.0, 1.0, 1.0, 1.0)


## ========== 加载纹理 ==========

func _load_textures() -> void:
	_try_load_texture(%BgArt, IMG_BG)
	_try_load_texture(%Vignette, IMG_VIGNETTE)
	_try_load_texture(%DividerDeco, IMG_DIVIDER)

	# 预加载遮罩纹理
	_tex_overlay_locked = _try_load(IMG_OVERLAY_LOCKED)
	_tex_overlay_unbuilt = _try_load(IMG_OVERLAY_UNBUILT)

	# 资源图标
	for resource_type: String in RESOURCE_ICONS:
		var icon_node: TextureRect = get_node_or_null(RESOURCE_ICON_NODES.get(resource_type, ""))
		if icon_node:
			_try_load_texture(icon_node, RESOURCE_ICONS[resource_type])

	# 设施卡片背景
	for slot_name: String in FACILITY_SLOT_MAP:
		var facility_id: String = FACILITY_SLOT_MAP[slot_name]
		var slot_node: PanelContainer = %FacilityList.get_node_or_null(slot_name)
		if slot_node == null:
			continue
		var card_bg: TextureRect = slot_node.get_node_or_null("CardBg")
		if card_bg and FACILITY_IMAGES.has(facility_id):
			_try_load_texture(card_bg, FACILITY_IMAGES[facility_id])


func _try_load_texture(target: TextureRect, path: String) -> void:
	if not ResourceLoader.exists(path):
		push_warning("Hub: 资源不存在 -> %s" % path)
		return
	var tex = load(path) as Texture2D
	if tex:
		target.texture = tex
	else:
		push_warning("Hub: 加载失败 -> %s" % path)


func _try_load(path: String) -> Texture2D:
	if not ResourceLoader.exists(path):
		push_warning("Hub: 资源不存在 -> %s" % path)
		return null
	var tex = load(path) as Texture2D
	if not tex:
		push_warning("Hub: 加载失败 -> %s" % path)
	return tex


## ========== 设施产出结算 ==========

## 收集设施产出（每次进入枢纽时结算）
func _collect_facility_production() -> void:
	var production := FacilityService.collect_all_production()
	if production.is_empty():
		return
	for resource_type: String in production:
		var amount: int = int(production[resource_type])
		PlayerData.modify_resource(resource_type, amount)
	# 用非阻塞浮层展示产出汇总，3秒后自动消失
	ProductionToast.show_production(self, production)


## ========== UI 更新 ==========

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
		var label: Label = slot_node.get_node("MarginContainer/Label")
		if label == null:
			continue
		var overlay: TextureRect = slot_node.get_node_or_null("Overlay")
		var config: FacilityData = DataManager.get_facility(facility_id)
		var state: Dictionary = PlayerData.facilities.get(facility_id, {})
		var level: int = int(state.get("level", 0))

		if config == null:
			label.text = "%s  [配置缺失]" % facility_id
			_set_overlay(overlay, null)
		elif level <= 0:
			if FacilityService.is_unlocked(config):
				label.text = "%s  [未建造]" % config.display_name
				_set_overlay(overlay, _tex_overlay_unbuilt)
			else:
				label.text = "%s  [未解锁 - 需通过第%d扇黑门]" % [config.display_name, config.unlock_gate]
				_set_overlay(overlay, _tex_overlay_locked)
		else:
			var workers: int = int(state.get("workers", 0))
			label.text = "%s  Lv.%d  工人:%d" % [config.display_name, level, workers]
			_set_overlay(overlay, null)


func _set_overlay(overlay: TextureRect, tex: Texture2D) -> void:
	if overlay == null:
		return
	if tex:
		overlay.texture = tex
		overlay.visible = true
	else:
		overlay.visible = false


func _snapshot_resources() -> void:
	_prev_resources = {
		"bio_electricity": PlayerData.bio_electricity,
		"nano_alloy": PlayerData.nano_alloy,
		"hashrate": PlayerData.hashrate,
		"chips": PlayerData.chips,
		"credits": PlayerData.credits,
	}


## ========== 信号回调 ==========

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


## ========== 角色详情 ==========

func _open_character_detail(char_id: String) -> void:
	var detail := CharacterDetailScene.instantiate()
	%PopupLayer.add_child(detail)
	detail.set_anchors_preset(Control.PRESET_FULL_RECT)
	detail.set_offsets_preset(Control.PRESET_FULL_RECT)
	detail.setup(char_id)
	detail.back_pressed.connect(_on_character_detail_closed.bind(detail))


func _on_character_detail_closed(detail: Control) -> void:
	detail.queue_free()
	# 刷新队伍面板
	var page: Control = _tab_pages[TAB_TEAM]
	for child in page.get_children():
		if child.has_method("refresh"):
			child.refresh()


## ========== 工具方法 ==========

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
