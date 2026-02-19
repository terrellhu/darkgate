## 职业技能树配置
## 每个职业对应一棵树，2个分支（A/B），每分支3个节点（Lv10/15/20解锁）
class_name ProfessionTreeData
extends Resource

## 节点解锁等级门槛
const NODE_LEVELS := [10, 15, 20]

@export var id: String = ""
@export var profession: CharacterData.Profession = CharacterData.Profession.ASSAULT
@export var branch_a_name: String = ""
@export var branch_b_name: String = ""
@export var branch_a_skills: Array[String] = []  ## 3个skill_id, 对应Lv10/15/20
@export var branch_b_skills: Array[String] = []  ## 3个skill_id
