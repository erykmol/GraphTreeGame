extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var player
var current_location
var characters = []
var location_items
var main_hero_id
var camera: Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func is_character(id):
	for character in characters:
		if character["Id"] == id:
			return true
	return false
