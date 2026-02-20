# 模块7实施计划：内容装填与上线前打磨

---

## 1. 目标

形成可测试版本与可持续扩展内容管线。重点确保**第一扇黑门**达到可外测质量。

### DoD（完成标准）
1. 至少"第一扇黑门"达到可外测质量。
2. 核心流程无阻塞，崩溃率可控。
3. 主要系统参数具备可维护的配置表。

---

## 2. 当前内容盘点

| 内容类型 | 已有数量 | 目标数量 | 状态 |
|----------|----------|----------|------|
| 探索事件 | 7 | 25+ | 需大量扩充 |
| 叙事碎片/对话 | 0 | 15+ | 从零开始 |
| 敌人模板 | 11 (Gate 1-2) | 11 (Gate 1优先) | Gate 1已完成 |
| 装备道具 | 8 | 8 (Gate 1够用) | Gate 1已完成 |
| 技能树节点 | 36 (11个占位) | 36 (全部实装) | 需补全 |
| 音效/音乐 | 0 | 基础覆盖 | 暂不处理 |
| UI主题 | 基础功能 | 可玩级 | 后续打磨 |

---

## 3. 分阶段计划

### 阶段7.1 — 第一扇黑门内容补全（最高优先级）

#### 7.1.1 探索事件扩充

为Gate 1补充约18个新事件，每个事件需写3段SAN分级文本。按类型分布：

| 类型 | 已有 | 新增 | 合计 | 说明 |
|------|------|------|------|------|
| NARRATIVE | 1 | 5 | 6 | 纯叙事，展现废土氛围与Y-崩溃余波 |
| CHOICE | 1 | 4 | 5 | 道德抉择，影响资源/SAN/精神链接 |
| CHECK | 1(+2子事件) | 3(+6子事件) | 4 | 属性检定，分支成功/失败结果 |
| TRAP | 1 | 3 | 4 | 强制负面效果，制造紧张感 |
| REWARD | 1 | 3 | 4 | 正面事件，提供资源/道具 |

事件主题围绕Gate 1环境（废土城市废墟/地铁站/工业区）：
- 幸存者遭遇（选择类）
- 旧时代遗迹探索（检定类）
- 变异生物巢穴（陷阱类）
- 军事物资发现（奖励类）
- 变异前人类遗物（叙事类，展现Y-崩溃悲剧）

#### 7.1.2 叙事碎片系统

在 `data/dialogues/` 目录下创建数据终端可读的世界观碎片文件。内容类型：
- 旧时代日志（科学家/军人/平民视角）
- 异化研究报告
- 紧急广播记录
- 幸存者求救信号

暂使用 EventData 的 NARRATIVE 类型，后续可扩展专用资源类。

#### 7.1.3 技能树占位补全

需要补全的11个技能节点：

| 技能ID | 名称 | 职业 | 分支 | 设计方向 |
|--------|------|------|------|----------|
| skill_tree_assault_b2 | 铁壁意志 | ASSAULT | 持久B2 | BUFF/自身防御+生命回复 |
| skill_tree_assault_b3 | 不屈战魂 | ASSAULT | 持久B3 | BUFF/低血触发回复+攻击增强 |
| skill_tree_exec_b2 | 腐蚀涂层 | EXEC | 毒B2 | DEBUFF/降低目标防御+持续伤害 |
| skill_tree_shield_a3 | 绝对防御 | SHIELD | 守护A3 | BUFF/大幅减伤+嘲讽 |
| skill_tree_shield_b1 | 荆棘护甲 | SHIELD | 反击B1 | PASSIVE/受击反伤 |
| skill_tree_shield_b2 | 反击姿态 | SHIELD | 反击B2 | BUFF/受击后反击概率 |
| skill_tree_plague_b2 | 衰败光环 | PLAGUE | 腐蚀B2 | DEBUFF/AOE降防 |
| skill_tree_psion_b2 | 心灵共鸣 | PSION | 辅助B2 | HEAL/群体治疗+小量护盾 |
| skill_tree_psion_b3 | 超载赋能 | PSION | 辅助B3 | BUFF/全队攻击速度提升 |
| skill_tree_berserker_a1 | 血怒 | BERSERKER | 狂暴A1 | BUFF/高异化消耗换攻击力飙升 |
| skill_tree_berserker_b3 | 不死战意 | BERSERKER | 吸血B3 | BUFF/濒死触发+大量回复 |

#### 7.1.4 Gate 1数值平衡

验证重点：
- 初始队伍(Lv1)能否通过Gate 1前半段普通战斗
- Lv5-8队伍能否挑战Gate 1精英战
- Lv10+队伍能否击败Gate 1 Boss（深渊吞噬者）
- 单次探索资源消耗与产出是否可持续

---

### 阶段7.2 — UI反馈与可读性（后续）

1. 战斗反馈：伤害飘字、暴击特效、状态图标、ATB条动画
2. 探索反馈：节点揭示动画、SAN变化提示、迷雾效果
3. 枢纽反馈：资源变化提示、设施升级特效
4. 日志系统：战斗日志可回溯

### 阶段7.3 — 稳定性与性能（后续）

1. 冒烟测试：主菜单→枢纽→准备→探索→战斗→返回枢纽全流程
2. 存档鲁棒性：边界情况处理
3. 移动端适配：720x1280目标分辨率
4. 内存/性能：连续多场战斗无泄漏

### 阶段7.4 — 扩展内容（后续）

1. Gate 3-9敌人梯度扩展
2. 更多品质/职业专属装备
3. 多阶段Boss机制
4. 黑门解锁条件联动

---

## 4. 文件清单（阶段7.1产出物）

### 新增事件文件 (data/events/)
```
event_narrative_02.tres ~ event_narrative_06.tres   (5个叙事)
event_choice_02.tres ~ event_choice_05.tres         (4个选择)
event_check_02.tres ~ event_check_04.tres           (3个检定)
event_check_02_success/failure.tres                  (6个子事件)
event_check_03_success/failure.tres
event_check_04_success/failure.tres
event_trap_02.tres ~ event_trap_04.tres             (3个陷阱)
event_reward_02.tres ~ event_reward_04.tres         (3个奖励)
```

### 新增叙事碎片文件 (data/dialogues/)
```
lore_scientist_log_01.tres ~ 03.tres    (科学家日志)
lore_soldier_diary_01.tres ~ 03.tres    (军人日记)
lore_broadcast_01.tres ~ 03.tres        (紧急广播)
lore_survivor_note_01.tres ~ 03.tres    (幸存者留言)
```

### 修改技能文件 (data/skills/) — 11个占位补全
```
skill_tree_assault_b2/b3.tres
skill_tree_exec_b2.tres
skill_tree_shield_a3/b1/b2.tres
skill_tree_plague_b2.tres
skill_tree_psion_b2/b3.tres
skill_tree_berserker_a1/b3.tres
```
