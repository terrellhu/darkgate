## 状态效果管理器
## 负责施加、查询、回合处理、清理
class_name StatusManager
extends RefCounted


## 尝试施加技能的所有效果，返回已施加效果的描述列表
static func try_apply_skill_effects(attacker: BattleUnit, defender: BattleUnit, skill: SkillData) -> Array[String]:
	var applied: Array[String] = []
	var duration := maxi(1, skill.dot_duration) if skill.dot_duration > 0 else 2

	if skill.stun_chance > 0.0 and _try_apply(attacker, defender, skill.stun_chance):
		defender.status_effects.append(
			StatusEffect.create_stun(attacker.unit_id, duration)
		)
		applied.append("眩晕")

	if skill.silence_chance > 0.0 and _try_apply(attacker, defender, skill.silence_chance):
		defender.status_effects.append(
			StatusEffect.create_silence(attacker.unit_id, duration)
		)
		applied.append("沉默")

	if skill.bleed_chance > 0.0 and _try_apply(attacker, defender, skill.bleed_chance):
		var dot_dur := maxi(1, skill.dot_duration) if skill.dot_duration > 0 else 2
		defender.status_effects.append(
			StatusEffect.create_bleed(attacker.unit_id, attacker.atk, skill.dot_damage, dot_dur)
		)
		applied.append("流血")

	if skill.taunt_chance > 0.0 and _try_apply(attacker, defender, skill.taunt_chance):
		defender.status_effects.append(
			StatusEffect.create_taunt(attacker.unit_id, attacker.unit_id, duration)
		)
		applied.append("嘲讽")

	return applied


## 回合结束处理：DoT 扣血、持续时间 -1、清除到期效果
## 返回事件列表 [{ "type": "dot_damage"/"status_expired", ... }]
static func process_turn_effects(unit: BattleUnit) -> Array[Dictionary]:
	var events: Array[Dictionary] = []
	var to_remove: Array[int] = []

	for i in range(unit.status_effects.size()):
		var e: StatusEffect = unit.status_effects[i]

		## DoT 伤害
		if e.type == StatusEffect.Type.BLEED and e.dot_damage > 0:
			var dot_dmg := CombatCalculator.calculate_dot_damage(e.source_atk, e.dot_damage, unit)
			unit.current_hp -= dot_dmg
			events.append({
				"type": "dot_damage",
				"target": unit.unit_id,
				"amount": dot_dmg,
				"status_name": "流血",
			})
			if unit.current_hp <= 0:
				unit.current_hp = 0
				unit.alive = false
				events.append({ "type": "kill", "target": unit.unit_id })

		## 持续时间 -1
		e.remaining_turns -= 1
		if e.remaining_turns <= 0:
			to_remove.append(i)
			events.append({
				"type": "status_expired",
				"target": unit.unit_id,
				"status_name": _type_name(e.type),
			})

	## 从后往前移除到期效果
	to_remove.reverse()
	for idx in to_remove:
		unit.status_effects.remove_at(idx)

	return events


## 清除单位所有状态效果
static func clear_all(unit: BattleUnit) -> void:
	unit.status_effects.clear()


## 内部：判定效果是否施加成功
static func _try_apply(attacker: BattleUnit, defender: BattleUnit, base_chance: float) -> bool:
	return CombatCalculator.should_apply_effect(base_chance, attacker, defender)


static func _type_name(type: StatusEffect.Type) -> String:
	match type:
		StatusEffect.Type.STUN:
			return "眩晕"
		StatusEffect.Type.SILENCE:
			return "沉默"
		StatusEffect.Type.BLEED:
			return "流血"
		StatusEffect.Type.TAUNT:
			return "嘲讽"
	return "未知"
