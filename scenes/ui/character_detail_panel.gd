## 角色详情面板
## 显示角色全身立绘、属性、装备、技能
extends Control

signal back_pressed

const EquipmentService := preload("res://scripts/character/equipment_service.gd")

const FULL_IMG_TEMPLATE := "res://assets/images/characters/%s_full.png"
const DETAIL_BG_PATH := "res://assets/images/team/detail_bg.png"

const PROFESSION_NAMES := {
	0: "突击手", 1: "盾卫", 2: "处刑人",
	3: "瘟疫使者", 4: "脑波术士", 5: "狂暴体",
}

const RARITY_COLORS := {
	0: Color(0.6, 0.6, 0.6),    # N
	1: Color(0.3, 0.7, 0.3),    # R
	2: Color(0.3, 0.5, 0.9),    # SR
	3: Color(0.8, 0.5, 0.1),    # SSR
}

const SKILL_TYPE_NAMES := {
	0: "物理", 1: "异化", 2: "治疗",
	3: "增益", 4: "减益", 5: "控制", 6: "被动",
}

const SLOT_DISPLAY_NAMES := {
	"WEAPON": "武器",
	"HEAD": "头部",
	"BODY": "躯干",
	"ARMS": "手臂",
	"LEGS": "腿部",
	"ACCESSORY_A": "配件A",
	"ACCESSORY_B": "配件B",
}

var _char_id: String = ""
var _current_tab: int = 0  # 0=属性 1=装备 2=技能


func _ready() -> void:
	%BtnBack.pressed.connect(_on_back)
	%BtnRemove.pressed.connect(_on_remove)
	%BtnTabStats.pressed.connect(_switch_tab.bind(0))
	%BtnTabEquip.pressed.connect(_switch_tab.bind(1))
	%BtnTabSkills.pressed.connect(_switch_tab.bind(2))

	# 加载详情页背景
	if ResourceLoader.exists(DETAIL_BG_PATH):
		var tex := load(DETAIL_BG_PATH) as Texture2D
		if tex:
			%DetailBg.texture = tex


func setup(char_id: String) -> void:
	_char_id = char_id
	_current_tab = 0
	_refresh()


func _refresh() -> void:
	if _char_id.is_empty():
		return
	var char_data: CharacterData = DataManager.get_character(_char_id)
	if char_data == null:
		return
	var runtime: Dictionary = PlayerData.get_character_runtime(_char_id)
	var stats: Dictionary = PlayerData.get_character_stats(_char_id)
	var level: int = int(runtime.get("level", 1))
	var stars: int = int(runtime.get("stars", 1))

	# 头部信息
	%LblName.text = char_data.display_name
	var rarity_color: Color = RARITY_COLORS.get(char_data.rarity, Color.WHITE)
	%LblName.add_theme_color_override("font_color", rarity_color)
	%LblProfession.text = PROFESSION_NAMES.get(char_data.profession, "未知")
	%LblLevelStars.text = "Lv.%d  %s" % [level, "★".repeat(stars)]
	%LblDesc.text = char_data.description

	# 移出队伍按钮
	%BtnRemove.visible = PlayerData.is_in_team(_char_id)

	# 全身立绘
	_load_full_portrait(_char_id)

	# Tab内容
	_update_tab_buttons()
	_refresh_tab_content(char_data, runtime, stats)


func _load_full_portrait(char_id: String) -> void:
	var path := FULL_IMG_TEMPLATE % char_id
	if ResourceLoader.exists(path):
		var tex := load(path) as Texture2D
		if tex:
			%FullPortrait.texture = tex
	else:
		%FullPortrait.texture = null


func _switch_tab(tab: int) -> void:
	_current_tab = tab
	_update_tab_buttons()
	var char_data: CharacterData = DataManager.get_character(_char_id)
	if char_data == null:
		return
	var runtime: Dictionary = PlayerData.get_character_runtime(_char_id)
	var stats: Dictionary = PlayerData.get_character_stats(_char_id)
	_refresh_tab_content(char_data, runtime, stats)


func _update_tab_buttons() -> void:
	var buttons := [%BtnTabStats, %BtnTabEquip, %BtnTabSkills]
	for i in buttons.size():
		buttons[i].disabled = (i == _current_tab)
		if i == _current_tab:
			buttons[i].modulate = Color(1.0, 0.8, 0.8, 1.0)
		else:
			buttons[i].modulate = Color(1.0, 1.0, 1.0, 1.0)


func _refresh_tab_content(char_data: CharacterData, runtime: Dictionary, stats: Dictionary) -> void:
	for child in %TabContent.get_children():
		child.queue_free()

	match _current_tab:
		0: _build_stats_tab(char_data, runtime, stats)
		1: _build_equip_tab(runtime)
		2: _build_skills_tab(char_data, runtime)


## ========== 属性 Tab ==========

