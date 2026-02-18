## 地图生成器
## 根据黑门编号生成探索地图节点
class_name MapGenerator
extends RefCounted

const COLUMNS := 5
const ROWS := 6

## 中间行节点类型的权重分布
const NODE_WEIGHTS := {
	MapNodeData.NodeType.EMPTY: 40,
	MapNodeData.NodeType.BATTLE: 25,
	MapNodeData.NodeType.EVENT: 15,
	MapNodeData.NodeType.TREASURE: 10,
	MapNodeData.NodeType.TERMINAL: 5,
	MapNodeData.NodeType.SUPPLY: 5,
}


## 生成指定黑门的地图节点数组
static func generate(gate: int) -> Array[MapNodeData]:
	var nodes: Array[MapNodeData] = []
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(gate * 1000 + randi())

	# 构建权重池
	var weight_pool: Array[int] = []
	for type: int in NODE_WEIGHTS:
		for i in NODE_WEIGHTS[type]:
			weight_pool.append(type)

	# 生成所有节点
	for row in ROWS:
		for col in COLUMNS:
			var node := MapNodeData.new()
			node.id = "node_%d_%d" % [row, col]
			node.grid_position = Vector2i(col, row)

			# 确定节点类型
			if row == 0:
				node.node_type = MapNodeData.NodeType.ENTRANCE
			elif row == ROWS - 1:
				if col == COLUMNS / 2:
					node.node_type = MapNodeData.NodeType.BOSS
				else:
					node.node_type = MapNodeData.NodeType.EMPTY
			else:
				var random_index := rng.randi_range(0, weight_pool.size() - 1)
				node.node_type = weight_pool[random_index] as MapNodeData.NodeType

			# 确保第1行（入口后）至少有一个战斗节点
			if row == 1 and col == COLUMNS - 1:
				var has_battle := false
				for prev_node in nodes:
					if prev_node.grid_position.y == 1 and prev_node.node_type == MapNodeData.NodeType.BATTLE:
						has_battle = true
						break
				if not has_battle:
					node.node_type = MapNodeData.NodeType.BATTLE

			# 设置消耗（随黑门编号递增）
			node.bio_electricity_cost = 1 + gate / 3
			node.san_drain = 1.0 + gate * 0.5

			# 建立连接关系（上下左右相邻）
			var connections: Array[String] = []
			if row > 0:
				connections.append("node_%d_%d" % [row - 1, col])
			if row < ROWS - 1:
				connections.append("node_%d_%d" % [row + 1, col])
			if col > 0:
				connections.append("node_%d_%d" % [row, col - 1])
			if col < COLUMNS - 1:
				connections.append("node_%d_%d" % [row, col + 1])
			node.connected_nodes = connections

			nodes.append(node)

	return nodes
