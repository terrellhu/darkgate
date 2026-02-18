## 地图节点数据模板
## 定义探索地图中每个格子的属性
class_name MapNodeData
extends Resource

## 节点类型
enum NodeType {
	EMPTY,          ## 空地
	BATTLE,         ## 战斗
	EVENT,          ## 事件
	TREASURE,       ## 宝箱
	TERMINAL,       ## 数据终端（叙事碎片）
	SUPPLY,         ## 补给站
	BOSS,           ## BOSS
	ENTRANCE,       ## 入口
	EXIT,           ## 出口
}

@export var id: String = ""
@export var node_type: NodeType = NodeType.EMPTY
@export var grid_position: Vector2i = Vector2i.ZERO  ## 网格坐标

## 连接的相邻节点ID
@export var connected_nodes: Array[String] = []

## 是否已探索
@export var revealed: bool = false

## 关联数据
@export_group("关联数据")
@export var event_id: String = ""       ## 关联的事件ID
@export var enemy_group: Array[String] = []  ## 遭遇的敌人ID列表
@export var treasure_item_ids: Array[String] = []  ## 宝箱内容
@export var narrative_text_key: String = ""  ## 叙事文本键

## 消耗
@export_group("消耗")
@export var bio_electricity_cost: int = 1   ## 进入消耗的生物电
@export var san_drain: float = 1.0          ## 进入时SAN值下降量