func _build_stats_tab(char_data: CharacterData, runtime: Dictionary, stats: Dictionary) -> void:
	var level: int = int(runtime.get("level", 1))
	var xp: int = int(runtime.get("xp", 0))
	var xp_needed := GrowthService.xp_to_next_level(level)
	var stars: int = int(runtime.get("stars", 1))

	# 经验
	if xp_needed > 0:
		_add_stat_line("经验", "%d / %d" % [xp, xp_needed])
	else:
		_add_stat_line("经验", "%d (满级)" % xp)

	_add_separator()

	# 主属性
	_add_stat_line("HP", str(int(stats.get("max_hp", 0))))
	_add_stat_line("ATK", str(int(stats.get("atk", 0))))
	_add_stat_line("DEF", str(int(stats.get("def", 0))))
	_add_stat_line("SPD", str(int(stats.get("speed", 0))))

	_add_separator()

	# 暴击
	_add_stat_line("暴击率", "%.1f%%" % (float(stats.get("crit_rate", 0)) * 100))
	_add_stat_line("暴击伤害", "%.1fx" % float(stats.get("crit_damage", 1.5)))

	_add_separator()

	# 次属性
	_add_stat_line("命中修正", "%.0f%%" % (float(stats.get("hit_rate", 1.0)) * 100))
	_add_stat_line("闪避率", "%.1f%%" % (float(stats.get("dodge_rate", 0)) * 100))
	_add_stat_line("穿甲", "%.0f%%" % (float(stats.get("armor_pen", 0)) * 100))
	_add_stat_line("效果命中", "%.0f%%" % (float(stats.get("effect_hit", 0)) * 100))
	_add_stat_line("效果抵抗", "%.0f%%" % (float(stats.get("effect_resist", 0)) * 100))

	_add_separator()

	# 异化
	var aberration: float = float(runtime.get("current_aberration", 0))
	_add_stat_line("异化值", "%.0f / %.0f" % [aberration, char_data.max_aberration])
	_add_stat_line("异化/技能", "%.0f" % char_data.aberration_per_skill)

	# 星升按钮
	_add_separator()
	if stars >= GrowthService.MAX_STARS:
		_add_info_line("满星")
	else:
		var cost := GrowthService.get_star_upgrade_cost(stars)
		var btn := Button.new()
		btn.text = "星升 (芯片:%d 合金:%d)" % [cost["chips"], cost["nano_alloy"]]
		btn.disabled = PlayerData.chips < cost["chips"] or PlayerData.nano_alloy < cost["nano_alloy"]
		btn.pressed.connect(_on_star_upgrade)
		%TabContent.add_child(btn)


## ========== 装备 Tab ==========

func _build_equip_tab(runtime: Dictionary) -> void:
	var equip: Dictionary = EquipmentService.normalize_hero_equipment(runtime.get("equipment", {}))
	var enhancements: Dictionary = runtime.get("enhancements", {})
	var slots := ["WEAPON", "HEAD", "BODY", "ARMS", "LEGS", "ACCESSORY_A", "ACCESSORY_B"]

	for slot in slots:
		var item_id: String = String(equip.get(slot, ""))
		var slot_name: String = SLOT_DISPLAY_NAMES.get(slot, slot)

		if item_id.is_empty():
			_add_equip_slot_empty(slot_name)
			continue

		var item: ItemData = DataManager.get_item(item_id)
		var item_name := item.display_name if item != null else item_id
		var enhance_lv: int = int(enhancements.get(item_id, 0))

		var hbox := HBoxContainer.new()
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var info := VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var name_lbl := Label.new()
		name_lbl.text = "%s: %s" % [slot_name, item_name]
		name_lbl.add_theme_color_override("font_color", Color(0.92, 0.88, 0.83))
		info.add_child(name_lbl)

		var enhance_lbl := Label.new()
		enhance_lbl.text = "强化 +%d" % enhance_lv
		enhance_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		enhance_lbl.add_theme_font_size_override("font_size", 12)
		info.add_child(enhance_lbl)

		hbox.add_child(info)

		# 强化按钮
		if enhance_lv < GrowthService.MAX_ENHANCE_LEVEL:
			var cost := GrowthService.get_enhance_cost(enhance_lv)
			var btn := Button.new()
			btn.text = "强化"
			btn.custom_minimum_size = Vector2(60, 0)
			btn.disabled = PlayerData.nano_alloy < cost["nano_alloy"] or PlayerData.bio_electricity < cost["bio_electricity"]
			btn.pressed.connect(_on_enhance.bind(slot))
			hbox.add_child(btn)
		else:
			var max_lbl := Label.new()
			max_lbl.text = "MAX"
			max_lbl.add_theme_color_override("font_color", Color(0.8, 0.5, 0.1))
			hbox.add_child(max_lbl)

		# 卸下按钮
		var unequip_btn := Button.new()
		unequip_btn.text = "卸下"
		unequip_btn.custom_minimum_size = Vector2(60, 0)
		unequip_btn.pressed.connect(_on_unequip.bind(slot))
		hbox.add_child(unequip_btn)

		%TabContent.add_child(hbox)

	_add_separator()

	# 可装备物品列表
	_add_info_line("— 背包中的可装备物品 —")
	var inventory := PlayerData.get_inventory_items()
	var has_equippable := false
	for item_id: String in inventory:
		var count: int = int(inventory[item_id])
		if count <= 0:
			continue
		var item: ItemData = DataManager.get_item(item_id)
		if item == null:
			continue
		if not _is_equippable(item):
			continue
		has_equippable = true
		var hbox := HBoxContainer.new()
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var lbl := Label.new()
		lbl.text = "%s x%d" % [item.display_name, count]
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9))
		hbox.add_child(lbl)

		# 找到适配的槽位并添加装备按钮
		var target_slot := _get_item_slot(item)
		if not target_slot.is_empty():
			var btn := Button.new()
			btn.text = "装备→%s" % SLOT_DISPLAY_NAMES.get(target_slot, target_slot)
			btn.pressed.connect(_on_equip_item.bind(target_slot, item_id))
			hbox.add_child(btn)

		%TabContent.add_child(hbox)

	if not has_equippable:
		_add_info_line("无可装备物品")


