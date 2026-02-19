## 地图生成器
## 根据黑门编号生成探索地图节点
class_name MapGenerator
extends RefCounted

const CELL_SIZE := 36  ## 格子边长（像素）
const CELL_GAP := 2   ## 格子间距（像素）

## 中间行节点类型的权重分布
const NODE_WEIGHTS := {
	MapNodeData.NodeType.EMPTY: 40,
	MapNodeData.NodeType.BATTLE: 25,
	MapNodeData.NodeType.EVENT: 15,
	MapNodeData.NodeType.TREASURE: 10,
	MapNodeData.NodeType.TERMINAL: 5,
	MapNodeData.NodeType.SUPPLY: 5,
}

## ========== 每黑门敌人配置 ==========
## 格式：{ gate: { "normal": [...], "elite": [...], "boss": [...] } }
## normal: 6种普通小怪   elite: 3种精英怪   boss: BOSS编组
const GATE_ENEMIES := {
	1: {
		"normal": [
			"enemy_abomination_01",    ## 初级孽体 - 基础肉搏
			"enemy_abomination_02",    ## 腐烂孽体 - 带流血撕咬
			"enemy_mutant_beast_01",   ## 变异噬齿兽 - 高速攻击
			"enemy_mutant_beast_02",   ## 变异蛛蝎 - 毒液DoT
			"enemy_mech_abom_01",      ## 废铁傀儡 - 高甲眩晕
			"enemy_mech_abom_02",      ## 破损哨卫 - 干扰嚎叫
		],
		"elite": [
			"enemy_elite_brute_01",    ## 肥大畸变体 - 高血眩晕
			"enemy_elite_stalker_01",  ## 暗影潜行者 - 高速流血
			"enemy_elite_spitter_01",  ## 腐液喷射者 - DoT+沉默
		],
		"boss": ["enemy_boss_gate1"],  ## 深渊吞噬者
	},
	2: {
		"normal": [
			"enemy_mech_abom_01",      ## 废铁傀儡 - 高甲眩晕
			"enemy_mech_abom_02",      ## 破损哨卫 - 干扰嚎叫
			"enemy_mutant_beast_01",   ## 变异噬齿兽 - 高速攻击
			"enemy_mutant_beast_02",   ## 变异蛛蝎 - 毒液DoT
			"enemy_abomination_01",    ## 初级孽体 - 基础肉搏
			"enemy_abomination_02",    ## 腐烂孽体 - 带流血撕咬
		],
		"elite": [
			"enemy_elite_brute_01",    ## 肥大畸变体 - 高血眩晕
			"enemy_elite_spitter_01",  ## 腐液喷射者 - DoT+沉默
			"enemy_elite_stalker_01",  ## 暗影潜行者 - 高速流血
		],
		"boss": ["enemy_boss_gate2"],  ## 铁壁主脑
	},
}

## 精英出现概率（战斗节点有此概率变为精英战）
const ELITE_BATTLE_CHANCE := 0.25


## 根据容器尺寸计算能容纳的列数和行数
static func calc_grid_size(container_size: Vector2) -> Vector2i:
	var step := CELL_SIZE + CELL_GAP
	var cols := maxi(3, int(container_size.x / step))
	var rows := maxi(3, int(container_size.y / step))
	return Vector2i(cols, rows)


## 生成指定黑门的地图节点数组，seed为0时自动生成随机种子
static func generate(gate: int, cols: int, rows: int, map_seed: int = 0) -> Array[MapNodeData]:
	var nodes: Array[MapNodeData] = []
	var rng := RandomNumberGenerator.new()
	if map_seed == 0:
		map_seed = hash(gate * 1000 + randi())
	rng.seed = map_seed

	# 构建权重池
	var weight_pool: Array[int] = []
	for type: int in NODE_WEIGHTS:
		for i in NODE_WEIGHTS[type]:
			weight_pool.append(type)

	# 生成所有节点
	for row in rows:
		for col in cols:
			var node := MapNodeData.new()
			node.id = "node_%d_%d" % [row, col]
			node.grid_position = Vector2i(col, row)

			# 确定节点类型
			if row == 0:
				node.node_type = MapNodeData.NodeType.ENTRANCE
			elif row == rows - 1:
				if col == cols / 2:
					node.node_type = MapNodeData.NodeType.BOSS
				else:
					node.node_type = MapNodeData.NodeType.EMPTY
			else:
				var random_index := rng.randi_range(0, weight_pool.size() - 1)
				node.node_type = weight_pool[random_index] as MapNodeData.NodeType

			# 确保第1行（入口后）至少有一个战斗节点
			if row == 1 and col == cols - 1:
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

			# 填充敌人配置
			if node.node_type == MapNodeData.NodeType.BATTLE:
				node.enemy_group = _generate_battle_group(rng, gate)
			elif node.node_type == MapNodeData.NodeType.BOSS:
				node.enemy_group = _get_boss_group(gate)

			# 建立连接关系（上下左右相邻）
			var connections: Array[String] = []
			if row > 0:
				connections.append("node_%d_%d" % [row - 1, col])
			if row < rows - 1:
				connections.append("node_%d_%d" % [row + 1, col])
			if col > 0:
				connections.append("node_%d_%d" % [row, col - 1])
			if col < cols - 1:
				connections.append("node_%d_%d" % [row, col + 1])
			node.connected_nodes = connections

			nodes.append(node)

	return nodes


## 生成战斗节点的敌人编组
static func _generate_battle_group(rng: RandomNumberGenerator, gate: int) -> Array[String]:
	var config := _get_gate_config(gate)
	var normal_pool: Array = config["normal"]
	var elite_pool: Array = config["elite"]

	## 判断是否为精英战
	var is_elite := rng.randf() < ELITE_BATTLE_CHANCE
	if is_elite and not elite_pool.is_empty():
		return _generate_elite_group(rng, elite_pool, normal_pool)
	return _generate_normal_group(rng, normal_pool)


## 普通战斗：2-3个普通小怪
static func _generate_normal_group(rng: RandomNumberGenerator, pool: Array) -> Array[String]:
	var group: Array[String] = []
	var count := rng.randi_range(2, 3)
	for i in count:
		group.append(pool[rng.randi_range(0, pool.size() - 1)])
	return group


## 精英战斗：1个精英 + 0-1个普通小怪
static func _generate_elite_group(rng: RandomNumberGenerator, elite_pool: Array, normal_pool: Array) -> Array[String]:
	var group: Array[String] = []
	group.append(elite_pool[rng.randi_range(0, elite_pool.size() - 1)])
	if rng.randf() < 0.6 and not normal_pool.is_empty():
		group.append(normal_pool[rng.randi_range(0, normal_pool.size() - 1)])
	return group


## 获取 BOSS 敌人编组
static func _get_boss_group(gate: int) -> Array[String]:
	var config := _get_gate_config(gate)
	var boss: Array = config["boss"]
	var result: Array[String] = []
	for id in boss:
		result.append(id)
	return result


## 获取指定黑门的敌人配置（未配置的门回退到门1）
static func _get_gate_config(gate: int) -> Dictionary:
	if GATE_ENEMIES.has(gate):
		return GATE_ENEMIES[gate]
	## 回退到最高已配置的门
	var best_gate := 1
	for g: int in GATE_ENEMIES:
		if g <= gate and g > best_gate:
			best_gate = g
	return GATE_ENEMIES[best_gate]
