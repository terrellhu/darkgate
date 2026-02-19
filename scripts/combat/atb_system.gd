## ATB 行动条系统
## 管理所有单位的充能与行动顺序
class_name ATBSystem
extends RefCounted

var _units: Array[BattleUnit] = []


func setup(units: Array[BattleUnit]) -> void:
	_units = units


## 每帧充能，返回本帧 ATB 已满的单位列表（按溢出量 -> 速度 -> 随机排序）
func tick(delta: float) -> Array[BattleUnit]:
	var ready: Array[BattleUnit] = []

	for unit in _units:
		if not unit.alive:
			continue
		if unit.is_stunned():
			continue
		unit.atb += float(unit.speed) * CombatConfig.ATB_SPEED_FACTOR * delta
		if unit.atb >= CombatConfig.ATB_MAX:
			ready.append(unit)

	if ready.size() > 1:
		ready.sort_custom(_sort_by_overflow)

	return ready


## 消耗行动条
func consume_action(unit: BattleUnit) -> void:
	unit.atb -= CombatConfig.ATB_MAX
	if unit.atb < 0.0:
		unit.atb = 0.0


## 重置所有 ATB
func reset() -> void:
	for unit in _units:
		unit.atb = 0.0


## 排序规则：溢出量大的优先 -> 速度快的优先 -> 随机
static func _sort_by_overflow(a: BattleUnit, b: BattleUnit) -> bool:
	var overflow_a := a.atb - CombatConfig.ATB_MAX
	var overflow_b := b.atb - CombatConfig.ATB_MAX
	if not is_equal_approx(overflow_a, overflow_b):
		return overflow_a > overflow_b
	if a.speed != b.speed:
		return a.speed > b.speed
	return randf() < 0.5
