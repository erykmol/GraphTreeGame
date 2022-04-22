extends TextureButton

var child

func _ready():
	child = get_child(0)
	child.self_modulate.a = 0.0
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	connect("pressed", self, "_on_mouse_pressed")

func _on_mouse_entered():
	child.self_modulate.a = 1.0

func _on_mouse_exited():
	child.self_modulate.a = 0.0

func _on_mouse_pressed():
	get_tree().change_scene("res://Locations/" + name + ".tscn")
