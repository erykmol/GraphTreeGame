extends KinematicBody2D

signal item_picked
signal health_updated
signal killed

const UP_DIRECTION = Vector2.UP

onready var health_bar = $HealthBar

var speed = 10000
export var jump_strength = 1500
export var maximum_jumps = 2
export var double_jump_strength = 1200
export var gravity = 4500

var _jumps_made = 0
var _velocity = Vector2.ZERO

var keycap
var is_dialog_open = false
var current_body_entered

var inventory_open = false
var inventory

var map_open = false
var map

var max_health = 1 setget _set_max_health
var health = max_health setget _set_health
var damage

var item

# Called when the node enters the scene tree for the first time.
func _ready():
	keycap = get_child(3)
	var camera = get_child(2)
	camera.position.y = position.y - 465

func _physics_process(delta):
	if !inventory_open && !map_open:
		var _horizontal_direction = (
			Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		)
		_velocity.x = _horizontal_direction * speed
		_velocity.y += gravity * delta
		
		if _velocity.x > 0:
			scale.x = scale.y * -1
			keycap.scale.x = scale.y * 1
		elif _velocity.x < 0:
			scale.x = scale.y * 1
			keycap.scale.x = scale.y * 1
		
		var _vertical_direction = Input.get_action_strength("ui_up")
		if is_on_floor():
			_velocity.y = -_vertical_direction * jump_strength
			
		_velocity = move_and_slide(_velocity, UP_DIRECTION)

func _on_Area2D_body_entered(body):
	current_body_entered = body
	keycap.visible = true


func _on_Area2D_body_exited(body):
	current_body_entered = null
	keycap.visible = false

func _process(delta):
	if Input.is_action_just_pressed("interact") && current_body_entered != null && current_body_entered.get_meta("id") == "location_change":
		if is_dialog_open:
			get_parent().hideDialogBox(current_body_entered.get_meta("id"), self)
			is_dialog_open = false

		if !is_dialog_open && keycap.visible:
			get_parent().showDialogBox(current_body_entered.get_meta("id"), self)
			is_dialog_open = true
	
	if Input.is_action_just_pressed("interact") && current_body_entered != null:
		if current_body_entered.get_meta("scene_name") == "ItemObject":
			var item_name = current_body_entered.get_meta("id")
			Global.gathered_items.append(item_name.to_lower())
			emit_signal("item_picked", current_body_entered)

func _slot_filled(slot, path):
	if slot == "HEAD":
		pass
	if slot == "CHEST":
		get_child(0).get_child(0).get_child(0).texture = load(path)
	if slot == "LEGS":
		pass
	if slot == "MAIN_HAND":
		get_child(5).texture = load(path)
	if slot == "OFF_HAND":
		get_child(6).texture = load(path)

func load_inventory():
	if inventory_open:
		remove_child(inventory)
		inventory = null
		inventory_open = false
	else:
		inventory = load("res://InventoryUI.tscn").instance()
		scale_inventory()
		add_child(inventory)
		inventory_open = true

func load_map():
	if map_open:
		remove_child(map)
		map = null
		map_open = false
	else:
		map = load("res://Map/Map.tscn").instance()
		scale_map()
		add_child(map)
		map_open = true
		
func scale_map():
	var map_position = Vector2(700, -950)
	if scale == Vector2(1, -1):
		map.scale = Vector2(-1, 1)
	else:
		map_position = Vector2(-700, -950)
	map.position = map_position

func scale_inventory():
	var inventory_position = Vector2(0, -300)
	inventory.rect_position = inventory_position
	if scale == Vector2(1, -1):
		inventory.rect_scale = Vector2(-1, 1)
	else:
		inventory.rect_scale = Vector2(1, 1)
		
func damage(amount):
	_set_health(health - amount)
	
func _set_health(value):
	var previous_health = health
	health = clamp(value, 0, max_health)
	health_bar.value = health
	if health != previous_health:
		if health == 0:
			emit_signal("killed")
			return
		emit_signal("health_updated")

func _set_max_health(value):
	max_health = value
	health_bar.max_value = value