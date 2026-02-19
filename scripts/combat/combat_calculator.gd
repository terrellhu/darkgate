## 战斗公式计算器
## 所有计算为纯函数，无副作用，便于测试与调参
class_name CombatCalculator
extends RefCounted


## 命中判定：返回是否命中
static func roll_hit(attacker: BattleUnit, defender: BattleUnit, skill: SkillData, san: float) -> bool:
	var hit_penalty := 0.0
	if attacker.is_ally and san < CombatConfig.SAN_LOW_THRESHOLD:
		hit_penalty = CombatConfig.SAN_LOW_ALLY_HIT_PENALTY
	var hit_chance := clampf(
		CombatConfig.HIT_BASE_FACTOR * attacker.hit_rate + skill.accuracy_bonus - defender.dodge_rate - hit_penalty,
		CombatConfig.HIT_MIN,
		CombatConfig.HIT_MAX
	)
	return randf() < hit_chance


## 暴击判定：返回是否暴击
static func roll_crit(attacker: BattleUnit, link: float) -> bool:
	var link_bonus := get_link_crit_bonus(link) if attacker.is_ally else 0.0
	var crit_chance := clampf(
		attacker.crit_rate + link_bonus,
		CombatConfig.CRIT_MIN,
		CombatConfig.CRIT_MAX
	)
	return randf() < crit_chance


## 计算伤害
static func calculate_damage(attacker: BattleUnit, defender: BattleUnit, skill: SkillData,
		is_crit: bool, san: float, link: float) -> int:
	var raw := float(attacker.atk) * skill.damage_multiplier + float(skill.base_damage)
	var variance := randf_range(CombatConfig.DAMAGE_VARIANCE_MIN, CombatConfig.DAMAGE_VARIANCE_MAX)

	var penetrated_def := float(defender.def_stat) * (1.0 - attacker.armor_pen) * (1.0 - skill.ignore_def_ratio)
	var def_factor := 100.0 / (100.0 + maxf(0.0, penetrated_def))

	var crit_mul := attacker.crit_damage if is_crit else 1.0

	var san_factor := get_san_attack_factor(san, not attacker.is_ally)
	var link_factor := 1.0
	if not defender.is_ally:
		link_factor = 1.0  ## 玩家打敌人不受 link 减伤影响
	else:
		link_factor = get_link_damage_taken_factor(link)

	var damage := int(floor(raw * def_factor * crit_mul * variance * san_factor))
	## 精神链接低下时受到的伤害加成（仅作用于友方受击）
	if not attacker.is_ally and link_factor > 1.0:
		damage = int(floor(float(damage) * link_factor))
	return maxi(CombatConfig.MIN_DAMAGE, damage)


## 计算治疗量
static func calculate_heal(caster: BattleUnit, skill: SkillData) -> int:
	var raw := float(caster.atk) * skill.heal_multiplier + float(skill.base_damage)
	var variance := randf_range(CombatConfig.HEAL_VARIANCE_MIN, CombatConfig.HEAL_VARIANCE_MAX)
	var heal := int(floor(raw * (1.0 + caster.heal_power) * variance))
	return maxi(1, heal)


## 计算护盾值
static func calculate_shield(caster: BattleUnit, skill: SkillData) -> int:
	var raw := float(caster.atk) * skill.shield_multiplier + float(skill.base_damage)
	var shield := int(floor(raw * (1.0 + caster.heal_power)))
	return maxi(1, shield)


## 状态效果施加判定
static func should_apply_effect(base_chance: float, attacker: BattleUnit, defender: BattleUnit) -> bool:
	if base_chance <= 0.0:
		return false
	var apply_chance := clampf(
		base_chance + attacker.effect_hit - defender.effect_resist,
		CombatConfig.EFFECT_APPLY_MIN,
		CombatConfig.EFFECT_APPLY_MAX
	)
	return randf() < apply_chance


## 计算 DoT 伤害
static func calculate_dot_damage(source_atk: int, dot_flat: int, _target: BattleUnit) -> int:
	## MVP: 使用固定值 + 来源攻击力的小比例
	var damage := dot_flat + int(floor(float(source_atk) * 0.1))
	return maxi(CombatConfig.MIN_DAMAGE, damage)


## SAN 对攻击方的影响因子
static func get_san_attack_factor(san: float, is_enemy: bool) -> float:
	if san >= CombatConfig.SAN_LOW_THRESHOLD:
		return 1.0
	if is_enemy:
		return 1.0 + CombatConfig.SAN_LOW_ENEMY_ATK_BONUS
	return 1.0  ## 友方攻击力不受 SAN 惩罚（命中惩罚在 roll_hit 中处理）


## 精神链接暴击加成
static func get_link_crit_bonus(link: float) -> float:
	if link >= CombatConfig.LINK_HIGH_THRESHOLD:
		return CombatConfig.LINK_HIGH_CRIT_BONUS
	return 0.0


## 精神链接受伤加成（>1.0 表示多受伤害）
static func get_link_damage_taken_factor(link: float) -> float:
	if link < CombatConfig.LINK_LOW_THRESHOLD:
		return 1.0 + CombatConfig.LINK_LOW_DAMAGE_TAKEN_BONUS
	return 1.0


## 掉落倍率计算
static func calculate_drop_multiplier(gate: int, min_san: float) -> float:
	var gate_mul := 1.0 + maxf(0, gate - 1) * CombatConfig.DROP_MULTIPLIER_PER_GATE
	var risk_bonus := 1.0
	if min_san < CombatConfig.DROP_SAN_LOW_THRESHOLD:
		risk_bonus += CombatConfig.DROP_SAN_LOW_BONUS
	if min_san < CombatConfig.DROP_SAN_CRITICAL_THRESHOLD:
		risk_bonus += CombatConfig.DROP_SAN_CRITICAL_BONUS
	return gate_mul * risk_bonus
