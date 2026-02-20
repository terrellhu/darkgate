## 通知浮层（Toast）
## 在屏幕顶部显示短暂的提示信息，自动消失
extends PanelContainer

const SLIDE_DURATION := 0.3  ## 滑入时间
const SHOW_DURATION := 2.0   ## 显示时间
const FADE_DURATION := 0.5   ## 淡出时间

@onready var _label: Label = $Label

var _timer := 0.0
var _phase: int = 0  ## 0=滑入, 1=显示, 2=淡出


## 创建一个 Toast 并添加到场景树
## parent: 挂载节点
## text: 显示文本
## color: 文字颜色
static func show_toast(parent: Node, text: String, color: Color = Color.WHITE) -> void:
	var toast_scene := preload("res://scenes/ui/toast_notification.tscn")
	var toast := toast_scene.instantiate()
	parent.add_child(toast)
	toast._setup(text, color)


func _setup(text: String, color: Color) -> void:
	## 延迟到 _ready 之后设置，确保 _label 已就绪
	await ready
	_label.text = text
	_label.add_theme_color_override("font_color", color)
	## 初始位置：屏幕上方外
	position.y = -size.y
	_phase = 0
	_timer = 0.0


func _process(delta: float) -> void:
	_timer += delta
	match _phase:
		0:  ## 滑入
			var progress := minf(_timer / SLIDE_DURATION, 1.0)
			position.y = lerpf(-size.y, 8.0, progress)
			if _timer >= SLIDE_DURATION:
				_timer = 0.0
				_phase = 1
		1:  ## 显示
			if _timer >= SHOW_DURATION:
				_timer = 0.0
				_phase = 2
		2:  ## 淡出
			var progress := minf(_timer / FADE_DURATION, 1.0)
			modulate.a = 1.0 - progress
			if _timer >= FADE_DURATION:
				queue_free()
