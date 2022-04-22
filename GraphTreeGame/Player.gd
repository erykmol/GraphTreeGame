extends KinematicBody2D


const UP_DIRECTION = Vector2.UP

var speed = 600
export var jump_strength = 1500
export var maximum_jumps = 2
export var double_jump_strength = 1200
export var gravity = 4500

var _jumps_made = 0
var _velocity = Vector2.ZERO

var keycap
var is_dialog_open = false
var current_body_entered

signal item_picked
# Called when the node enters the scene tree for the first time.
func _ready():
	keycap = get_child(3)
	var camera = get_child(2)
	camera.position.y = position.y - 465

func _physics_process(delta):
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
	if Input.is_action_just_pressed("interact") && current_body_entered != null:
		if current_body_entered.get_meta("scene_name") == "ItemObject":
			var item_name = current_body_entered.get_meta("id")
			Global.gathered_items.append(item_name)
			emit_signal("item_picked", current_body_entered)
			return
			
		if is_dialog_open:
			var dialog_box = get_child(5)
			dialog_box.hide()
			remove_child(dialog_box)
			is_dialog_open = false
			
		if !is_dialog_open && keycap.visible:
			var dialog_box = load("res://DialogBox.tscn").instance()
			add_child(dialog_box)
			dialog_box.show()
			is_dialog_open = true
