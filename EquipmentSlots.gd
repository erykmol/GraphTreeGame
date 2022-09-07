extends Panel

onready var slots = get_children()
var items = {}

signal slot_filled

func _ready():
	for slot in slots:
		items[slot.name] = null

func insert_item(item):
	var item_pos = item.rect_global_position + item.rect_size / 2
	var slot = get_slot_under_pos(item_pos)
	if slot == null:
		return false
	
	var db_Item = ItemDB.get_item(item.get_meta("id"))
	var item_slot = db_Item["slot"]
	if item_slot != slot.name:
		return false
	if items[item_slot] != null:
		return false
	items[item_slot] = item
	item.rect_global_position = slot.rect_global_position + slot.rect_size / 2 - item.rect_size / 2
	emit_signal("slot_filled", slot.name, db_Item)
	return true

func grab_item(pos):
	var item = get_item_under_pos(pos)
	if item == null:
		return null
	
	var item_slot = ItemDB.get_item(item.get_meta("id"))["slot"]
	items[item_slot] = null
	return item

func get_slot_under_pos(pos):
	return get_thing_under_pos(slots, pos)

func get_item_under_pos(pos):
	return get_thing_under_pos(items.values(), pos)

func get_thing_under_pos(arr, pos):
	for thing in arr:
		if thing != null and thing.get_global_rect().has_point(pos):
			return thing
	return null

func insert_item_for_slot(item, slot):
	if slot == "HEAD":
		pass
	if slot == "CHEST":
		item.rect_global_position = $CHEST.rect_global_position + $CHEST.rect_size / 2 - item.rect_size / 2
#		$CHEST.texture = load(path)
	if slot == "LEGS":
		pass
	if slot == "MAIN_HAND":
		item.rect_global_position = $MAIN_HAND.rect_global_position + $MAIN_HAND.rect_size / 2 - item.rect_size / 2
#		$MAIN_HAND.texture = load(path)
	if slot == "OFF_HAND":
		item.rect_global_position = $OFF_HAND.rect_global_position + $OFF_HAND.rect_size / 2 - item.rect_size / 2
#		$OFF_HAND.texture = load(path)
