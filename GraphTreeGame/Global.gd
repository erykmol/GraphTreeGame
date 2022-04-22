extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var player
var current_location
var characters
var location_items
var gathered_items = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var scene = load("res://Player.tscn")
	player = scene.instance()
