extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
#	var btn = $WindowDialog.get_close_button()
#	btn.hide()

func show():
	get_child(0).visible = true
	
func hide():
	get_child(0).visible = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
