extends Node2D

var vBoxContainer
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var itemsList

# Called when the node enters the scene tree for the first time.
func _ready():
	vBoxContainer = get_child(0).get_child(0).get_child(0).get_child(1).get_child(2)

func show():
	get_child(0).visible = true
	
func hide():
	get_child(0).visible = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func addOption(option):
	option.rect_size.y = 51
	vBoxContainer.add_child(option)
	print(vBoxContainer.rect_size)
