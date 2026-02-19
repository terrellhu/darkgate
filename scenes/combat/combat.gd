## 战斗场景
## 整合 ATB 循环、行动执行、状态管理、结算奖励
extends Control

## 战斗状态
enum CombatState {
	PREPARING,  ## 准备阶段
	RUNNING,    ## 战斗进行中（自动）
	PAUSED,     ## 玩家手动干预（预留）
	VICTORY,    ## 胜利
	DEFEAT,     ## 失败
}

## ========== 运行时状态 ==========
var _state: CombatState = CombatState.PREPARING
var _allies: Array[BattleUnit] = []
var _enemies: Array[BattleUnit] = []
var _all_units: Array[BattleUnit] = []
var _atb_system: ATBSystem = null
var _min_san: float = 100.0
var _is_auto: bool = true
var _battle_ended: bool = false

## ========== 单位 UI 节点映射 ==========
var _unit_labels: Dictionary = {}  ## { unit_id: Label }


func _ready() -> void:
	%BtnAuto.pressed.connect(_on_toggle_auto)
	%BtnRetreat.pressed.connect(_on_retreat)
	setup_combat(GameManager.consume_pending_combat_enemy_ids())


## ========== 初始化 ==========

func setup_combat(enemy_ids: Array[String]) -> void:
	_state = CombatState.PREPARING
	_battle_ended = false
	_allies.clear()
	_enemies.clear()
	_all_units.clear()
	_unit_labels.clear()
	_min_san = PlayerData.current_san
	_clear_unit_views()

	_log("遭遇敌人！")

	## 构建友方
	for char_id in PlayerData.team:
		var unit := BattleUnit.from_ally(char_id)
		if unit == null:
			continue
		_allies.append(unit)

	## 构建敌方
	for i in range(enemy_ids.size()):
		var eid: String = enemy_ids[i]
		var unit := BattleUnit.from_enemy(eid, PlayerData.current_gate, i)
		if unit == null:
			_log("[警告] 敌人配置缺失: %s" % eid)
			continue
		_enemies.append(unit)

	## 合并
	_all_units.append_array(_allies)
	_all_units.append_array(_enemies)

	## 初始化 ATB
	_atb_system = ATBSystem.new()
	_atb_system.setup(_all_units)

	## 创建 UI
	_create_unit_views()

	## 日志：队伍与敌人信息
	for u in _allies:
		_log("%s  HP:%d ATK:%d DEF:%d SPD:%d" % [u.display_name, u.max_hp, u.atk, u.def_stat, u.speed])
	for u in _enemies:
		_log("%s  HP:%d ATK:%d DEF:%d SPD:%d" % [u.display_name, u.max_hp, u.atk, u.def_stat, u.speed])

	if _allies.is_empty():
		_log("无可用队员，战斗失败。")
		_end_combat("defeat")
		return
	if _enemies.is_empty():
		_log("无敌人，战斗胜利。")
		_end_combat("victory")
		return

	_state = CombatState.RUNNING
	EventBus.combat_started.emit(enemy_ids)


## ========== 主循环 ==========

func _process(delta: float) -> void:
	if _state != CombatState.RUNNING:
		return

	_min_san = minf(_min_san, PlayerData.current_san)

	var ready_units := _atb_system.tick(delta)
	for unit in ready_units:
		if _battle_ended:
			return
		if not unit.alive:
			continue
		_process_unit_turn(unit)
		if _check_battle_end():
			return


## ========== 单位回合处理 ==========

func _process_unit_turn(unit: BattleUnit) -> void:
	## 1. 状态效果 tick（DoT 等）
	var status_events := StatusManager.process_turn_effects(unit)
	_log_events(status_events)
	_refresh_unit_view(unit)

	## DoT 致死检查
	if not unit.alive:
		_log("%s 因状态效果死亡！" % unit.display_name)
		_atb_system.consume_action(unit)
		return

	## 2. 冷却 -1
	for skill_id in unit.cooldowns.keys():
		if int(unit.cooldowns[skill_id]) > 0:
			unit.cooldowns[skill_id] = int(unit.cooldowns[skill_id]) - 1

	## 3. 眩晕跳过
	if unit.is_stunned():
		_log("%s 处于眩晕状态，无法行动。" % unit.display_name)
		_atb_system.consume_action(unit)
		return

	## 4. 选择行动（AI 自动）
	var action := CombatAI.choose_action(unit, _allies, _enemies)
	var skill: SkillData = action["skill"]
	var targets: Array[BattleUnit] = []
	for t in action["targets"]:
		targets.append(t as BattleUnit)

	## 5. 日志输出行动意图
	var target_names: Array[String] = []
	for t in targets:
		target_names.append(t.display_name)
	_log("%s 使用 [%s] → %s" % [unit.display_name, skill.display_name, ", ".join(target_names)])

	## 6. 执行行动
	var events := ActionResolver.resolve_action(
		unit, skill, targets, PlayerData.current_san, PlayerData.current_mental_link
	)
	_log_events(events)

	## 7. 消耗 ATB
	_atb_system.consume_action(unit)

	## 8. 刷新所有受影响单位的 UI
	_refresh_all_views()


