## 主菜单场景
extends Control

const TITLE_TEXT := "九重黑门"
const GLITCH_CHARS := "異化防線九重黑門▓▒░█▌▐◆◇●○■□△▽◣◤"

@onready var _bg: ColorRect = $Background
@onready var _accent: ColorRect = $TopAccent
@onready var _tagline: Label = $MarginContainer/Content/TitleBox/Tagline
@onready var _title: Label = $MarginContainer/Content/TitleBox/Title
@onready var _divider: ColorRect = $MarginContainer/Content/TitleBox/Divider
@onready var _subtitle: Label = $MarginContainer/Content/TitleBox/Subtitle
@onready var _btn_box: VBoxContainer = $MarginContainer/Content/ButtonBox
@onready var _footer: Label = $MarginContainer/Content/Footer

var _particles: Control = null
var _title_settings: LabelSettings = null
var _base_shadow_color: Color = Color.TRANSPARENT
var _time: float = 0.0
var _anim_done: bool = false


func _ready() -> void:
	%BtnNewGame.pressed.connect(_on_new_game)
	%BtnContinue.pressed.connect(_on_continue)
	%BtnSettings.pressed.connect(_on_settings)
	%BtnContinue.disabled = not SaveManager.has_save(0)

	# 缓存标题阴影设置
	_title_settings = _title.label_settings
	if _title_settings:
		_base_shadow_color = _title_settings.shadow_color

	# 添加粒子背景
	_particles = Control.new()
	_particles.set_script(preload("res://scenes/main/bg_particles.gd"))
	_particles.name = "Particles"
	add_child(_particles)
	move_child(_particles, 1)

	# 等一帧确保布局计算完毕
	await get_tree().process_frame
	_play_entrance()


func _process(delta: float) -> void:
	_time += delta
	if not _anim_done:
		return
	# 标题阴影呼吸脉动
	if _title_settings:
		var pulse := 0.55 + 0.15 * sin(_time * 1.8)
		_title_settings.shadow_color = Color(
			_base_shadow_color.r, _base_shadow_color.g, _base_shadow_color.b, pulse)


## ========== 入场动画编排 ==========

func _play_entrance() -> void:
	## 隐藏所有元素
	_bg.modulate.a = 0.0
	_accent.scale.x = 0.0
	_tagline.modulate.a = 0.0
	_title.modulate.a = 0.0
	_title.text = ""
	_divider.scale.x = 0.0
	_divider.pivot_offset.x = _divider.size.x * 0.5
	_subtitle.modulate.a = 0.0
	_footer.modulate.a = 0.0
	_particles.modulate.a = 0.0

	for btn: Control in _btn_box.get_children():
		btn.modulate.a = 0.0
		btn.position.x = 50.0

	## 并行时间线
	var tw := create_tween().set_parallel(true)
	tw.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

	# t=0.0  背景淡入
	tw.tween_property(_bg, "modulate:a", 1.0, 0.6)

	# t=0.2  顶部红色条展开
	tw.tween_property(_accent, "scale:x", 1.0, 0.5).set_delay(0.2)

	# t=0.5  标语淡入
	tw.tween_property(_tagline, "modulate:a", 1.0, 0.4).set_delay(0.5)

	# t=0.7  标题解码特效
	tw.tween_property(_title, "modulate:a", 1.0, 0.01).set_delay(0.7)
	tw.tween_callback(_start_title_decode).set_delay(0.7)

	# t=0.8  粒子渐显
	tw.tween_property(_particles, "modulate:a", 1.0, 1.2).set_delay(0.8)

	# t=1.6  分隔线从中心展开
	tw.tween_property(_divider, "scale:x", 1.0, 0.4).set_delay(1.6)

	# t=1.8  英文副标题淡入
	tw.tween_property(_subtitle, "modulate:a", 1.0, 0.4).set_delay(1.8)

	# t=2.1+ 按钮依次右滑入场
	var buttons := _btn_box.get_children()
	for i: int in buttons.size():
		var d := 2.1 + i * 0.12
		tw.tween_property(buttons[i], "modulate:a", 1.0, 0.3).set_delay(d)
		tw.tween_property(buttons[i], "position:x", 0.0, 0.4).set_delay(d)

	# t=2.7  页脚淡入
	tw.tween_property(_footer, "modulate:a", 1.0, 0.5).set_delay(2.7)

	# 动画结束标记
	tw.tween_callback(func(): _anim_done = true).set_delay(3.2)


## ========== 标题"解码"特效 ==========

func _start_title_decode() -> void:
	var tw := create_tween()
	var length := TITLE_TEXT.length()

	# 乱码闪烁阶段 (8步 × 0.05s)
	for step: int in 8:
		tw.tween_callback(_set_title_garble.bind(0, length))
		tw.tween_interval(0.05)

	# 逐字解码阶段
	for i: int in range(1, length + 1):
		tw.tween_callback(_set_title_garble.bind(i, length))
		tw.tween_interval(0.1)

	# 最终定格
	tw.tween_callback(func(): _title.text = TITLE_TEXT)


func _set_title_garble(revealed: int, total: int) -> void:
	var text := ""
	for i: int in total:
		if i < revealed:
			text += TITLE_TEXT[i]
		else:
			text += GLITCH_CHARS[randi() % GLITCH_CHARS.length()]
	_title.text = text


## ========== 按钮回调 ==========

func _on_new_game() -> void:
	PlayerData.init_new_game()
	GameManager.change_state(GameManager.GameState.HUB)


func _on_continue() -> void:
	if SaveManager.load_game(0):
		if PlayerData.has_expedition_map_state():
			GameManager.change_state(GameManager.GameState.EXPEDITION)
		else:
			GameManager.change_state(GameManager.GameState.HUB)


func _on_settings() -> void:
	# TODO: 打开设置面板
	pass
