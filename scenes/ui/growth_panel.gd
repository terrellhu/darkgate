## 成长面板
## 显示角色升级、装备强化、技能树、星级突破
extends PanelContainer

const EquipmentService := preload("res://scripts/character/equipment_service.gd")

var _char_ids: Array[String] = []
var _current_index: int = 0
var _current_char_id: String = ""


func _ready() -> void:
	%BtnPrevChar.pressed.connect(_on_switch_char.bind(-1))
	%BtnNextChar.pressed.connect(_on_switch_char.bind(1))
	%BtnStarUpgrade.pressed.connect(_on_star_upgrade)
	%TabContainer.tab_changed.connect(_on_tab_changed)

	# 收集所有已拥有角色
	for char_id: String in PlayerData.owned_characters:
		_char_ids.append(char_id)
	if _char_ids.is_empty():
		return
	_current_index = 0
	_current_char_id = _char_ids[0]
	_refresh()


func _on_switch_char(delta: int) -> void:
	if _char_ids.is_empty():
		return
	_current_index = (_current_index + delta) % _char_ids.size()
	if _current_index < 0:
		_current_index += _char_ids.size()
	_current_char_id = _char_ids[_current_index]
	_refresh()


func _on_tab_changed(_tab: int) -> void:
	_refresh()


func _refresh() -> void:
	if _current_char_id.is_empty():
		return
	var char_data: CharacterData = DataManager.get_character(_current_char_id)
	if char_data == null:
		return
	var runtime: Dictionary = PlayerData.owned_characters.get(_current_char_id, {})
	var stats: Dictionary = PlayerData.get_character_stats(_current_char_id)
	var level: int = int(runtime.get("level", 1))
	var stars: int = int(runtime.get("stars", 1))
	var xp: int = int(runtime.get("xp", 0))
	var xp_needed := GrowthService.xp_to_next_level(level)

	# 头部：角色名/职业/等级/星级
	var prof_name := _profession_name(char_data.profession)
	%LblCharName.text = "%s (%s)" % [char_data.display_name, prof_name]
	var star_text := ""
	for i in stars:
		star_text += "*"
	%LblCharLevel.text = "Lv.%d  %s  (%d/%d)" % [level, star_text, _current_index + 1, _char_ids.size()]

	# Tab 0: 升级
	_refresh_level_tab(level, xp, xp_needed, stars, stats)
	# Tab 1: 强化
	_refresh_enhance_tab(runtime)
	# Tab 2: 技能树
	_refresh_tree_tab(char_data, runtime)


func _refresh_level_tab(level: int, xp: int, xp_needed: int, stars: int, stats: Dictionary) -> void:
	var star_str := ""
	for i in stars:
		star_str += "*"
	if xp_needed > 0:
		%LblLevelInfo.text = "等级: Lv.%d  %s\n经验: %d / %d" % [level, star_str, xp, xp_needed]
	else:
		%LblLevelInfo.text = "等级: Lv.%d  %s (满级)\n经验: %d" % [level, star_str, xp]
	%LblStats.text = "HP:%d  ATK:%d  DEF:%d  SPD:%d\n暴击:%.0f%%  暴伤:%.1fx" % [
		int(stats.get("max_hp", 0)), int(stats.get("atk", 0)),
		int(stats.get("def", 0)), int(stats.get("speed", 0)),
		float(stats.get("crit_rate", 0)) * 100, float(stats.get("crit_damage", 1.5)),
	]
	# 星级突破
	if stars >= GrowthService.MAX_STARS:
		%BtnStarUpgrade.text = "满星"
		%BtnStarUpgrade.disabled = true
	else:
		var cost := GrowthService.get_star_upgrade_cost(stars)
		%BtnStarUpgrade.text = "星升 (芯片:%d 合金:%d)" % [cost["chips"], cost["nano_alloy"]]
		%BtnStarUpgrade.disabled = PlayerData.chips < cost["chips"] or PlayerData.nano_alloy < cost["nano_alloy"]


