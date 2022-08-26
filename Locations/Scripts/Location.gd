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

#var player_productions = []
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
		var character_name = character["Name"].to_lower()
		if character_name == "main_hero":
			Global.main_hero_id = character["Id"]
			var player_productions = characters_productions[Global.main_hero_id]
			var filtered_player_productions = []
			for production in player_productions:
				if not "Teleportation" in production["prod"]["Title"]:
					filtered_player_productions.append(production)
			print("\n\nfifarafa", JSON.print(filtered_player_productions))
			var scene = load("res://Player.tscn")
			player = scene.instance()
			player.connect("item_picked", self, "_item_picked")
			var locationChangeArea = get_child(1).get_child(0).get_child(1)
			locationChangeArea.set_meta("id", "location_change")
			var locationChangeArea1 = get_child(9).get_child(1)
			locationChangeArea1.set_meta("id", "location_change")
			ItemDB.clean_gathered_items()
			for item in character["Items"]:
				ItemDB.gather_item(item["Name"].to_lower())
			add_child(player)
			var player_health = character["Attributes"]["HP"]
			player.max_health = player_health
			player.health = player_health
			player.productions = filtered_player_productions
#			print("player productions count ",len(player.productions))
			var character_global_position = Vector2(256, 290)
			if characters_positions.has(character_name):
				player.global_position = characters_positions[character_name]
			else:
				player.global_position = character_global_position
				characters_positions[character_name] = character_global_position
			return
		
		var path = "res://Characters/" + character_name + "/" + character_name + ".tscn"
		var fileExists = directory.file_exists(path)
		var scene
		if fileExists:
			scene = load(path)
		else:
			scene = load("res://Characters/placeholder/placeholder_character.tscn")
		var characterInstance = scene.instance()
		characterInstance.set_script(load("res://NPC.gd"))
		var character_global_position = Vector2(position_x, 290)
		if characters_positions.has(character_name):
			characterInstance.global_position = characters_positions[character_name]
		else:
			characterInstance.global_position = character_global_position
			characters_positions[character_name] = character_global_position
		position_x += 100
		add_child(characterInstance)
		characterInstance.set_productions(characters_productions[character["Id"]])

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
			var item_global_position = Vector2(position_x, 290)
			if items_positions.has(item_name):
				itemInstance.global_position = items_positions[item_name]
			else:
				itemInstance.global_position = item_global_position
				items_positions[item_name] = item_global_position
			position_x += 200
			add_child(itemInstance)
			itemInstance.set_productions(items_productions[item["Id"]])

func _item_picked(item):
	remove_child(item)

func _location_change(location_name, production, location_variant):
	hideDialogBox()
	$HTTPRequest.post_new_world(world, production, location_variant, "Main_hero")

func _production_execution(name, production, variant):
	hideDialogBox()
	$HTTPRequest.post_new_world(world, production, variant, "Main_hero")
	characters_positions["main_hero"] = player.global_position
	hideDialogBox()
	remove_child(player)
	player = null
	for child in get_children():
		if child is KinematicBody2D:
			remove_child(child)
		
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
				dialog_box.addOption(option)
#				option.rect_min_size = Vector2(20, 300)
				option.set_text(location_variant[2]["WorldNodeName"])
				option.set_variant(location_variant)
				option.set_production(location_change_production)
				option.connect("location_change", self, "_location_change")
	else:
		for production in object.get_productions():
			for variant in production["variants"]:
	#			print(production["prod"]["Title"])
				var option = load("res://DialogBox/DialogOption.tscn").instance()
				dialog_box.addOption(option)
				var personalised_desc = personalise_description(production["prod"]["Description"], variant)
#				print(personalised_desc, variant)
				option.set_text(personalised_desc)
				option.set_variant(variant)
				option.set_production(production)
				option.connect("production_execution", self, "_production_execution")
				
	dialog_box.show()
	
func hideDialogBox():
#	print("hide dialog box")
	player.is_dialog_open = false
	if dialog_box != null:
		dialog_box.hide()
		remove_child(dialog_box)
		dialog_box = null
	
func _slot_filled(slot, path):
	player._slot_filled(slot, path)

func _get_world(world):
	self.world = world.duplicate(true)
	
	var first_location = getFirstLocation(world)
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

	characters_positions = {}
	items_positions = {}
	
	current_location_id = first_location["Id"]
	add_characters(first_location["Characters"])
	if first_location.has("Items"):
		add_items(first_location["Items"])
	
	set_map_title(first_location["Name"])

func _get_productions(all_productions):
	for production in all_productions:
		if "location change" in production["prod"]["Title"].to_lower():
			location_change_production = production
	self.all_productions = all_productions

func get_productions_for_characters():
	var productions_to_return = {}
	var characterss = Global.characters
#	print(characterss, "\n")
	for production in all_productions:
		for variant in production["variants"]:
			for node in variant:
				var WorldNodeId = node["WorldNodeId"]
#				print(node["WorldNodeName"], "\n")
				if Global.is_character(WorldNodeId):
					if productions_to_return.has(WorldNodeId):
						productions_to_return[WorldNodeId].append(production)
					else:
						productions_to_return[WorldNodeId] = [production]
	return  productions_to_return

#func get_productions_only_for_player():
#	var productions_to_return = []
#	for production in player_productions:
#		var is_there_proper_value = false
#		for variant in production["variants"]:
#			for node in variant:
#				var WorldNodeId = node["WorldNodeId"]
#				if Global.main_hero_id == WorldNodeId:
#					is_there_proper_value = true
#		if is_there_proper_value == true:
#			productions_to_return.append(production)
#	return productions_to_return
	# wywalić itemy z production_to_return
	# przepisać wyciąganie produkcji dla przedmiotów tylko w lokacji, a nie te które posiadają postacie
	# ignorować wszystkie produkcje z tytułem "location change"
	# ignorowanie wszystkich produkcji z tytułem "teleportation", ale to łatwego odkomentowania

# dopisanie wyświetlania atrybutów dla przedmiotów 
# trzymać tytuły produkcji walka zakonczona smiercia gracza i jedzenie/nutrition w configu
# a dla bandytów, walka zakonczona smiercią przeciwnika(rzucą się tylko gdy maja przewage)
#sprawdzanie czy w świecie jest smok i bandyta, jak tak to postuje ze smokiem jako objectem, i wykonuję  
func get_productions_for_items():
	var productions_to_return = {}
	for production in all_productions:
		var production_and_variants = {}
		for variant in production["variants"]:
			for node in variant:
				var WorldNodeId = node["WorldNodeId"]
				if ItemDB.is_item(WorldNodeId):
					if productions_to_return.has(WorldNodeId):
						productions_to_return[WorldNodeId].append(production)
					else:
						productions_to_return[WorldNodeId] = [production]
	return  productions_to_return
	
func personalise_description(description, variant):
	var descdription_to_return = description
	var stop_pair = [
		"«", "»"
	]
	for node in variant:
		var __position = descdription_to_return.find(stop_pair[0])
		var position__ = descdription_to_return.find(stop_pair[1])
		var length = position__ - __position
		var substr = descdription_to_return.substr(__position, length + 1)
		var dasdad = descdription_to_return.substr(__position, length)
		if node["LSNodeRef"] == descdription_to_return.substr(__position + 1, length - 1):
			descdription_to_return = descdription_to_return.replace(substr, node["WorldNodeName"])
	return descdription_to_return.replace("(", "").replace(")", "")
