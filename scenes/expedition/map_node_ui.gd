## 地图节点 UI
## 单个探索格子的显示和交互
extends Button

signal node_clicked(node_id: String)

var node_data: MapNodeData
var is_current: bool = false
var is_reachable: bool = false
var is_visited: bool = false

## 节点类型对应的文字图标
const TYPE_ICONS := {
	MapNodeData.NodeType.EMPTY: "·",
	MapNodeData.NodeType.BATTLE: "☠",
	MapNodeData.NodeType.EVENT: "?",
	MapNodeData.NodeType.TREASURE: "□",
	MapNodeData.NodeType.TERMINAL: "◈",
	MapNodeData.NodeType.SUPPLY: "+",
	MapNodeData.NodeType.BOSS: "◆",
	MapNodeData.NodeType.ENTRANCE: "▽",
	MapNodeData.NodeType.EXIT: "△",
}

const COLOR_CURRENT := Color(0.2, 0.9, 0.3)
const COLOR_REACHABLE := Color(0.5, 0.7, 0.9)
const COLOR_VISITED := Color(0.4, 0.4, 0.4)
const COLOR_HIDDEN := Color(0.2, 0.2, 0.2)
const COLOR_DEFAULT := Color(0.6, 0.6, 0.6)


func setup(data: MapNodeData) -> void:
	node_data = data
	custom_minimum_size = Vector2(60, 60)
	pressed.connect(_on_pressed)
	update_display()


func update_display() -> void:
	if is_current:
		text = "★"
		add_theme_color_override("font_color", COLOR_CURRENT)
		add_theme_color_override("font_hover_color", COLOR_CURRENT)
	elif is_visited or node_data.revealed:
		text = TYPE_ICONS.get(node_data.node_type, "?")
		var color := COLOR_VISITED if is_visited else COLOR_DEFAULT
		add_theme_color_override("font_color", color)
		add_theme_color_override("font_hover_color", color)
	else:
		text = "■"
		add_theme_color_override("font_color", COLOR_HIDDEN)
		add_theme_color_override("font_hover_color", COLOR_HIDDEN)

	# 可达节点高亮边框
	if is_reachable and not is_current:
		add_theme_color_override("font_color", COLOR_REACHABLE)
		add_theme_color_override("font_hover_color", COLOR_REACHABLE)

	disabled = not is_reachable and not is_current


func _on_pressed() -> void:
	node_clicked.emit(node_data.id)
