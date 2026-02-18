## 装备服务
## 提供装备槽位规范、装备合法性校验、旧数据兼容迁移
class_name EquipmentService
extends RefCounted

const SLOT_WEAPON := "WEAPON"
const SLOT_HEAD := "HEAD"
const SLOT_BODY := "BODY"
const SLOT_ARMS := "ARMS"
const SLOT_LEGS := "LEGS"
const SLOT_ACCESSORY_A := "ACCESSORY_A"
const SLOT_ACCESSORY_B := "ACCESSORY_B"

const HERO_EQUIP_SLOTS: Array[String] = [
	SLOT_WEAPON,
	SLOT_HEAD,
	SLOT_BODY,
	SLOT_ARMS,
	SLOT_LEGS,
	SLOT_ACCESSORY_A,
	SLOT_ACCESSORY_B,
]

const SLOT_DISPLAY_NAMES := {
	SLOT_WEAPON: "武器",
	SLOT_HEAD: "头部",
	SLOT_BODY: "躯干",
	SLOT_ARMS: "手臂",
	SLOT_LEGS: "腿部",
	SLOT_ACCESSORY_A: "饰品A",
	SLOT_ACCESSORY_B: "饰品B",
}


static func create_empty_hero_equipment() -> Dictionary:
	var equipment := {}
	for slot in HERO_EQUIP_SLOTS:
		equipment[slot] = ""
	return equipment


static func normalize_hero_equipment(raw: Variant) -> Dictionary:
	var equipment := create_empty_hero_equipment()
	if raw is Dictionary:
		var dict_raw: Dictionary = raw
		for slot in HERO_EQUIP_SLOTS:
			var value: Variant = dict_raw.get(slot, "")
			equipment[slot] = _to_item_id(value)
		return equipment

	if raw is Array:
		var ids: Array[String] = Array(raw, TYPE_STRING, "", null)
		return assign_items_to_slots(ids, equipment)

	return equipment


static func assign_items_to_slots(item_ids: Array[String], initial: Dictionary = {}) -> Dictionary:
	var equipment := normalize_hero_equipment(initial)
	for item_id in item_ids:
		var item: ItemData = DataManager.get_item(item_id)
		if item == null or not is_equip_item(item):
			continue
		var runtime_slots := get_runtime_slots_for_item(item)
		for slot in runtime_slots:
			if String(equipment.get(slot, "")).is_empty():
				equipment[slot] = item_id
				break
	return equipment


static func get_runtime_slots_for_item(item: ItemData) -> Array[String]:
	match item.equip_slot:
		ItemData.EquipSlot.SLOT_WEAPON:
			return [SLOT_WEAPON]
		ItemData.EquipSlot.SLOT_HEAD:
			return [SLOT_HEAD]
		ItemData.EquipSlot.SLOT_BODY:
			return [SLOT_BODY]
		ItemData.EquipSlot.SLOT_ARMS:
			return [SLOT_ARMS]
		ItemData.EquipSlot.SLOT_LEGS:
			return [SLOT_LEGS]
		ItemData.EquipSlot.SLOT_ACCESSORY:
			return [SLOT_ACCESSORY_A, SLOT_ACCESSORY_B]
		_:
			return []


static func slot_accepts_item(slot: String, item: ItemData) -> bool:
	return slot in get_runtime_slots_for_item(item)


static func is_equip_item(item: ItemData) -> bool:
	return item.item_type == ItemData.ItemType.WEAPON \
		or item.item_type == ItemData.ItemType.ARMOR \
		or item.item_type == ItemData.ItemType.ACCESSORY


static func get_equip_block_reason(
	char_data: CharacterData,
	runtime: Dictionary,
	item: ItemData,
	slot: String,
	owned_characters: Dictionary,
	char_id: String
) -> String:
	if item == null:
		return "装备不存在"
	if not is_equip_item(item):
		return "该物品不可装备"
	if not slot_accepts_item(slot, item):
		return "目标槽位不兼容"

	var level := int(runtime.get("level", 1))
	if level < item.min_level:
		return "等级不足"

	if not item.profession_whitelist.is_empty():
		if item.profession_whitelist.find(int(char_data.profession)) == -1:
			return "职业不符"

	if not item.char_type_whitelist.is_empty():
		if item.char_type_whitelist.find(int(char_data.char_type)) == -1:
			return "类型不符"

	var equipment := normalize_hero_equipment(runtime.get("equipment", {}))
	for equipped_slot in HERO_EQUIP_SLOTS:
		if equipped_slot == slot:
			continue
		if String(equipment.get(equipped_slot, "")) == item.id:
			return "该角色已装备同名装备"

	if item.unique_equip and is_item_equipped_by_other(owned_characters, item.id, char_id):
		return "该装备已被其他角色占用"

	return ""


static func is_item_equipped_by_other(owned_characters: Dictionary, item_id: String, exclude_char_id: String = "") -> bool:
	for other_char_id in owned_characters:
		if String(other_char_id) == exclude_char_id:
			continue
		var runtime: Dictionary = owned_characters.get(other_char_id, {})
		var equipment := normalize_hero_equipment(runtime.get("equipment", {}))
		for slot in HERO_EQUIP_SLOTS:
			if String(equipment.get(slot, "")) == item_id:
				return true
	return false


static func get_equipped_item_ids(equipment: Dictionary) -> Array[String]:
	var ids: Array[String] = []
	var normalized := normalize_hero_equipment(equipment)
	for slot in HERO_EQUIP_SLOTS:
		var item_id := String(normalized.get(slot, ""))
		if not item_id.is_empty():
			ids.append(item_id)
	return ids


static func get_slot_display_name(slot: String) -> String:
	return String(SLOT_DISPLAY_NAMES.get(slot, slot))


static func _to_item_id(value: Variant) -> String:
	if value == null:
		return ""
	return String(value)
