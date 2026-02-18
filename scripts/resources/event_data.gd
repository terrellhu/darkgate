## 探索事件数据模板
## 定义在探索中遇到的文字事件
class_name EventData
extends Resource

## 事件类型
enum EventType {
	NARRATIVE,      ## 纯叙事（只有文本）
	CHOICE,         ## 选择事件（有分支选项）
	CHECK,          ## 检定事件（基于属性判定）
	TRAP,           ## 陷阱（强制触发负面效果）
	REWARD,         ## 奖励事件
}

@export var id: String = ""
@export var event_type: EventType = EventType.NARRATIVE
@export_multiline var description: String = ""  ## 事件描述文本

## 选项列表（CHOICE类型使用）
## 每个选项是一个字典: { "text": String, "result_id": String, "condition": String }
@export var choices: Array[Dictionary] = []

## 检定属性（CHECK类型使用）
@export_group("检定")
@export var check_attribute: String = ""  ## 检定的属性名
@export var check_threshold: int = 0     ## 检定阈值
@export var success_result_id: String = ""
@export var failure_result_id: String = ""

## 效果
@export_group("效果")
@export var san_change: float = 0.0
@export var bio_electricity_change: int = 0
@export var item_rewards: Array[String] = []
@export var trigger_combat: bool = false
@export var combat_enemy_ids: Array[String] = []

## SAN值依赖文本
## 低SAN值时显示不同的事件描述
@export_group("理智影响")
@export_multiline var low_san_description: String = ""  ## SAN<40时的描述
@export_multiline var critical_san_description: String = ""  ## SAN<10时的描述