## ========== 技能 Tab ==========

func _build_skills_tab(char_data: CharacterData, runtime: Dictionary) -> void:
	var skills := PlayerData.get_character_skills(_char_id)

	if skills.is_empty():
		_add_info_line("无技能")
		return

	for skill in skills:
		var vbox := VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var type_str: String = SKILL_TYPE_NAMES.get(skill.skill_type, "未知")

		var name_lbl := Label.new()
		name_lbl.text = "%s [%s]" % [skill.display_name, type_str]
		name_lbl.add_theme_color_override("font_color", Color(0.92, 0.88, 0.83))
		vbox.add_child(name_lbl)

		if not skill.description.is_empty():
			var desc_lbl := Label.new()
			desc_lbl.text = skill.description
			desc_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
			desc_lbl.add_theme_font_size_override("font_size", 12)
			desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			vbox.add_child(desc_lbl)

		# 关键数值
		var details := ""
		if skill.base_damage > 0:
			details += "基伤:%d " % skill.base_damage
		if skill.damage_multiplier > 0 and skill.skill_type != SkillData.SkillType.HEAL:
			details += "倍率:%.1fx " % skill.damage_multiplier
		if skill.heal_multiplier > 0:
			details += "治疗:%.1fx " % skill.heal_multiplier
		if skill.cooldown > 0:
			details += "CD:%d回合 " % skill.cooldown
		if skill.aberration_cost > 0:
			details += "异化消耗:%.0f " % skill.aberration_cost

		if not details.is_empty():
			var detail_lbl := Label.new()
			detail_lbl.text = details.strip_edges()
			detail_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
			detail_lbl.add_theme_font_size_override("font_size", 11)
			vbox.add_child(detail_lbl)

		%TabContent.add_child(vbox)
		_add_separator()


## ========== 事件回调 ==========

func _on_back() -> void:
	back_pressed.emit()


func _on_remove() -> void:
	PlayerData.remove_from_team(_char_id)
	SaveManager.save_game(0)
	back_pressed.emit()


func _on_star_upgrade() -> void:
	if PlayerData.star_upgrade(_char_id):
		SaveManager.save_game(0)
		_refresh()


func _on_enhance(slot: String) -> void:
	if PlayerData.enhance_equipment(_char_id, slot):
		SaveManager.save_game(0)
		_refresh()


func _on_unequip(slot: String) -> void:
	if PlayerData.unequip_item_from_character(_char_id, slot):
		SaveManager.save_game(0)
		_refresh()


func _on_equip_item(slot: String, item_id: String) -> void:
	if PlayerData.equip_item_to_character(_char_id, slot, item_id):
		SaveManager.save_game(0)
		_refresh()


## ========== 辅助方法 ==========

func _add_stat_line(label: String, value: String) -> void:
	var hbox := HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var lbl := Label.new()
	lbl.text = label
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	hbox.add_child(lbl)

	var val := Label.new()
	val.text = value
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	val.add_theme_color_override("font_color", Color(0.92, 0.88, 0.83))
	hbox.add_child(val)

	%TabContent.add_child(hbox)


func _add_separator() -> void:
	var sep := HSeparator.new()
	%TabContent.add_child(sep)


func _add_info_line(text: String) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	%TabContent.add_child(lbl)


func _add_equip_slot_empty(slot_name: String) -> void:
	var lbl := Label.new()
	lbl.text = "%s: [空]" % slot_name
	lbl.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	%TabContent.add_child(lbl)


func _is_equippable(item: ItemData) -> bool:
	return item.item_type == ItemData.ItemType.WEAPON or item.item_type == ItemData.ItemType.ARMOR or item.item_type == ItemData.ItemType.ACCESSORY


const EQUIP_SLOT_MAP := {
	ItemData.EquipSlot.SLOT_WEAPON: "WEAPON",
	ItemData.EquipSlot.SLOT_HEAD: "HEAD",
	ItemData.EquipSlot.SLOT_BODY: "BODY",
	ItemData.EquipSlot.SLOT_ARMS: "ARMS",
	ItemData.EquipSlot.SLOT_LEGS: "LEGS",
	ItemData.EquipSlot.SLOT_ACCESSORY: "ACCESSORY_A",
}


func _get_item_slot(item: ItemData) -> String:
	return EQUIP_SLOT_MAP.get(item.equip_slot, "")
