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

var main_character_id
var main_character_name


onready var enemies = ItemDB._get_config()["enemies"]
onready var fight_production_title = ItemDB._get_config()["fight_production_title"]

func _ready():
	$HTTPRequest.connect("get_world", self, "_get_world")
	$HTTPRequest.connect("get_productions", self, "_get_productions")
	$HTTPRequest.get_world()
	Global.camera = $Camera2D

func set_location_background(title):
	var sprite = $ParallaxBackground/ParallaxLayer/Sprite
	var map_texture_path = "res://MapsTextures/" + title.replace("'", "").to_lower() + ".png"
	var directory = Directory.new()
	if directory.file_exists(map_texture_path):
		sprite.texture = load(map_texture_path)
	else:
		sprite.texture = load("res://MapsTextures/placeholder.png")
	sprite.offset.y = -sprite.texture.get_size().y
	sprite.scale = get_viewport_rect().size / sprite.texture.get_size()
	$ParallaxBackground/ParallaxLayer.motion_mirroring.x = sprite.texture.get_size().x * sprite.scale.x
	
	var locationChangeArea = get_child(1).get_child(0).get_child(1)
	locationChangeArea.set_meta("id", "location_change")
	var locationChangeArea1 = get_child(9).get_child(1)
	locationChangeArea1.set_meta("id", "location_change")

func _process(delta):
	if Input.is_action_just_pressed("inventory_open"):
		player.load_inventory()
		
	if Input.is_action_just_pressed("map_open"):
		player.load_map()

var new_productions = {}
	
func add_characters(characters):
	var position_x = 512
	var directory = Directory.new();
	var characters_productions = new_productions
	for character in characters:
		var character_id = character["Id"]
		if character_id == main_character_id:
			Global.main_hero_id = main_character_id
			var scene = load("res://Player.tscn")
			player = scene.instance()
			player.connect("item_picked", self, "_item_picked")
			ItemDB.clean_gathered_items()
			for item in character["Items"]:
				ItemDB.gather_item(item["Name"].to_lower())
			add_child(player)
			var player_health = character["Attributes"]["HP"]
			player.max_health = player_health
			player.health = player_health
			var player_productions = characters_productions[main_character_id]
			
			player.productions = player_productions
			if characters_positions.has(main_character_id):
				print(characters_positions[main_character_id])
				player.global_position = characters_positions[main_character_id]
			else:
				var character_global_position = Vector2(256, -200)
				player.global_position = character_global_position
				characters_positions[main_character_id] = character_global_position
			return
		
		var characterInstance = get_character_model(directory, character)
		characterInstance.set_script(load("res://NPC.gd"))
		var character_global_position = Vector2(position_x, -200)
		if characters_positions.has(character_id):
			characterInstance.global_position = characters_positions[character_id]
		else:
			characterInstance.global_position = character_global_position
			characters_positions[character_id] = character_global_position
		position_x += 250
		add_child(characterInstance)
		characterInstance.set_productions(characters_productions[character["Id"]])
		
		var timer = Timer.new()
		add_child(timer)
		timer.start(2)
		timer.connect("timeout", self, "timer_cleanup", [timer])
		timer.connect("timeout", self, "execute_timer_production", [character, characters_productions, main_character_id])

func get_character_model(directory, character):
	var character_name = character["Name"]
	var path = "res://Characters/" + character_name + "/" + character_name + ".tscn"
	var fileExists = directory.file_exists(path)
	var scene
	if fileExists:
		scene = load(path)
	else:
		scene = load("res://Characters/placeholder/placeholder_character.tscn")
	return scene.instance()

func execute_timer_production(character, characters_productions, main_character_id):
	var character_name = character["Name"].to_lower()
	if character_name in enemies.keys():
		for production in characters_productions[character["Id"]]:
			var inner_production = production["production"]
			if inner_production["prod"]["Title"] == enemies[character_name]["production_title"]:
				var precondition = inner_production["prod"]["Preconditions"][0]
				var split_precondition = precondition["Cond"].split(" ")
				var left_precondition_side = split_precondition[0]
				var left_side_object_ref = left_precondition_side.split(".")[0]
				for variant in production["variants"]:
					for node in variant:
						if node["LSNodeRef"] == left_side_object_ref:
							if node["WorldNodeId"] != main_character_id:
								__production_execution(production["production"], production["variants"][0], character["Name"])

