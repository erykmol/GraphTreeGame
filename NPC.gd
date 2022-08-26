extends KinematicBody2D



const UP_DIRECTION = Vector2.UP

var speed = 600
export var jump_strength = 1500
export var maximum_jumps = 2
export var double_jump_strength = 1200
export var gravity = 4500

var _jumps_made = 0
var _velocity = Vector2.ZERO

onready var productions = []
var is_in_party = false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_meta("type", "npc")


func _physics_process(delta):
#	var _horizontal_direction = (
#		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
#	)
#	_velocity.x = _horizontal_direction * speed
	_velocity.y += gravity * delta
	
#	if _velocity.x > 0:
#		scale.x = scale.y * -1
#	elif _velocity.x < 0:
#		scale.x = scale.y * 1
	
	_velocity = move_and_slide(_velocity, UP_DIRECTION)

func set_productions(new_productions):
	productions = new_productions

func get_productions():
	return productions
