extends Node2D

var player

const item_object = preload("res://ItemObject.tscn")

func _ready():
	var scene = load("res://Player.tscn")
	player = scene.instance()
	player.connect("item_picked", self, "_item_picked")
	add_child(player)
	set_map_title(Global.current_location)
	add_characters(Global.characters)
	add_items(Global.location_items)

func set_map_title(title):
	var static_body = get_child(1)
	var sprite = get_child(0).get_child(0).get_child(0)
	var map_texture_path = "res://MapsTextures/" + title.replace("'", "").to_lower() + ".png"
	var directory = Directory.new()
	if directory.file_exists(map_texture_path):
		sprite.texture = load(map_texture_path)
	else:
		sprite.texture = load("res://MapsTextures/placeholder.png")
	sprite.global_position.y = 230
	static_body.global_position.y = 230

func _process(delta):
	if Input.is_action_just_pressed("inventory_open"):
		var inventory = load("res://InventoryUI.tscn").instance()
		var inventory_position = player.global_position
		inventory_position.y -= 300
		inventory.rect_position = inventory_position
		add_child(inventory)
		
	if Input.is_action_just_pressed("map_open"):
		var map = load("res://Map/Map.tscn").instance()
		add_child(map)
		
func add_characters(characters):
	var position_x = 512
	var directory = Directory.new();
	
	for character in characters:
		var path = "res://Characters/" + character["Name"].to_lower() + "/" + character["Name"].to_lower() + ".tscn"
		var fileExists = directory.file_exists(path)
		var scene
		if fileExists:
			scene = load(path)
		else:
			scene = load("res://Characters/placeholder/placeholder_character.tscn")
		var characterInstance = scene.instance()
		var script = load("res://NPC.gd")
		characterInstance.set_script(script)
		characterInstance.global_position = Vector2(position_x, 290)
		position_x += 100
		add_child(characterInstance)

func add_items(items):
	var position_x = 712
	if items != null:
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
			itemInstance.global_position = Vector2(position_x, 290)
			position_x += 200
			add_child(itemInstance)

func _item_picked(item):
	remove_child(item)