func timer_cleanup(timer):
	timer.queue_free()

func add_items(items):
	var position_x = 712
	if items != null:
		var items_productions = new_productions
		for item in items:
			var itemInstance = item_object.instance()
			var item_name = item["Name"].to_lower()
			var itemDB_item = ItemDB.get_item(item_name)
			itemInstance.set_meta("scene_name", "ItemObject")
			itemInstance.set_meta("id", item_name)
			itemInstance.get_child(2).texture = load(itemDB_item["icon"])
			var collisionShape = itemInstance.get_child(1).get_child(0)
			collisionShape.set_disabled(false)
			var item_global_position = Vector2(position_x, -540)
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

func _location_change(production, location_variant):
	characters_positions = {}
	items_positions = {}
	__production_execution(production, location_variant, "Main_hero")

func _production_execution(production, variant):
	characters_positions[main_character_id] = player.global_position
	__production_execution(production, variant, "Main_hero")

func __production_execution(production, variant, object):
	hideDialogBox()
	$HTTPRequest.post_new_world(world, production, variant, object)
	clean_scene()

func clean_scene():
	hideDialogBox()
	remove_child(player)
	player = null
	for child in get_children():
		if child is KinematicBody2D:
			remove_child(child)
		
func getFirstLocation(locations, main_location_id):
	for location in locations:
		if location["Id"] == main_location_id:
			return location

func showDialogBox(id, object):
	dialog_box = load("res://DialogBox/DialogBox.tscn").instance()
	add_child(dialog_box)
	dialog_box.set_position(Vector2(player.global_position.x, -get_viewport_rect().size.y / 2))
	if id == "location_change":
		for location_variant in location_change_production["variants"]:
			if String(location_variant[0]["WorldNodeId"]) == current_location_id:
				var option = load("res://DialogBox/DialogOption.tscn").instance()
				dialog_box.addOption(option)
				option.set_text(location_variant[2]["WorldNodeName"].replace("_", " "))
				option.set_variant(location_variant)
				option.set_production(location_change_production)
				option.connect("location_change", self, "_location_change")
	else:
		for production in object.get_productions():
			for variant in production["variants"]:
				var option = load("res://DialogBox/DialogOption.tscn").instance()
				dialog_box.addOption(option)
				var personalised_desc = personalise_description(production["production"]["prod"]["Description"], variant)
				option.set_text(personalised_desc)
				option.set_variant(variant)
				option.set_production(production)
				option.connect("production_execution", self, "_production_execution")
	dialog_box.show()

func handle_fighting_productions(productions):
	for production in productions:
		if "fight" in production["production"]["prod"]["Title"].to_lower():
			pass
			
func check_if_fighting_production(production_title):
	pass
	
func hideDialogBox():
	if player != null:
		player.is_dialog_open = false
	if dialog_box != null:
		dialog_box.hide()
		remove_child(dialog_box)
		dialog_box = null
	
func _slot_filled(slot, path):
	player._slot_filled(slot, path)

func _get_world(world, status):
	if status == "lost":
		var game_over_box = load("res://DialogBox/GameOverBox.tscn").instance()
		var center = Global.camera.get_camera_screen_center()
		add_child(game_over_box)
		print(game_over_box.global_position)
		game_over_box.global_position = center
		clean_scene()
		return
	self.world = world.duplicate(true)

