extends Control

const item_base = preload("res://ItemBase.tscn")

onready var inventory_base = $InventoryBase
onready var grid_backpack = $GridBackPack
onready var equipment_slots = $EquipmentSlots

var item_held = null
var item_offset = Vector2()
var last_container = null
var last_position = Vector2()

var text_box

func _ready():
	var player = get_parent()
	for key in ItemDB.equipped_items.keys():
		var item_object = ItemDB.equipped_items[key]
		var item_id = item_object["Name"]
		var item = item_base.instance()
		item.set_meta("id", item_id)
		item.texture = load(item_object["icon"])
		add_child(item)
		equipment_slots.insert_item_for_slot(item, key)
	
	for item in ItemDB.gathered_items:
		pickup_item(item)
	equipment_slots.connect("slot_filled", self, "_slot_filled")
	text_box = load("res://TextBox.tscn").instance()
	add_child(text_box)

func _process(delta):
	var cursor_pos = get_global_mouse_position()
	if Input.is_action_just_pressed("inv_grab"):
		grab(cursor_pos)
	if Input.is_action_just_released("inv_grab"):
		release(cursor_pos)
	if item_held != null:
		item_held.rect_global_position = cursor_pos + item_offset
		
	show_textBox(cursor_pos)
	
func show_textBox(cursor_pos):
	var a = grid_backpack.get_item_under_pos(cursor_pos)
	var b = equipment_slots.get_item_under_pos(cursor_pos)
#	var c = get_container_under_cursor(cursor_pos)
		
	if a != null:
		set_data_for_text_box(a)
		display_text_box(a, cursor_pos)
	elif b != null:
		set_data_for_text_box(b)
		display_text_box(b, cursor_pos)
	else:
		text_box.hide()
		
func set_data_for_text_box(item_object):
	var item = ItemDB.get_item(item_object.get_meta("id"))
	var text = "Name: " + item["Name"]
	if item.has("Attributes"):
		var attributes = item["Attributes"]
		for key in attributes.keys():
			text = text + "\n" + key + ": " + String(attributes[key])
	text_box.set_text(text)

func display_text_box(item_object, cursor_pos):
	text_box.rect_global_position = cursor_pos
	text_box.show()
#	if text_box.get_parent() == null:
#		add_child(text_box)
		
func grab(cursor_pos):
	var c = get_container_under_cursor(cursor_pos)
	if c != null and c.has_method("grab_item"):
		item_held = c.grab_item(cursor_pos)
		if item_held != null:
			last_container = c
			last_position = item_held.rect_global_position
			item_offset = item_held.rect_global_position - cursor_pos
			move_child(item_held, get_child_count())

func release(cursor_pos):
	if item_held == null:
		return
	var c = get_container_under_cursor(cursor_pos)
	if c == null:
		drop_item()
	elif c.has_method("insert_item"):
		if c.insert_item(item_held):
			item_held = null
		else:
			return_item()
	else:
		return_item()
	

func get_container_under_cursor(cursor_pos):
	var containers = [grid_backpack, equipment_slots, inventory_base]
	for c in containers:
		if c.get_global_rect().has_point(cursor_pos):
			return c
	return null

func drop_item():
	item_held.queue_free()
	item_held = null

func return_item():
	item_held.rect_global_position = last_position
	last_container.insert_item(item_held)
	item_held = null
	
func pickup_item(item_object):
	var item_id = item_object["Name"]
	var item = item_base.instance()
	item.set_meta("id", item_id)
	item.texture = load(item_object["icon"])
	add_child(item)
	if !grid_backpack.insert_item_at_first_available_spot(item):
		item.queue_free()
		return false
	return true

func _slot_filled(slot, item):
	var icon_path = item["icon"]
	get_parent()._slot_filled(slot, icon_path)
	ItemDB.add_item_to_equipped(item)
