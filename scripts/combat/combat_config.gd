## 战斗系统全局数值常量
## 所有可调参数集中于此，便于平衡性调整
class_name CombatConfig
extends RefCounted

## ========== ATB ==========
const ATB_MAX := 1000.0
const ATB_SPEED_FACTOR := 100.0

## ========== 伤害方差 ==========
const DAMAGE_VARIANCE_MIN := 0.95
const DAMAGE_VARIANCE_MAX := 1.05
const HEAL_VARIANCE_MIN := 0.97
const HEAL_VARIANCE_MAX := 1.03

## ========== 命中 / 暴击 ==========
const HIT_BASE_FACTOR := 0.90
const HIT_MIN := 0.10
const HIT_MAX := 0.99
const CRIT_MIN := 0.0
const CRIT_MAX := 0.75

## ========== 状态效果 ==========
const EFFECT_APPLY_MIN := 0.05
const EFFECT_APPLY_MAX := 0.95

## ========== 异化 / 失控 ==========
const LOST_CONTROL_ATK_BONUS := 0.35
const LOST_CONTROL_SPD_BONUS := 0.20
const LOST_CONTROL_DEF_PENALTY := 0.25
const SOOTHE_REGAIN_THRESHOLD := 0.60
const POST_COMBAT_ABERRATION_DECAY := 0.35

## ========== SAN 影响（两档 MVP） ==========
const SAN_LOW_THRESHOLD := 40.0
const SAN_LOW_ENEMY_ATK_BONUS := 0.15
const SAN_LOW_ALLY_HIT_PENALTY := 0.10

## ========== 精神链接 ==========
const LINK_HIGH_THRESHOLD := 80.0
const LINK_HIGH_CRIT_BONUS := 0.05
const LINK_LOW_THRESHOLD := 20.0
const LINK_LOW_DAMAGE_TAKEN_BONUS := 0.15

## ========== 敌人黑门缩放 ==========
const ENEMY_HP_SCALE_PER_GATE := 0.18
const ENEMY_ATK_SCALE_PER_GATE := 0.12
const ENEMY_DEF_SCALE_PER_GATE := 0.10
const ENEMY_SPEED_SCALE_PER_GATE := 0.06

## ========== 掉落 ==========
const DROP_MULTIPLIER_PER_GATE := 0.08
const DROP_SAN_LOW_BONUS := 0.10
const DROP_SAN_CRITICAL_BONUS := 0.15
const DROP_SAN_LOW_THRESHOLD := 40.0
const DROP_SAN_CRITICAL_THRESHOLD := 10.0

## ========== 精神链接衰减（探索用） ==========
const LINK_DECAY_BASE := 2.0
const LINK_DECAY_PER_GATE := 0.3
const LINK_VISION_REDUCED_THRESHOLD := 50.0
const LINK_VISION_REDUCED_CHANCE := 0.5

## ========== 通用 ==========
const MIN_DAMAGE := 1
const MIN_SPEED := 1
