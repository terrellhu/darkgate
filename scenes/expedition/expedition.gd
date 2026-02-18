## 探索场景
## 管理地图移动、事件触发、SAN值变化
extends Control

const MapNodeUIScene := preload("res://scenes/expedition/map_node_ui.tscn")
const MapGeneratorScript := preload("res://scripts/expedition/map_generator.gd")

# ========== 地图状态 ==========
var _map_nodes: Dictionary = {}  ## { id: MapNodeData }
var _node_uis: Dictionary = {}   ## { id: MapNodeUI }
var _current_node_id: String = ""
var _visited_nodes: Dictionary = {}  ## { id: true }

# ========== 事件 ID 池 ==========
var _event_ids: Array[String] = []

# ========== 氛围文本 ==========
const AMBIENT_NORMAL: Array[String] = [
	"空气中弥漫着金属锈蚀的味道。四周寂静无声。",
	"脚下的碎石在黑暗中发出清脆的响声。远处有什么东西在移动。",
	"通道两侧的墙壁上布满了干涸的血迹和抓痕。有人曾在这里拼命逃跑。",
	"荧光苔藓勉强照亮了前方的道路。一切似乎暂时安全。",
	"你发现了一些旧时代的杂志和空罐头。这里曾经有人躲藏过。",
]
const AMBIENT_LOW_SAN: Array[String] = [
	"墙壁似乎在缓缓蠕动。你揉了揉眼睛——也许只是光线的问题。",
	"有人在你耳边低语。但回头看去，身后空无一人。",
	"地面上的影子不属于你们任何一个人。它有太多的手臂。",
	"你的队友向你微笑。但你确信那不是她正常的表情。牙齿太多了。",
]
const AMBIENT_CRITICAL_SAN: Array[String] = [
	"通道变成了一条巨大的食道。肌肉壁在有节奏地收缩，推着你们前进。",
	"你看到了自己的尸体躺在前方。它睁开了眼睛，用你的声音说——'欢迎回家。'",
	"天花板上倒挂着无数张脸。它们都是你认识的人。它们在同时尖叫。",
]

const TREASURE_TEXTS: Array[String] = [
	"你在废墟中发现了一个未被破坏的补给箱！获得了一些纳米合金和芯片。",
	"一具穿着军装的遗骸旁放着一个密封的工具箱。里面的物资保存完好。",
	"隐藏在墙壁暗格中的应急物资。看来有人提前做了准备。",
]

const TERMINAL_TEXTS: Array[String] = [
	"[数据终端 - 音频日志 #0147]\n\n'......第三天了。外面的声音终于停了。但我不敢出去。我听到了我丈夫的声音在门外叫我的名字。但是——他三天前就已经变成了那种东西。'\n\n[记录中断]",
	"[数据终端 - 研究笔记 #0093]\n\n'Y染色体似乎是触发异化的关键受体。病毒选择性地攻击SRY基因区域，导致不可逆的基因重组。女性的XX染色体提供了天然的免疫屏障。讽刺的是，我们一直以为Y染色体代表力量。'\n\n[后续数据已损坏]",
	"[数据终端 - 军方加密通讯 #0221]\n\n'黑门不是入侵。重复，黑门不是入侵。它们是回应。地核深处的信号在呼唤什么东西。我们只是......碰巧在这里。'\n\n[通讯结束]",
]

const SUPPLY_TEXTS: Array[String] = [
	"你找到了一个还在运转的旧时代急救站。自动医疗系统仍在工作。队伍恢复了体力和理智。",
	"一处隐蔽的地下水源。清澈的水让紧绷的神经暂时放松下来。",
]

const BATTLE_TEXTS: Array[String] = [
	"前方的阴影中传来了低沉的咆哮声。孽体发现了你们！",
	"一群扭曲的人形正在撕咬什么东西。它们闻到了你们的气息，缓缓转过头来。",
	"地面上的尸体突然动了——它并没有死透。更多的孽体从废墟中涌出。",
]


