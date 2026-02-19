## 运行时状态效果实例
## 挂载在 BattleUnit.status_effects 数组中
class_name StatusEffect
extends RefCounted

enum Type { STUN, SILENCE, BLEED, TAUNT }

var type: Type
var remaining_turns: int = 1
var source_unit_id: String = ""  ## 施加者 unit_id（用于 DoT 来源追踪）
var source_atk: int = 0         ## 施加时快照的攻击力
var dot_damage: int = 0         ## 每回合固定伤害
var taunt_target_id: String = ""  ## TAUNT 时强制攻击的目标 unit_id


static func create_stun(source_id: String, duration: int) -> StatusEffect:
	var e := StatusEffect.new()
	e.type = Type.STUN
	e.source_unit_id = source_id
	e.remaining_turns = maxi(1, duration)
	return e


static func create_silence(source_id: String, duration: int) -> StatusEffect:
	var e := StatusEffect.new()
	e.type = Type.SILENCE
	e.source_unit_id = source_id
	e.remaining_turns = maxi(1, duration)
	return e


static func create_bleed(source_id: String, atk: int, dot_dmg: int, duration: int) -> StatusEffect:
	var e := StatusEffect.new()
	e.type = Type.BLEED
	e.source_unit_id = source_id
	e.source_atk = atk
	e.dot_damage = dot_dmg
	e.remaining_turns = maxi(1, duration)
	return e


static func create_taunt(source_id: String, target_id: String, duration: int) -> StatusEffect:
	var e := StatusEffect.new()
	e.type = Type.TAUNT
	e.source_unit_id = source_id
	e.taunt_target_id = target_id
	e.remaining_turns = maxi(1, duration)
	return e
