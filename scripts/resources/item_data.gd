## 物品/装备数据模板
class_name ItemData
extends Resource

## 物品类型
enum ItemType {
	WEAPON,         ## 武器
	ARMOR,          ## 护甲
	ACCESSORY,      ## 饰品
	CONSUMABLE,     ## 消耗品
	MATERIAL,       ## 材料
	BLUEPRINT,      ## 蓝图
	KEY_ITEM,       ## 关键道具
}

## 品质
enum Quality { WHITE, GREEN, BLUE, PURPLE, ORANGE }

## 装备槽位（仅装备类有效）
enum EquipSlot {
	SLOT_WEAPON,
	SLOT_HEAD,
	SLOT_BODY,
	SLOT_ARMS,
	SLOT_LEGS,
	SLOT_ACCESSORY,
}

@export var id: String = ""
@export var display_name: String = ""
@export var item_type: ItemType = ItemType.MATERIAL
@export var quality: Quality = Quality.WHITE
@export_multiline var description: String = ""
@export var icon_path: String = ""
@export var stackable: bool = true
@export var max_stack: int = 99

## 装备属性（仅装备类有效）
@export_group("装备属性")
@export var equip_slot: EquipSlot = EquipSlot.SLOT_WEAPON
@export var equip_hp: int = 0
@export var equip_atk: int = 0
@export var equip_def: int = 0
@export var equip_speed: int = 0
@export var equip_crit_rate: float = 0.0
@export var min_level: int = 1
@export var profession_whitelist: Array[int] = []
@export var char_type_whitelist: Array[int] = []
@export var unique_equip: bool = false

## 消耗品效果
@export_group("消耗品效果")
@export var heal_amount: int = 0
@export var san_restore: float = 0.0
@export var mental_restore: float = 0.0
