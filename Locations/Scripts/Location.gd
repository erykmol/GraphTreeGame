extends Node2D

signal set_productions

var player
var json

const item_object = preload("res://ItemObject.tscn")

#var all_locations
var world
var available_locations = {}
var dialog_box

var current_location_id

var player_productions = []
var location_change_production = {}
var all_productions = []
var chosen_production

var characters_positions = {}
var items_positions = {}

func _ready():
	$HTTPRequest.connect("get_world", self, "_get_world")
	$HTTPRequest.connect("get_productions", self, "_get_productions")
	$HTTPRequest.get_world()

func set_map_title(title):
	var first_static_body = get_child(1)
	var sprite = get_child(0).get_child(0).get_child(0)
	var map_texture_path = "res://MapsTextures/" + title.replace("'", "").to_lower() + ".png"
	var directory = Directory.new()
	if directory.file_exists(map_texture_path):
		sprite.texture = load(map_texture_path)
	else:
		sprite.texture = load("res://MapsTextures/placeholder.png")
	sprite.global_position = Vector2(0, 0)
	player.global_position = Vector2(256, 290)

func _process(delta):
	if Input.is_action_just_pressed("inventory_open"):
		player.load_inventory()
		
	if Input.is_action_just_pressed("map_open"):
		player.load_map()
	
func add_characters(characters):
	var position_x = 512
	var directory = Directory.new();
	var characters_productions = get_productions_for_characters()
	for character in characters:
		if character["Name"].to_lower() == "main_hero":
			var scene = load("res://Player.tscn")
			player = scene.instance()
			player.connect("item_picked", self, "_item_picked")
			var locationChangeArea = get_child(1).get_child(0).get_child(1)
			locationChangeArea.set_meta("id", "location_change")
			var locationChangeArea1 = get_child(9).get_child(1)
			locationChangeArea1.set_meta("id", "location_change")
			for item in character["Items"]:
				Global.gathered_items.append(item["Name"].to_lower())
			add_child(player)
			var player_health = character["Attributes"]["HP"]
			player.max_health = player_health
			player.health = player_health
			return
		
		var character_name = character["Name"].to_lower()
		var path = "res://Characters/" + character_name + "/" + character_name + ".tscn"
		var fileExists = directory.file_exists(path)
		var scene
		if fileExists:
			scene = load(path)
		else:
			scene = load("res://Characters/placeholder/placeholder_character.tscn")
		var characterInstance = scene.instance()
		var script = load("res://NPC.gd").new()
#		script._ready()
#		characterInstance.set_script(script)
#		characterInstance._ready()
#		script._ready()
#		script.set_process(true) # if you have processing logic
#		script.set_physics_process(true) # if you have physics logic
		var character_global_position = Vector2(position_x, 290)
		if characters_positions.has(character_name):
			characterInstance.global_position = characters_positions[character_name]
		else:
			characterInstance.global_position = character_global_position
			characters_positions[character_name] = character_global_position
		position_x += 100
		add_child(characterInstance)
		emit_signal("set_productions", characters_productions[character_name])
		script.set_productions(characters_productions[character_name])

func add_items(items):
	var position_x = 712
	if items != null:
		var items_productions = get_productions_for_items()
		for item in items:
			var itemInstance = item_object.instance()
			var item_name = item["Name"].to_lower()
			var itemDB_item = ItemDB.get_item(item_name)
			itemInstance.set_meta("scene_name", "ItemObject")
			itemInstance.set_meta("id", item_name)
			itemInstance.get_child(2).texture = load(itemDB_item["icon"])
			var collisionShape = itemInstance.get_child(1).get_child(0)
			collisionShape.set_disabled(false)
			var script = load("res://NPC.gd")
			itemInstance.set_script(script)
			var item_global_position = Vector2(position_x, 290)
			if items_positions.has(item_name):
				itemInstance.global_position = items_positions[item_name]
			else:
				itemInstance.global_position = item_global_position
				items_positions[item_name] = item_global_position
			position_x += 200
			add_child(itemInstance)
			emit_signal("set_productions", items_productions[item_name])
#			script.set_productions()

func _item_picked(item):
	remove_child(item)

