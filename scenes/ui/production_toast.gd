## 设施产出汇总浮层
## 非阻塞式通知，自动消失，不影响下方按钮交互
extends Control

const SLIDE_DURATION := 0.4
const SHOW_DURATION := 3.0
const FADE_DURATION := 0.6

const IMG_BG := "res://assets/images/hub/toast_production_bg.png"
const IMG_DIVIDER := "res://assets/images/hub/toast_production_divider.png"
const IMG_FRAME := "res://assets/images/hub/toast_production_frame.png"

const RESOURCE_DISPLAY := {
	"bio_electricity": "生物电",
	"nano_alloy": "合金",
	"hashrate": "算力",
	"mental_power": "精神力",
	"chips": "芯片",
	"credits": "信用点",
}

const RESOURCE_ICONS := {
	"bio_electricity": "res://assets/images/hub/icon_bio_electricity.png",
	"nano_alloy": "res://assets/images/hub/icon_nano_alloy.png",
	"hashrate": "res://assets/images/hub/icon_hashrate.png",
	"mental_power": "res://assets/images/hub/icon_mental_power.png",
}

var _timer := 0.0
var _phase: int = 0  ## 0=滑入, 1=显示, 2=淡出
var _target_y := 60.0


static func show_production(parent: Node, production: Dictionary) -> void:
	if production.is_empty():
		return
	var toast := _build(production)
	parent.add_child(toast)


static func _build(production: Dictionary) -> Control:
	var toast := Control.new()
	toast.set_script(preload("res://scenes/ui/production_toast.gd"))
	toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast.z_index = 100

	# ---- 背景 NinePatchRect ----
	var bg := NinePatchRect.new()
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg_tex = load(IMG_BG) as Texture2D
	if bg_tex:
		bg.texture = bg_tex
		# 9-patch 切片边距（根据 512×128 素材，四边各留 16px 不拉伸）
		bg.patch_margin_left = 16
		bg.patch_margin_top = 16
		bg.patch_margin_right = 16
		bg.patch_margin_bottom = 16
	else:
		# 回退：纯色面板
		var fallback := ColorRect.new()
		fallback.color = Color(0.04, 0.02, 0.06, 0.92)
		fallback.mouse_filter = Control.MOUSE_FILTER_IGNORE
		fallback.set_anchors_preset(Control.PRESET_FULL_RECT)
		toast.add_child(fallback)
	toast.add_child(bg)

	# ---- 外框光效 NinePatchRect ----
	var frame := NinePatchRect.new()
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	var frame_tex = load(IMG_FRAME) as Texture2D
	if frame_tex:
		frame.texture = frame_tex
		frame.patch_margin_left = 16
		frame.patch_margin_top = 16
		frame.patch_margin_right = 16
		frame.patch_margin_bottom = 16
	toast.add_child(frame)

	# ---- 内容区 MarginContainer ----
	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	toast.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_theme_constant_override("separation", 6)
	margin.add_child(vbox)

	# ---- 标题 ----
	var title := Label.new()
	title.text = "⚡ 设施产出结算"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var title_settings := LabelSettings.new()
	title_settings.font_size = 16
	title_settings.font_color = Color(0.95, 0.85, 0.6, 1.0)
	title_settings.outline_size = 1
	title_settings.outline_color = Color(0, 0, 0, 0.6)
	title.label_settings = title_settings
	vbox.add_child(title)

	# ---- 分割线（图片） ----
	var divider := TextureRect.new()
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	divider.custom_minimum_size = Vector2(0, 8)
	divider.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	divider.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	var div_tex = load(IMG_DIVIDER) as Texture2D
	if div_tex:
		divider.texture = div_tex
	vbox.add_child(divider)

	# ---- 资源条目 ----
	var item_settings := LabelSettings.new()
	item_settings.font_size = 14
	item_settings.font_color = Color(0.85, 0.85, 0.9, 1.0)

	var amount_settings := LabelSettings.new()
	amount_settings.font_size = 15
	amount_settings.font_color = Color(0.4, 1.0, 0.5, 1.0)
	amount_settings.outline_size = 1
	amount_settings.outline_color = Color(0, 0, 0, 0.5)

	for resource_type: String in production:
		var amount: int = int(production[resource_type])
		if amount == 0:
			continue
		var hbox := HBoxContainer.new()
		hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hbox.add_theme_constant_override("separation", 8)
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER

		# 资源图标
		if RESOURCE_ICONS.has(resource_type):
			var icon := TextureRect.new()
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			icon.custom_minimum_size = Vector2(20, 20)
			icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			var tex = load(RESOURCE_ICONS[resource_type]) as Texture2D
			if tex:
				icon.texture = tex
			hbox.add_child(icon)

		# 资源名
		var name_label := Label.new()
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		name_label.text = RESOURCE_DISPLAY.get(resource_type, resource_type)
		name_label.label_settings = item_settings
		hbox.add_child(name_label)

		# 产出量
		var amount_label := Label.new()
		amount_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		amount_label.text = "+%d" % amount
		amount_label.label_settings = amount_settings
		hbox.add_child(amount_label)

		vbox.add_child(hbox)

	return toast


func _ready() -> void:
	# 等待一帧让布局计算完成，然后根据内容自适应尺寸
	await get_tree().process_frame
	# 手动收缩到内容尺寸
	var vp_width := get_viewport_rect().size.x
	var content_size := _get_content_size()
	size = content_size
	position.x = (vp_width - content_size.x) / 2.0
	position.y = -content_size.y
	_target_y = 60.0
	_phase = 0
	_timer = 0.0


func _get_content_size() -> Vector2:
	for child in get_children():
		if child is MarginContainer:
			var min_size: Vector2 = child.get_combined_minimum_size()
			# 加上 margin 本身的边距
			return Vector2(
				maxf(min_size.x, 280.0),
				min_size.y
			)
	return Vector2(280, 120)


func _process(delta: float) -> void:
	_timer += delta
	match _phase:
		0:  ## 滑入（带缓动）
			var t := minf(_timer / SLIDE_DURATION, 1.0)
			var ease_t := 1.0 - pow(1.0 - t, 3.0)  # ease-out cubic
			position.y = lerpf(-size.y, _target_y, ease_t)
			if _timer >= SLIDE_DURATION:
				_timer = 0.0
				_phase = 1
		1:  ## 显示
			if _timer >= SHOW_DURATION:
				_timer = 0.0
				_phase = 2
		2:  ## 淡出 + 上移
			var t := minf(_timer / FADE_DURATION, 1.0)
			var ease_t := t * t  # ease-in quad
			modulate.a = 1.0 - ease_t
			position.y = lerpf(_target_y, _target_y - 20.0, ease_t)
			if _timer >= FADE_DURATION:
				queue_free()
