## 主菜单场景
extends Control

const TITLE_TEXT := "九重黑门"
const GLITCH_CHARS := "異化防線九重黑門▓▒░█▌▐◆◇●○■□△▽◣◤"

## 图片资源路径
const IMG_BG := "res://assets/images/menu/bg_main.png"
const IMG_CHAR := "res://assets/images/menu/char_main.png"
const IMG_GLOW := "res://assets/images/menu/title_glow.png"
const IMG_DIVIDER := "res://assets/images/menu/divider_ornament.png"
const IMG_BTN_NORMAL := "res://assets/images/menu/btn_normal.png"
const IMG_BTN_PRESSED := "res://assets/images/menu/btn_pressed.png"

var _title_settings: LabelSettings = null
var _base_shadow_color: Color = Color.TRANSPARENT
var _time: float = 0.0
var _anim_done: bool = false


func _ready() -> void:
	%BtnNewGame.pressed.connect(_on_new_game)
	%BtnContinue.pressed.connect(_on_continue)
	%BtnSettings.pressed.connect(_on_settings)
	%BtnContinue.disabled = not SaveManager.has_save(0)

	# 缓存标题阴影
	_title_settings = %Title.label_settings
	if _title_settings:
		_base_shadow_color = _title_settings.shadow_color

	# 加载图片资源
	_load_textures()

	# 等一帧确保布局完成
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
	# 标题光效脉动
	if %TitleGlow.texture:
		%TitleGlow.modulate.a = 0.7 + 0.3 * sin(_time * 1.5)
	# 角色立绘微呼吸
	if %CharArt.texture:
		var breath := 1.0 + 0.005 * sin(_time * 1.2)
		%CharArt.scale = Vector2(breath, breath)


## ========== 加载纹理 ==========

func _load_textures() -> void:
	_try_load_texture(%BgArt, IMG_BG)
	_try_load_texture(%CharArt, IMG_CHAR)
	_try_load_texture(%TitleGlow, IMG_GLOW)
	_try_load_texture(%DividerDeco, IMG_DIVIDER)
	# 按钮纹理
	_try_load_btn_textures()


func _try_load_texture(target: TextureRect, path: String) -> void:
	if not ResourceLoader.exists(path):
		push_warning("Menu: 资源不存在 -> %s" % path)
		return
	var tex = load(path) as Texture2D
	if tex:
		target.texture = tex
		print("Menu: 加载成功 %s (%dx%d)" % [path, tex.get_width(), tex.get_height()])
	else:
		push_warning("Menu: 加载失败 -> %s" % path)


func _try_load_btn_textures() -> void:
	var tex_normal := load(IMG_BTN_NORMAL) as Texture2D
	if not tex_normal:
		return
	# 按钮图片必须是宽扁形状(宽>高*3)才适合做按钮底图，否则保留原有StyleBoxFlat
	if tex_normal.get_width() <= tex_normal.get_height() * 3:
		push_warning("Menu: btn_normal 尺寸不适合做按钮底图 (%dx%d)，使用默认样式" \
			% [tex_normal.get_width(), tex_normal.get_height()])
		return
	var tex_pressed := load(IMG_BTN_PRESSED) as Texture2D

	for btn: Button in %ButtonBox.get_children():
		var sb_normal := _make_btn_stylebox(tex_normal)
		btn.add_theme_stylebox_override("normal", sb_normal)

		if tex_pressed:
			var sb_pressed := _make_btn_stylebox(tex_pressed)
			btn.add_theme_stylebox_override("pressed", sb_pressed)
			btn.add_theme_stylebox_override("hover", sb_pressed)


func _make_btn_stylebox(tex: Texture2D) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = tex
	sb.texture_margin_left = 24
	sb.texture_margin_right = 24
	sb.texture_margin_top = 24
	sb.texture_margin_bottom = 24
	sb.content_margin_left = 24.0
	sb.content_margin_top = 15.0
	sb.content_margin_right = 24.0
	sb.content_margin_bottom = 15.0
	return sb


## ========== 入场动画编排 ==========