## ========== 胜负检查 ==========

func _check_battle_end() -> bool:
	var enemies_alive := false
	for u in _enemies:
		if u.alive:
			enemies_alive = true
			break

	if not enemies_alive:
		_end_combat("victory")
		return true

	var allies_alive := false
	for u in _allies:
		if u.alive:
			allies_alive = true
			break

	if not allies_alive:
		_end_combat("defeat")
		return true

	return false


## ========== 战斗结束 ==========

func _end_combat(result: String) -> void:
	_battle_ended = true

	match result:
		"victory":
			_state = CombatState.VICTORY
			_log("")
			_log("═══ 战斗胜利！ ═══")
			_award_drops()
		"defeat":
			_state = CombatState.DEFEAT
			_log("")
			_log("═══ 队伍全灭... ═══")

	## 异化值衰减 & HP 回写
	_writeback_ally_state()

	EventBus.combat_ended.emit(result)
	GameManager.last_combat_result = result

	## 延时返回
	var timer := get_tree().create_timer(2.0)
	timer.timeout.connect(func() -> void:
		if result == "victory":
			GameManager.change_state(GameManager.GameState.EXPEDITION)
		else:
			PlayerData.clear_expedition_map_state()
			GameManager.change_state(GameManager.GameState.HUB)
	)


## 计算并发放掉落
func _award_drops() -> void:
	var drop_mul := CombatCalculator.calculate_drop_multiplier(PlayerData.current_gate, _min_san)
	var total_bio := 0
	var total_nano := 0
	var total_hash := 0

	for u in _enemies:
		total_bio += int(floor(float(u.drop_bio_electricity) * drop_mul))
		total_nano += int(floor(float(u.drop_nano_alloy) * drop_mul))
		total_hash += int(floor(float(u.drop_hashrate) * drop_mul))

		## 物品掉落
		for i in range(u.drop_item_ids.size()):
			if i < u.drop_item_rates.size() and randf() < u.drop_item_rates[i]:
				PlayerData.add_item_to_inventory(u.drop_item_ids[i], 1)
				var item: ItemData = DataManager.get_item(u.drop_item_ids[i])
				var item_name := item.display_name if item != null else u.drop_item_ids[i]
				_log("  获得物品: %s" % item_name)

	if total_bio > 0:
		PlayerData.modify_resource("bio_electricity", total_bio)
	if total_nano > 0:
		PlayerData.modify_resource("nano_alloy", total_nano)
	if total_hash > 0:
		PlayerData.modify_resource("hashrate", total_hash)

	_log("  获得: 生物电 +%d | 纳米合金 +%d | 算力 +%d" % [total_bio, total_nano, total_hash])


## 回写友方状态到 PlayerData
func _writeback_ally_state() -> void:
	for unit in _allies:
		## HP 回写（死亡角色设为 1 以便后续复活机制处理）
		var final_hp := unit.current_hp if unit.alive else 1
		PlayerData.set_character_hp(unit.source_id, final_hp)

		## 异化值衰减
		if unit.max_aberration > 0.0:
			var persist := int(floor(unit.current_aberration * CombatConfig.POST_COMBAT_ABERRATION_DECAY))
			PlayerData.set_character_aberration(unit.source_id, float(persist))


## ========== UI 控制 ==========

func _on_toggle_auto() -> void:
	if _state == CombatState.PAUSED:
		_state = CombatState.RUNNING
		%BtnAuto.text = "手动"
	elif _state == CombatState.RUNNING:
		_state = CombatState.PAUSED
		%BtnAuto.text = "自动"