func _location_change(location_name, production, location_variant):
	player.is_dialog_open = false
	remove_child(dialog_box)
	$HTTPRequest.post_new_world(world, production, location_variant, "Main_hero")

func _production_execution(production, variant):
	player.is_dialog_open = false
	remove_child(dialog_box)
	$HTTPRequest.post_new_world(world, production, variant, "Main_hero")

func getFirstLocation(locations):
	for location in locations:
		if location.has("Characters"):
			for character in location["Characters"]:
				if character["Name"].to_lower() == "main_hero":
					return location

func showDialogBox(id, object):
	dialog_box = load("res://DialogBox/DialogBox.tscn").instance()
	add_child(dialog_box)
	dialog_box.set_position(Vector2(player.global_position.x, player.global_position.y - 200))
	if id == "location_change":
		for location_variant in location_change_production["variants"]:
			if String(location_variant[0]["WorldNodeId"]) == current_location_id:
				var option = load("res://DialogBox/DialogOption.tscn").instance()
				option.rect_min_size = Vector2(20, 300)
				option.set_text(location_variant[2]["WorldNodeName"])
				option.set_variant(location_variant)
				option.set_production(location_change_production)
				option.connect("location_change", self, "_location_change")
				dialog_box.addOption(option)
	else:
		for production in object.get_productions():
			var option = load("res://DialogBox/DialogOption.tscn").instance()
			option.rect_min_size = Vector2(20, 300)
			option.set_text(production["Title"])
			option.set_variant(production["variants"][0])
			option.set_production(location_change_production)
			option.connect("production_execution", self, "_production_execution")
			dialog_box.addOption(option)
	dialog_box.show()
	
func hideDialogBox():
	player.is_dialog_open = false
	remove_child(dialog_box) 
	dialog_box.hide()
	dialog_box = null
	
func _slot_filled(slot, path):
	player._slot_filled(slot, path)

func _get_world(world):
	self.world = world.duplicate(true)
	characters_positions = {}
	items_positions = {}
	var first_location = getFirstLocation(world)
	current_location_id = first_location["Id"]
	add_characters(first_location["Characters"])
	if first_location.has("Items"):
		add_items(first_location["Items"])
	var connections_available = first_location["Connections"]
	var destination_ids = []
	for connection in connections_available:
		destination_ids.append(connection["Destination"])
	
	ItemDB.build_items_from_locations(world)
	
	for location in world:
		if destination_ids.has(location["Id"]):
			available_locations[location["Name"]] = location
		if location.has("Items"):
			ItemDB.build_items_from_characters(location["Items"])
	
	set_map_title(first_location["Name"])

func _get_productions(player_productions, all_productions):
	self.player_productions = player_productions
	for production in player_productions:
		if "location change" in production["prod"]["Title"].to_lower():
			location_change_production = production
	self.all_productions = all_productions
#	print(JSON.print(all_productions))

func get_productions_for_characters():
	var productions_to_return = {}
#	print("test", all_productions)
	for production in all_productions:
#		print(production)
		for variant in production["variants"]:
#			print(variant)
			for node in variant:
#				print(node)
				var LSNodeRef = node["LSNodeRef"].to_lower()
				if LSNodeRef == "bohatera" || LSNodeRef == "bohaterb":
					var WorldNodeName = node["WorldNodeName"].to_lower()
#					if WorldNodeName != "main_hero":
					if productions_to_return.has(WorldNodeName):
						productions_to_return[WorldNodeName].append(production)
					else:
						productions_to_return[WorldNodeName] = [production]
#					else:
#						if productions_to_return.has("main_hero"):
#							productions_to_return["main_hero"] = [production]
#						else:
#							productions_to_return["main_hero"].append(production)
	return  productions_to_return

func get_productions_for_items():
	var productions_to_return = {}
	for production in all_productions:
		var production_and_variants = {}
		for variant in production["variants"]:
			for node in variant:
				var LSNodeRef = node["LSNodeRef"].to_lower()
				if LSNodeRef == "something" || LSNodeRef == "opakowanie":
					var WorldNodeName = node["WorldNodeName"].to_lower()
					if productions_to_return.has(WorldNodeName):
						productions_to_return[WorldNodeName].append(production)
					else:
						productions_to_return[WorldNodeName] = [production]
	return  productions_to_return
