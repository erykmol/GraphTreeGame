extends TextureButton

var label
var characters
var items

func _ready():
	label = get_child(0)
	label.self_modulate.a = 1.0
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	connect("pressed", self, "_on_mouse_pressed")

func _on_mouse_entered():
	label.self_modulate.a = 1.0

func _on_mouse_exited():
	label.self_modulate.a = 0.0

func _on_mouse_pressed():
	var scene = get_tree().get_current_scene().filename
	if get_tree().current_scene.name == "Location.tscn":
		scene.set_map_title(get_child(0).text)
	else:
		Global.current_location = get_child(0).text
		Global.characters = characters
		Global.location_items = items
		get_tree().change_scene("res://Locations/Location.tscn")

func set_map_title(title):
	var label = get_child(0)
	label.text = title
