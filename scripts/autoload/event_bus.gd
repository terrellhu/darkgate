## 全局信号总线
## 解耦各模块间的通信
extends Node

# ========== 资源相关 ==========
## 资源数量变化
signal resource_changed(resource_type: String, new_value: int)

# ========== 探索相关 ==========
## SAN值（理智）变化
signal san_updated(new_value: float)
## 精神链接值变化
signal mental_link_updated(new_value: float)
## 触发探索事件
signal exploration_event_triggered(event_id: String)
## 到达地图节点
signal map_node_entered(node_id: String)

# ========== 战斗相关 ==========
## 战斗开始
signal combat_started(enemy_ids: Array)
## 战斗结束（"victory" / "defeat"）
signal combat_ended(result: String)
## 角色行动条就绪
signal atb_ready(character_id: String)

# ========== 角色相关 ==========
## 招募了新角色
signal character_recruited(character_id: String)
## 角色死亡
signal character_died(character_id: String)
## 异化值变化
signal aberration_updated(character_id: String, new_value: float)
## 异格者失控
signal character_lost_control(character_id: String)
## 角色装备变化
signal equipment_changed(character_id: String, slot: String, item_id: String)
## 背包物品数量变化
signal inventory_changed(item_id: String, new_count: int)

# ========== 场景/UI相关 ==========
## 请求切换场景
signal scene_change_requested(scene_path: String)
## 弹窗请求
signal popup_requested(popup_type: String, data: Dictionary)
## 叙事文本显示
signal narrative_display(text: String, choices: Array)

# ========== 成长相关 ==========
## 角色获得经验
signal xp_awarded(character_id: String, amount: int, new_level: int)
## 黑门推进
signal gate_advanced(new_gate: int)

# ========== 枢纽经营 ==========
## 设施升级
signal facility_upgraded(facility_id: String, new_level: int)
## 理智广播开启/关闭
signal broadcast_toggled(is_active: bool)
## 准备完成，确认出征
signal preparation_confirmed(team: Array[String])