func _play_entrance() -> void:
	## 隐藏所有元素
	$Background.modulate.a = 0.0
	%BgArt.modulate.a = 0.0
	%CharArt.modulate.a = 0.0
	%CharArt.position.y += 40.0
	$GradientOverlay.modulate.a = 0.0
	%Particles.modulate.a = 0.0
	$TopAccent.scale.x = 0.0
	%Tagline.modulate.a = 0.0
	%Title.modulate.a = 0.0
	%Title.text = ""
	%TitleGlow.modulate.a = 0.0
	%DividerDeco.modulate.a = 0.0
	%DividerDeco.scale.x = 0.0
	%DividerDeco.pivot_offset.x = %DividerDeco.size.x * 0.5
	%Subtitle.modulate.a = 0.0
	%Footer.modulate.a = 0.0

	for btn: Control in %ButtonBox.get_children():
		btn.modulate.a = 0.0
		btn.position.x = 50.0

	## 并行时间线
	var tw := create_tween().set_parallel(true)
	tw.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

	# t=0.0  黑底淡入
	tw.tween_property($Background, "modulate:a", 1.0, 0.3)

	# t=0.1  背景画淡入
	tw.tween_property(%BgArt, "modulate:a", 1.0, 1.0).set_delay(0.1)

	# t=0.2  顶部红线展开
	tw.tween_property($TopAccent, "scale:x", 1.0, 0.5).set_delay(0.2)

	# t=0.3  渐变遮罩淡入
	tw.tween_property($GradientOverlay, "modulate:a", 1.0, 0.8).set_delay(0.3)

	# t=0.5  角色立绘滑入 + 淡入
	tw.tween_property(%CharArt, "modulate:a", 1.0, 0.6).set_delay(0.5)
	tw.tween_property(%CharArt, "position:y", %CharArt.position.y - 40.0, 0.7).set_delay(0.5)

	# t=0.6  标语淡入
	tw.tween_property(%Tagline, "modulate:a", 1.0, 0.4).set_delay(0.6)

	# t=0.8  标题光效 + 标题解码
	tw.tween_property(%TitleGlow, "modulate:a", 0.8, 0.5).set_delay(0.8)
	tw.tween_property(%Title, "modulate:a", 1.0, 0.01).set_delay(0.8)
	tw.tween_callback(_start_title_decode).set_delay(0.8)

	# t=0.9  粒子渐显
	tw.tween_property(%Particles, "modulate:a", 1.0, 1.2).set_delay(0.9)

	# t=1.7  装饰分隔线展开
	tw.tween_property(%DividerDeco, "modulate:a", 1.0, 0.3).set_delay(1.7)
	tw.tween_property(%DividerDeco, "scale:x", 1.0, 0.4).set_delay(1.7)

	# t=1.9  副标题淡入
	tw.tween_property(%Subtitle, "modulate:a", 1.0, 0.4).set_delay(1.9)

	# t=2.2+  按钮依次滑入
	var buttons := %ButtonBox.get_children()
	for i: int in buttons.size():
		var d := 2.2 + i * 0.12
		tw.tween_property(buttons[i], "modulate:a", 1.0, 0.3).set_delay(d)
		tw.tween_property(buttons[i], "position:x", 0.0, 0.4).set_delay(d)

	# t=2.8  页脚淡入
	tw.tween_property(%Footer, "modulate:a", 1.0, 0.5).set_delay(2.8)

	# 动画结束
	tw.tween_callback(func(): _anim_done = true).set_delay(3.3)


## ========== 标题"解码"特效 ==========

func _start_title_decode() -> void:
	var tw := create_tween()
	var length := TITLE_TEXT.length()

	# 乱码闪烁阶段 (8步)
	for step: int in 8:
		tw.tween_callback(_set_title_garble.bind(0, length))
		tw.tween_interval(0.05)

	# 逐字解码阶段
	for i: int in range(1, length + 1):
		tw.tween_callback(_set_title_garble.bind(i, length))
		tw.tween_interval(0.1)

	# 最终定格
	tw.tween_callback(func(): %Title.text = TITLE_TEXT)


func _set_title_garble(revealed: int, total: int) -> void:
	var text := ""
	for i: int in total:
		if i < revealed:
			text += TITLE_TEXT[i]
		else:
			text += GLITCH_CHARS[randi() % GLITCH_CHARS.length()]
	%Title.text = text


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
