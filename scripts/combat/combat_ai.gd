## Gambit 风格战斗 AI
## 为自动模式友方和所有敌方选择技能与目标
class_name CombatAI
extends RefCounted


## 返回 { "skill": SkillData, "targets": Array[BattleUnit] }
static func choose_action(unit: BattleUnit, allies: Array[BattleUnit], enemies: Array[BattleUnit]) -> Dictionary:
	var my_allies := allies if unit.is_ally else enemies
	var my_enemies := enemies if unit.is_ally else allies
	var all_units: Array[BattleUnit] = []
	all_units.append_array(allies)
	all_units.append_array(enemies)

	## ── 失控：随机目标 + 普攻 ──
	if unit.lost_control:
		var basic := _get_basic_attack(unit)
		var alive_all := _get_alive(all_units)
		if alive_all.is_empty():
			return { "skill": basic, "targets": [] }
		var target: BattleUnit = alive_all[randi() % alive_all.size()]
		return { "skill": basic, "targets": [target] }

	## ── 被嘲讽：攻击嘲讽源 ──
	var taunt_id := unit.get_taunt_target()
	if not taunt_id.is_empty():
		var taunt_target := _find_unit(all_units, taunt_id)
		if taunt_target != null and taunt_target.alive:
			return { "skill": _get_basic_attack(unit), "targets": [taunt_target] }

	## ── 正常 AI：按优先级选技能 ──
	var silenced := unit.is_silenced()
	var sorted_skills := unit.skills.duplicate()
	sorted_skills.sort_custom(func(a: SkillData, b: SkillData) -> bool: return a.priority > b.priority)

	for skill: SkillData in sorted_skills:
		## 冷却检查
		if int(unit.cooldowns.get(skill.id, 0)) > 0:
			continue
		## 沉默时只能用普攻（cooldown == 0 且 PHYSICAL 的基础攻击）
		if silenced and (skill.cooldown > 0 or skill.skill_type != SkillData.SkillType.PHYSICAL):
			continue
		## 治疗技能：队友有人低于 50% 才使用
		if skill.skill_type == SkillData.SkillType.HEAL:
			if not _has_low_hp_ally(my_allies, 0.5):
				continue
		## 选择目标
		var targets := _select_targets(skill, unit, my_allies, my_enemies)
		if targets.is_empty():
			continue
		return { "skill": skill, "targets": targets }

	## 兜底：普攻
	var basic := _get_basic_attack(unit)
	var fallback_targets := _select_targets(basic, unit, my_allies, my_enemies)
	return { "skill": basic, "targets": fallback_targets }


## 根据技能目标类型选择目标
static func _select_targets(skill: SkillData, _caster: BattleUnit,
		my_allies: Array[BattleUnit], my_enemies: Array[BattleUnit]) -> Array[BattleUnit]:
	var targets: Array[BattleUnit] = []
	match skill.target_type:
		SkillData.TargetType.SINGLE_ENEMY:
			var alive := _get_alive(my_enemies)
			if alive.is_empty():
				return targets
			alive.sort_custom(func(a: BattleUnit, b: BattleUnit) -> bool: return a.current_hp < b.current_hp)
			targets.append(alive[0])
		SkillData.TargetType.ALL_ENEMIES:
			targets.append_array(_get_alive(my_enemies))
		SkillData.TargetType.SINGLE_ALLY:
			var alive := _get_alive(my_allies)
			if alive.is_empty():
				return targets
			alive.sort_custom(func(a: BattleUnit, b: BattleUnit) -> bool:
				return float(a.current_hp) / float(a.max_hp) < float(b.current_hp) / float(b.max_hp))
			targets.append(alive[0])
		SkillData.TargetType.ALL_ALLIES:
			targets.append_array(_get_alive(my_allies))
		SkillData.TargetType.SELF:
			targets.append(_caster)
	return targets


static func _get_alive(units: Array[BattleUnit]) -> Array[BattleUnit]:
	var alive: Array[BattleUnit] = []
	for u in units:
		if u.alive:
			alive.append(u)
	return alive


static func _has_low_hp_ally(allies: Array[BattleUnit], threshold: float) -> bool:
	for u in allies:
		if u.alive and float(u.current_hp) / float(u.max_hp) < threshold:
			return true
	return false


static func _get_basic_attack(unit: BattleUnit) -> SkillData:
	for skill in unit.skills:
		if skill.id == "skill_common_attack":
			return skill
	## 如果没有 skill_common_attack，取第一个可用技能
	if not unit.skills.is_empty():
		return unit.skills[0]
	## 兜底：从 DataManager 获取
	var fallback: SkillData = DataManager.get_skill("skill_common_attack")
	return fallback


static func _find_unit(units: Array[BattleUnit], unit_id: String) -> BattleUnit:
	for u in units:
		if u.unit_id == unit_id:
			return u
	return null
