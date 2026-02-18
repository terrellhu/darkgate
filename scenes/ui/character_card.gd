## 角色卡片 UI 组件
## 显示单个角色的基本信息
extends PanelContainer

signal card_pressed(char_id: String)

var _char_id: String = ""

const RARITY_COLORS := {
	0: Color(0.6, 0.6, 0.6),    # N - 灰色
	1: Color(0.3, 0.7, 0.3),    # R - 绿色
	2: Color(0.3, 0.5, 0.9),    # SR - 蓝色
	3: Color(0.8, 0.5, 0.1),    # SSR - 橙色
}

const PROFESSION_NAMES := {
	0: "突击手", 1: "盾卫", 2: "处刑人",
	3: "瘟疫使者", 4: "脑波术士", 5: "狂暴体",
}

## 异化系职业标记（主动利用异化能力的职业，角色卡显示特殊颜色）
const ABERRATION_PROFESSIONS: Array[int] = [
	CharacterData.Profession.PLAGUE,
	CharacterData.Profession.PSION,
	CharacterData.Profession.BERSERKER,
]


func setup(char_id: String, char_data: CharacterData, runtime: Dictionary) -> void:
	_char_id = char_id
	var level: int = runtime.get("level", 1)
	var stars: int = runtime.get("stars", 1)
	var stats := PlayerData.get_character_stats(char_id)
	var hp := int(stats.get("max_hp", char_data.base_hp))
	var atk := int(stats.get("atk", char_data.base_atk))
	var def := int(stats.get("def", char_data.base_def))

	%LblName.text = char_data.display_name
	%LblLevel.text = "Lv.%d" % level
	%LblProfession.text = PROFESSION_NAMES.get(char_data.profession, "未知")
	# 异化系职业在职业名旁显示紫色（主动利用异化的职业）
	if int(char_data.profession) in ABERRATION_PROFESSIONS:
		%LblProfession.add_theme_color_override("font_color", Color(0.6, 0.2, 0.8))
	%LblStats.text = "HP:%d  ATK:%d  DEF:%d" % [hp, atk, def]

	# 稀有度星标
	%LblRarity.text = "★".repeat(stars)

	# 稀有度颜色
	var rarity_color: Color = RARITY_COLORS.get(char_data.rarity, Color.WHITE)
	%LblName.add_theme_color_override("font_color", rarity_color)


func get_char_id() -> String:
	return _char_id


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		card_pressed.emit(_char_id)