func _on_retreat() -> void:
	if _battle_ended:
		return
	_log("队伍选择撤退...")
	_writeback_ally_state()
	GameManager.change_state(GameManager.GameState.EXPEDITION)


## ========== 日志 ==========

func _log(text: String) -> void:
	%BattleLog.append_text(text + "\n")


func _log_events(events: Array[Dictionary]) -> void:
	for ev in events:
		var t: String = ev.get("type", "")
		match t:
			"damage":
				var crit_mark := " [暴击!]" if ev.get("is_crit", false) else ""
				var shield_info := ""
				if int(ev.get("shield_absorbed", 0)) > 0:
					shield_info = " (护盾吸收%d)" % int(ev["shield_absorbed"])
				_log("  %s 受到 %d 伤害%s%s" % [
					_get_unit_name(ev["target"]),
					int(ev["amount"]),
					shield_info,
					crit_mark])
			"heal":
				_log("  %s 恢复 %d HP" % [_get_unit_name(ev["target"]), int(ev["amount"])])
			"shield":
				_log("  %s 获得 %d 护盾" % [_get_unit_name(ev["target"]), int(ev["amount"])])
			"miss":
				_log("  %s 闪避了攻击！" % _get_unit_name(ev["target"]))
			"kill":
				_log("  %s 被击败！" % _get_unit_name(ev["target"]))
			"status_applied":
				_log("  %s 被施加了 [%s]" % [_get_unit_name(ev["target"]), ev["status_name"]])
			"status_expired":
				_log("  %s 的 [%s] 效果消失" % [_get_unit_name(ev["target"]), ev["status_name"]])
			"dot_damage":
				_log("  %s 受到 [%s] 伤害 %d" % [
					_get_unit_name(ev["target"]),
					ev.get("status_name", "DoT"),
					int(ev["amount"])])
			"aberration_gain":
				_log("  %s 异化值 +%.0f (当前 %.0f)" % [
					_get_unit_name(ev["target"]),
					float(ev["amount"]),
					float(ev["new_value"])])
			"lost_control":
				_log("  !! %s 失控了！攻击力暴增，但无法分辨敌我！" % _get_unit_name(ev["target"]))


func _get_unit_name(unit_id: String) -> String:
	for u in _all_units:
		if u.unit_id == unit_id:
			return u.display_name
	return unit_id


## ========== 单位视图 ==========

func _create_unit_views() -> void:
	for unit in _allies:
		var label := _create_unit_label(unit)
		%AllyList.add_child(label)
		_unit_labels[unit.unit_id] = label
	for unit in _enemies:
		var label := _create_unit_label(unit)
		%EnemyList.add_child(label)
		_unit_labels[unit.unit_id] = label


func _create_unit_label(unit: BattleUnit) -> Label:
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_update_unit_label(label, unit)
	return label


func _update_unit_label(label: Label, unit: BattleUnit) -> void:
	var status_icons := ""
	if unit.is_stunned():
		status_icons += "[晕]"
	if unit.is_silenced():
		status_icons += "[默]"
	for e in unit.status_effects:
		if e.type == StatusEffect.Type.BLEED:
			status_icons += "[血]"
			break
	if unit.lost_control:
		status_icons += "[狂]"

	var hp_text := "HP:%d/%d" % [unit.current_hp, unit.max_hp]
	if not unit.alive:
		hp_text = "已倒下"
	var atb_pct := int(unit.atb / CombatConfig.ATB_MAX * 100.0)
	var ab_text := ""
	if unit.is_ally and unit.max_aberration > 0.0:
		ab_text = "\nAB:%.0f/%.0f" % [unit.current_aberration, unit.max_aberration]

	label.text = "%s%s\n%s | ATB:%d%%%s" % [
		unit.display_name,
		" " + status_icons if not status_icons.is_empty() else "",
		hp_text,
		atb_pct,
		ab_text,
	]


func _refresh_unit_view(unit: BattleUnit) -> void:
	if _unit_labels.has(unit.unit_id):
		_update_unit_label(_unit_labels[unit.unit_id], unit)


func _refresh_all_views() -> void:
	for unit in _all_units:
		_refresh_unit_view(unit)


func _clear_unit_views() -> void:
	for child in %AllyList.get_children():
		child.queue_free()
	for child in %EnemyList.get_children():
		child.queue_free()
	%BattleLog.clear()