func _refresh_enhance_tab(runtime: Dictionary) -> void:
	# 清除旧条目
	for child in %EnhanceList.get_children():
		child.queue_free()

	var equip: Dictionary = EquipmentService.normalize_hero_equipment(runtime.get("equipment", {}))
	var enhancements: Dictionary = runtime.get("enhancements", {})
	var slots := ["WEAPON", "HEAD", "BODY", "ARMS", "LEGS", "ACCESSORY_A", "ACCESSORY_B"]

	for slot in slots:
		var item_id: String = String(equip.get(slot, ""))
		if item_id.is_empty():
			var lbl := Label.new()
			lbl.text = "%s: [空]" % slot
			%EnhanceList.add_child(lbl)
			continue

		var item: ItemData = DataManager.get_item(item_id)
		var item_name := item.display_name if item != null else item_id
		var enhance_lv: int = int(enhancements.get(item_id, 0))

		var hbox := HBoxContainer.new()
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var lbl := Label.new()
		lbl.text = "%s: %s +%d" % [slot, item_name, enhance_lv]
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(lbl)

		if enhance_lv < GrowthService.MAX_ENHANCE_LEVEL:
			var cost := GrowthService.get_enhance_cost(enhance_lv)
			var btn := Button.new()
			btn.text = "强化 (合金:%d 电:%d)" % [cost["nano_alloy"], cost["bio_electricity"]]
			btn.disabled = PlayerData.nano_alloy < cost["nano_alloy"] or PlayerData.bio_electricity < cost["bio_electricity"]
			btn.pressed.connect(_on_enhance.bind(slot))
			hbox.add_child(btn)
		else:
			var lbl2 := Label.new()
			lbl2.text = "[满级]"
			hbox.add_child(lbl2)

		%EnhanceList.add_child(hbox)


func _refresh_tree_tab(char_data: CharacterData, runtime: Dictionary) -> void:
	for child in %TreeContent.get_children():
		child.queue_free()

	var tree: ProfessionTreeData = DataManager.get_skill_tree_for_profession(char_data.profession)
	if tree == null:
		var lbl := Label.new()
		lbl.text = "技能树配置缺失"
		%TreeContent.add_child(lbl)
		return

	var tree_unlocks: Array = runtime.get("tree_unlocks", [])
	var char_level: int = int(runtime.get("level", 1))

	# 检测已选分支
	var chosen_branch := ""  # "a" or "b" or ""
	for sid in tree_unlocks:
		if sid in tree.branch_a_skills:
			chosen_branch = "a"
			break
		elif sid in tree.branch_b_skills:
			chosen_branch = "b"
			break

	# 分支A
	var lbl_a := Label.new()
	lbl_a.text = "── %s ──" % tree.branch_a_name
	%TreeContent.add_child(lbl_a)
	_add_branch_nodes(tree.branch_a_skills, "a", chosen_branch, tree_unlocks, char_level)

	var sep := HSeparator.new()
	%TreeContent.add_child(sep)

	# 分支B
	var lbl_b := Label.new()
	lbl_b.text = "── %s ──" % tree.branch_b_name
	%TreeContent.add_child(lbl_b)
	_add_branch_nodes(tree.branch_b_skills, "b", chosen_branch, tree_unlocks, char_level)


func _add_branch_nodes(skills: Array[String], branch: String, chosen_branch: String, tree_unlocks: Array, char_level: int) -> void:
	for i in range(skills.size()):
		var skill_id: String = skills[i]
		var req_level: int = ProfessionTreeData.NODE_LEVELS[i]
		var skill: SkillData = DataManager.get_skill(skill_id)
		var skill_name := skill.display_name if skill != null else skill_id

		var hbox := HBoxContainer.new()
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var is_unlocked := skill_id in tree_unlocks
		var can_unlock := true
		if is_unlocked:
			can_unlock = false
		elif char_level < req_level:
			can_unlock = false
		elif not chosen_branch.is_empty() and chosen_branch != branch:
			can_unlock = false  # 分支互斥
		elif i > 0 and skills[i - 1] not in tree_unlocks:
			can_unlock = false  # 前序未解锁

		var lbl := Label.new()
		var status := "[已解锁]" if is_unlocked else ("[可解锁]" if can_unlock else "[锁定 Lv.%d]" % req_level)
		lbl.text = "Lv.%d %s %s" % [req_level, skill_name, status]
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(lbl)

		if can_unlock and not is_unlocked:
			var btn := Button.new()
			btn.text = "解锁"
			btn.pressed.connect(_on_unlock_skill.bind(skill_id))
			hbox.add_child(btn)

		%TreeContent.add_child(hbox)


func _on_enhance(slot: String) -> void:
	if PlayerData.enhance_equipment(_current_char_id, slot):
		_refresh()
		SaveManager.save_game(0)


func _on_star_upgrade() -> void:
	if PlayerData.star_upgrade(_current_char_id):
		_refresh()
		SaveManager.save_game(0)


func _on_unlock_skill(skill_id: String) -> void:
	if PlayerData.unlock_tree_skill(_current_char_id, skill_id):
		_refresh()
		SaveManager.save_game(0)


func _profession_name(profession: CharacterData.Profession) -> String:
	match profession:
		CharacterData.Profession.ASSAULT: return "突击手"
		CharacterData.Profession.SHIELD: return "盾卫"
		CharacterData.Profession.EXECUTIONER: return "处刑人"
		CharacterData.Profession.PLAGUE: return "瘟疫使者"
		CharacterData.Profession.PSION: return "脑波术士"
		CharacterData.Profession.BERSERKER: return "狂暴体"
		_: return "未知"
