## 设施配置数据模板
## 定义每种设施的基础参数和升级曲线
class_name FacilityData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var unlock_gate: int = 0  ## 解锁所需黑门层数（0 = 初始可用）

## 生产
@export_group("生产")
@export var produces_resource: String = ""  ## 产出资源类型（如 "bio_electricity"）
@export var base_output_per_worker: int = 0  ## 每工人每周期基础产出
@export var output_per_level_bonus: float = 0.2  ## 每级额外产出比例（+20%）

## 升级
@export_group("升级")
@export var upgrade_base_nano: int = 50
@export var upgrade_base_chips: int = 20
@export var upgrade_cost_scale: float = 1.5  ## 每级费用倍率
@export var max_level: int = 5
@export var max_workers_per_level: int = 2  ## 最大工人数 = 等级 × 此值