func _ready() -> void:
	# 收集可用事件ID
	var all_events := DataManager.get_all_events()
	for event_id: String in all_events:
		_event_ids.append(event_id)

	# 生成地图
	var nodes := MapGeneratorScript.generate(PlayerData.current_gate)
	for node in nodes:
		_map_nodes[node.id] = node

	# 渲染地图
	_render_map()

	# 玩家从入口开始（第1行中间）
	_current_node_id = "node_0_2"
	_visited_nodes[_current_node_id] = true
	_reveal_adjacent(_current_node_id)
	_update_all_node_uis()

	# 初始叙事
	_show_narrative("你踏入了第%d扇黑门。精神链接已建立。\n\n注意管理你的理智和生物电。点击相邻的高亮节点移动。" % PlayerData.current_gate)

	# UI 连接
	_update_status_bars()
	EventBus.san_updated.connect(_on_san_updated)
	EventBus.mental_link_updated.connect(_on_mental_link_updated)
	%BtnRest.pressed.connect(_on_rest)
	%BtnRetreat.pressed.connect(_on_retreat)


## 渲染地图网格
func _render_map() -> void:
	for child in %MapGrid.get_children():
		child.queue_free()
	_node_uis.clear()

	for row in MapGeneratorScript.ROWS:
		for col in MapGeneratorScript.COLUMNS:
			var node_id := "node_%d_%d" % [row, col]
			var node_data: MapNodeData = _map_nodes.get(node_id)
			if node_data == null:
				continue
			var node_ui := MapNodeUIScene.instantiate()
			%MapGrid.add_child(node_ui)
			node_ui.setup(node_data)
			node_ui.node_clicked.connect(_on_node_clicked)
			_node_uis[node_id] = node_ui


## 更新所有节点 UI 状态
func _update_all_node_uis() -> void:
	var current_node: MapNodeData = _map_nodes.get(_current_node_id)
	var reachable_ids: Array[String] = []
	if current_node:
		reachable_ids = current_node.connected_nodes

	for node_id: String in _node_uis:
		var ui = _node_uis[node_id]
		ui.is_current = (node_id == _current_node_id)
		ui.is_visited = _visited_nodes.has(node_id)
		ui.is_reachable = (node_id in reachable_ids) and not ui.is_current
		ui.update_display()


## 揭示相邻节点
func _reveal_adjacent(node_id: String) -> void:
	var node: MapNodeData = _map_nodes.get(node_id)
	if node == null:
		return
	node.revealed = true
	for adj_id in node.connected_nodes:
		var adj: MapNodeData = _map_nodes.get(adj_id)
		if adj:
			adj.revealed = true


## 节点点击处理
func _on_node_clicked(node_id: String) -> void:
	if node_id == _current_node_id:
		return

	var current_node: MapNodeData = _map_nodes.get(_current_node_id)
	if current_node == null or not (node_id in current_node.connected_nodes):
		return

	var target_node: MapNodeData = _map_nodes.get(node_id)
	if target_node == null:
		return

	# 检查生物电
	if PlayerData.bio_electricity < target_node.bio_electricity_cost:
		_show_narrative("生物电不足！无法继续前进。考虑撤退吧。")
		return

	# 消耗资源
	PlayerData.modify_resource("bio_electricity", -target_node.bio_electricity_cost)
	PlayerData.modify_san(-target_node.san_drain)

	# 移动
	_current_node_id = node_id
	_visited_nodes[node_id] = true
	_reveal_adjacent(node_id)
	_update_all_node_uis()

	# 检查 SAN 值
	if PlayerData.current_san <= 0:
		_show_narrative("理智崩溃！队伍陷入了无法控制的恐惧之中......\n\n被迫撤退。")
		await get_tree().create_timer(2.0).timeout
		_force_retreat()
		return

	# 触发节点事件
	_handle_node_event(target_node)


