extends Node2D

var json

# Called when the node enters the scene tree for the first time.
func _ready():
	var container = get_child(0)
	container.get_v_scrollbar().rect_scale.x = 0
	container.rect_position = get_viewport().size / 2 - container.get_size() / 2
	var loader = load("res://JSONLoader/JSONLoader.gd").new()
	json = loader.load_json_file("res://World_q0_pure.json")
	var locations = json[0]["LSide"]["Locations"]
	var first_location = locations[0]
	var connections_available = first_location["Connections"]
	var destination_ids = []
	for connection in connections_available:
		destination_ids.append(connection["Destination"])
	var available_locations = []
	
	ItemDB.build_items(locations)
	
	for location in locations:
		if destination_ids.has(location["Id"]):
			available_locations.append(location)
	var scroll = get_child(0).get_child(2)
	
	for available_location in available_locations:
		var location_rect = load("res://Map/LocationRect.tscn").instance()
		location_rect.set_map_title(available_location["Name"])
		location_rect.rect_min_size = Vector2(411, 200)
		location_rect.characters = available_location["Characters"]
		if available_location.has("Items"):
			location_rect.items = available_location["Items"]
		scroll.add_child(location_rect)
		
