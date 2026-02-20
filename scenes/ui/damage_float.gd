## 浮动伤害/治疗数字
## 从指定位置向上飘出并淡出
extends Label

const FLOAT_SPEED := 60.0   ## 上浮速度（像素/秒）
const DURATION := 0.8        ## 持续时间（秒）
const CRIT_SCALE := 1.5      ## 暴击时字体放大倍数

var _elapsed := 0.0


## 初始化浮动数字
## amount: 数值（正=伤害/治疗，负=无效）
## type: "damage" | "heal" | "miss" | "crit" | "shield" | "status"
static func create(amount: int, type: String = "damage") -> Label:
	var label := Label.new()
	label.set_script(load("res://scenes/ui/damage_float.gd"))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.z_index = 100

	match type:
		"damage":
			label.text = "-%d" % amount
			label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.2))
		"crit":
			label.text = "-%d!" % amount
			label.add_theme_color_override("font_color", Color(1.0, 0.1, 0.0))
			label.scale = Vector2(CRIT_SCALE, CRIT_SCALE)
		"heal":
			label.text = "+%d" % amount
			label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
		"shield":
			label.text = "+%d" % amount
			label.add_theme_color_override("font_color", Color(0.4, 0.7, 1.0))
		"miss":
			label.text = "闪避"
			label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		"status":
			label.text = str(amount) if amount != 0 else ""
			label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))

	return label


func _process(delta: float) -> void:
	_elapsed += delta
	position.y -= FLOAT_SPEED * delta

	## 淡出
	var progress := _elapsed / DURATION
	modulate.a = clampf(1.0 - progress, 0.0, 1.0)

	if _elapsed >= DURATION:
		queue_free()