## 处理节点事件
func _handle_node_event(node: MapNodeData) -> void:
	match node.node_type:
		MapNodeData.NodeType.EMPTY, MapNodeData.NodeType.ENTRANCE:
			_handle_empty()
		MapNodeData.NodeType.BATTLE:
			_handle_battle(node)
		MapNodeData.NodeType.EVENT:
			_handle_event()
		MapNodeData.NodeType.TREASURE:
			_handle_treasure()
		MapNodeData.NodeType.TERMINAL:
			_handle_terminal()
		MapNodeData.NodeType.SUPPLY:
			_handle_supply()
		MapNodeData.NodeType.BOSS:
			_handle_boss(node)


func _handle_empty() -> void:
	var texts := _get_ambient_texts()
	_show_narrative(texts[randi() % texts.size()])


func _handle_battle(node: MapNodeData) -> void:
	var text: String = BATTLE_TEXTS[randi() % BATTLE_TEXTS.size()]
	_show_narrative(text + "\n\n[即将进入战斗...]")
	await get_tree().create_timer(1.5).timeout
	var enemy_ids: Array[String] = node.enemy_group.duplicate()
	GameManager.start_combat(enemy_ids)


func _handle_event() -> void:
	if _event_ids.is_empty():
		_handle_empty()
		return

	var event_id: String = _event_ids[randi() % _event_ids.size()]
	var event_data: EventData = DataManager.get_event(event_id)
	if event_data == null:
		_handle_empty()
		return

	# 根据 SAN 选择描述文本
	var text := _get_san_based_text(event_data)

	# 应用即时效果
	if event_data.san_change != 0.0:
		PlayerData.modify_san(event_data.san_change)
	if event_data.bio_electricity_change != 0:
		PlayerData.modify_resource("bio_electricity", event_data.bio_electricity_change)

	# 显示事件
	if event_data.event_type == EventData.EventType.CHOICE and not event_data.choices.is_empty():
		display_narrative(text, event_data.choices)
	else:
		_show_narrative(text)


func _handle_treasure() -> void:
	var text: String = TREASURE_TEXTS[randi() % TREASURE_TEXTS.size()]
	var alloy_gain := randi_range(5, 20)
	var chip_gain := randi_range(2, 10)
	PlayerData.modify_resource("nano_alloy", alloy_gain)
	PlayerData.modify_resource("chips", chip_gain)
	_show_narrative(text + "\n\n获得：纳米合金 +%d，废弃芯片 +%d" % [alloy_gain, chip_gain])


func _handle_terminal() -> void:
	var text: String = TERMINAL_TEXTS[randi() % TERMINAL_TEXTS.size()]
	_show_narrative(text)
	PlayerData.modify_resource("hashrate", randi_range(10, 30))


func _handle_supply() -> void:
	var text: String = SUPPLY_TEXTS[randi() % SUPPLY_TEXTS.size()]
	var san_gain := 15.0
	var bio_gain := 10
	PlayerData.modify_san(san_gain)
	PlayerData.modify_resource("bio_electricity", bio_gain)
	_show_narrative(text + "\n\n恢复：理智 +%.0f，生物电 +%d" % [san_gain, bio_gain])


func _handle_boss(node: MapNodeData) -> void:
	_show_narrative("你感受到了门扉核心散发的强大异化波。这里就是本层的核心。\n\n准备迎战BOSS！\n\n[即将进入战斗...]")
	await get_tree().create_timer(2.0).timeout
	var enemy_ids: Array[String] = node.enemy_group.duplicate()
	GameManager.start_combat(enemy_ids)


## 根据 SAN 值获取对应氛围文本池
func _get_ambient_texts() -> Array[String]:
	var san := PlayerData.current_san
	if san < 10.0:
		var result: Array[String] = []
		result.assign(AMBIENT_CRITICAL_SAN)
		return result
	elif san < 40.0:
		var result: Array[String] = []
		result.assign(AMBIENT_LOW_SAN)
		return result
	else:
		var result: Array[String] = []
		result.assign(AMBIENT_NORMAL)
		return result