func _get_productions(all_productions, location_info, main_character_id):
	self.all_productions = all_productions
	self.main_character_id = main_character_id
	new_get_productions_for_characters(all_productions, location_info)
	
	var first_location = getFirstLocation(world, location_info["main_location_id"])
	var connections_available = first_location["Connections"]
	var destination_ids = []
	for connection in connections_available:
		destination_ids.append(connection["Destination"])
		
	ItemDB.build_items_from_locations(world)
	for location in world:
		if destination_ids.has(location["Id"]):
			available_locations[location["Name"]] = location
	
	current_location_id = first_location["Id"]
	add_characters(first_location["Characters"])
	if first_location.has("Items"):
		add_items(first_location["Items"])

	set_location_background(first_location["Name"])

# wyciąganie postaci tylko w aktualnej lokacji, iterowanie po nich, przypisanie produkcji 
# do postaci, pozniej 
# wyciągnięcie produkcji location_change, na koniec podpisanie pozostałych produkcji do bohatera

func new_get_productions_for_characters(all_productions, location_info):
	var location_characters = []
	var location_items = []
	var location_id = location_info["main_location_id"]
	for location in world:
		if location["Id"] == location_id:
			location_characters = location["Characters"]
			if location.has("Items"):
				location_items = location["Items"]
			break
	
	var duped_all_productions = all_productions.duplicate(true)
	var productions_dictionary = {}
	
	for production in duped_all_productions:
		var production_title = production["prod"]["Title"].to_lower()
		if "teleportation" in production_title:
			duped_all_productions.erase(production)
			break
		
	for production in duped_all_productions:
		var production_title = production["prod"]["Title"].to_lower()
		if "location change" in production_title:
			location_change_production = production
			duped_all_productions.erase(production)
			break
	
	for production in duped_all_productions:
		for item in location_items:
			var item_productions = []
			var item_id = item["Id"]
			var production_dict = {
				"production": production,
				"variants": []
			}
			for variant in production["variants"]:
				for node in variant:
					if node["WorldNodeId"] == item_id || node["WorldNodeName"] == item_id:
						production_dict["variants"].append(variant)
			
			if production_dict["variants"] != []:
				if productions_dictionary.has(item_id):
					productions_dictionary[item_id].append(production_dict)
				else:
					productions_dictionary[item_id] = [production_dict]
	
	for character in location_characters:
		if character["Id"] == main_character_id:
			location_characters.erase(character)
			location_characters.push_back(character)
			break
		
	for production in duped_all_productions:
		for character in location_characters:
			var character_id = character["Id"]
			var production_dict = {
				"production": production,
				"variants": []
			}
			for variant in production["variants"]:
				for node in variant:
					if node["WorldNodeId"] == character_id || node["WorldNodeName"] == character_id:
						if character_id == main_character_id:
							if !check_if_more_objects_fit(production["variants"], location_characters, location_items):
								production_dict["variants"].append(variant)
						else:
							production_dict["variants"].append(variant)
							
			if production_dict["variants"] != []:
				if productions_dictionary.has(character_id):
					productions_dictionary[character_id].append(production_dict)
				else:
					productions_dictionary[character_id] = [production_dict]
	new_productions = productions_dictionary

func check_if(object_id, variants):
	for variant in variants:
		for node in variant:
			var node_id = node["WorldNodeId"]
			if object_id == node_id:
				return true
		return false

func check_if_more_objects_fit(variants, characters, items):
	var fitting_characters_count = 0
	var characters_ids = []
	for item in items:
		characters_ids.append(item["Id"])
	for character in characters:
		if character["Id"] != main_character_id:
			characters_ids.append(character["Id"])
	for variant in variants:
		for node in variant:
			var node_id = node["WorldNodeId"]
			if characters_ids.find(node_id) != -1:
				fitting_characters_count += 1
	return fitting_characters_count > 0

# personalizuje opis produkcji, zastępując placeholder między "«" a "»"
func personalise_description(description, variant):
	var description_to_return = description
	for node in variant:
		var LSNodeRef = "«" + node["LSNodeRef"] + "»"
		var WorldNodeName = node["WorldNodeName"]
		description_to_return = description_to_return.replace(LSNodeRef, WorldNodeName)
	return description_to_return.replace("(", "").replace(")", "")
