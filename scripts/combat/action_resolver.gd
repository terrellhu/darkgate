## 行动执行器
## 解析技能 -> 对目标施加效果 -> 返回结构化事件
class_name ActionResolver
extends RefCounted


## 执行一次行动，返回事件列表
static func resolve_action(attacker: BattleUnit, skill: SkillData,
		targets: Array[BattleUnit], san: float, link: float) -> Array[Dictionary]:
	var events: Array[Dictionary] = []

	## ── 设置冷却 ──
	if skill.cooldown > 0:
		attacker.cooldowns[skill.id] = skill.cooldown

	## ── 异化积累（友方异格者专用） ──
	if attacker.is_ally and attacker.max_aberration > 0.0 and attacker.aberration_per_skill > 0.0:
		## 普攻不累积异化
		if skill.id != "skill_common_attack":
			var ab_gain := attacker.aberration_per_skill
			attacker.current_aberration = minf(
				attacker.current_aberration + ab_gain,
				attacker.max_aberration
			)
			events.append({
				"type": "aberration_gain",
				"target": attacker.unit_id,
				"amount": ab_gain,
				"new_value": attacker.current_aberration,
			})
			## 失控判定
			if attacker.current_aberration >= attacker.max_aberration and not attacker.lost_control:
				attacker.enter_lost_control()
				events.append({
					"type": "lost_control",
					"target": attacker.unit_id,
				})

	## ── 对每个目标执行 ──
	for target in targets:
		if not target.alive:
			continue
		var target_events := _resolve_on_target(attacker, skill, target, san, link)
		events.append_array(target_events)

	return events


static func _resolve_on_target(attacker: BattleUnit, skill: SkillData,
		target: BattleUnit, san: float, link: float) -> Array[Dictionary]:
	var events: Array[Dictionary] = []

	## ── 治疗类 ──
	if skill.skill_type == SkillData.SkillType.HEAL:
		var heal := CombatCalculator.calculate_heal(attacker, skill)
		var old_hp := target.current_hp
		target.current_hp = mini(target.current_hp + heal, target.max_hp)
		var actual_heal := target.current_hp - old_hp
		events.append({
			"type": "heal",
			"source": attacker.unit_id,
			"target": target.unit_id,
			"amount": actual_heal,
		})
		return events

	## ── BUFF / 护盾类 ──
	if skill.skill_type == SkillData.SkillType.BUFF:
		if skill.shield_multiplier > 0.0:
			var shield := CombatCalculator.calculate_shield(attacker, skill)
			target.shield_hp += shield
			events.append({
				"type": "shield",
				"source": attacker.unit_id,
				"target": target.unit_id,
				"amount": shield,
			})
		## BUFF 类技能也可附带嘲讽等效果
		_try_apply_effects(attacker, target, skill, events)
		return events

	## ── 伤害类（PHYSICAL / ABERRATION / DEBUFF / CONTROL） ──
	## 命中判定
	var hit := CombatCalculator.roll_hit(attacker, target, skill, san)
	if not hit:
		events.append({
			"type": "miss",
			"source": attacker.unit_id,
			"target": target.unit_id,
		})
		return events

	## 暴击判定
	var is_crit := CombatCalculator.roll_crit(attacker, link)

	## 伤害计算
	var damage := CombatCalculator.calculate_damage(attacker, target, skill, is_crit, san, link)

	## 护盾吸收
	var shield_absorbed := 0
	if target.shield_hp > 0:
		shield_absorbed = mini(damage, target.shield_hp)
		target.shield_hp -= shield_absorbed
		damage -= shield_absorbed

	## 扣血
	target.current_hp -= damage
	events.append({
		"type": "damage",
		"source": attacker.unit_id,
		"target": target.unit_id,
		"amount": damage,
		"shield_absorbed": shield_absorbed,
		"is_crit": is_crit,
	})

	## 死亡判定
	if target.current_hp <= 0:
		target.current_hp = 0
		target.alive = false
		events.append({ "type": "kill", "target": target.unit_id })
		return events  ## 死亡后不再施加状态

	## 状态效果施加
	_try_apply_effects(attacker, target, skill, events)

	return events


static func _try_apply_effects(attacker: BattleUnit, target: BattleUnit,
		skill: SkillData, events: Array[Dictionary]) -> void:
	var applied := StatusManager.try_apply_skill_effects(attacker, target, skill)
	for name in applied:
		events.append({
			"type": "status_applied",
			"source": attacker.unit_id,
			"target": target.unit_id,
			"status_name": name,
		})