## 根据 SAN 值选择事件文本
func _get_san_based_text(event_data: EventData) -> String:
	var san := PlayerData.current_san
	if san < 10.0 and not event_data.critical_san_description.is_empty():
		return event_data.critical_san_description
	elif san < 40.0 and not event_data.low_san_description.is_empty():
		return event_data.low_san_description
	else:
		return event_data.description


# ========== UI ==========

## 显示叙事文本（无选项）
func _show_narrative(text: String) -> void:
	%NarrativeText.text = text
	for child in %ChoiceList.get_children():
		child.queue_free()
	_update_narrative_style(PlayerData.current_san)


## 显示叙事文本（带选项）
func display_narrative(text: String, choices: Array[Dictionary] = []) -> void:
	%NarrativeText.text = text
	for child in %ChoiceList.get_children():
		child.queue_free()
	for choice: Dictionary in choices:
		var btn := Button.new()
		btn.text = choice.get("text", "")
		var choice_data: Dictionary = choice
		btn.pressed.connect(func() -> void: _on_choice_selected(choice_data))
		%ChoiceList.add_child(btn)
	_update_narrative_style(PlayerData.current_san)


func _on_choice_selected(choice: Dictionary) -> void:
	var result: String = choice.get("result", "")
	match result:
		"rescue":
			PlayerData.modify_resource("bio_electricity", -10)
			_show_narrative("你冒险进行了救援。废墟摇摇欲坠，但你成功救出了幸存者。\n\n她告诉你附近有一个旧时代的军火库。这个线索可能有用。\n\n消耗：生物电 -10")
		"leave":
			_show_narrative("你在地图上标记了位置，带着复杂的心情离开了。\n\n有时候活着比英雄主义更重要。")
		"scan":
			if PlayerData.consume_mental_power(10.0):
				PlayerData.modify_san(5.0)
				_show_narrative("你闭上眼睛，通过精神链接扫描了周围的环境。你找到了一条安全的救援路线。\n\n幸存者安全获救。你的基因链发出了轻微的刺痛。\n\n消耗：精神力 -10，基因裂痕 +1\n恢复：理智 +5")
			else:
				_show_narrative("你的精神力不足以进行扫描。你只能无奈地标记位置后离开。")
		_:
			_show_narrative("你做出了选择。命运的齿轮在转动。")


## 更新状态栏显示
func _update_status_bars() -> void:
	%SanBar.value = PlayerData.current_san
	%LinkBar.value = PlayerData.current_mental_link


func _on_san_updated(new_value: float) -> void:
	%SanBar.value = new_value
	_update_narrative_style(new_value)


func _on_mental_link_updated(new_value: float) -> void:
	%LinkBar.value = new_value


## 根据SAN值调整叙事文本风格
func _update_narrative_style(san: float) -> void:
	if san < 10.0:
		%NarrativeText.add_theme_color_override("default_color", Color(0.8, 0.1, 0.1))
	elif san < 40.0:
		%NarrativeText.add_theme_color_override("default_color", Color(0.6, 0.2, 0.6))
	elif san < 70.0:
		%NarrativeText.add_theme_color_override("default_color", Color(0.7, 0.7, 0.3))
	else:
		%NarrativeText.remove_theme_color_override("default_color")


## 休息 —— 消耗生物电恢复SAN
func _on_rest() -> void:
	if PlayerData.bio_electricity < 10:
		_show_narrative("生物电不足，无法休息。")
		return
	PlayerData.modify_resource("bio_electricity", -10)
	PlayerData.modify_san(15.0)
	_show_narrative("队伍就地休整。消耗了一些生物电来维持精神链接的稳定。\n\n消耗：生物电 -10\n恢复：理智 +15")


## 撤退
func _on_retreat() -> void:
	SaveManager.save_game(0)
	GameManager.change_state(GameManager.GameState.HUB)


## 强制撤退（SAN=0）
func _force_retreat() -> void:
	@warning_ignore("integer_division")
	PlayerData.modify_resource("nano_alloy", -PlayerData.nano_alloy / 4)
	GameManager.change_state(GameManager.GameState.HUB)
