extends Node2D

const iconPath = "res://items32px/"

var gathered_items = [ ]

var equipped_items = { }

var generated_Items = {
#	"breastplate": {
#		"icon": iconPath + "breastplate.png",
#		"slot": "CHEST"
#	},
	"error":{
		"Name": "Error",
		"icon": iconPath + "error.png",
		"slot": "NONE"
	}
}

func build_items_from_locations(locations):
	var filesList = list_files_in_directory(iconPath)
	for location in locations:
		if location.has("Characters"):
			build_items_from_characters(location["Characters"])
		if location.has("Items"):
			var items = location["Items"]
			for item in items:
				insert_item(item, filesList)

func build_items_from_characters(characters):
	Global.characters = Global.characters + characters
	var filesList = list_files_in_directory(iconPath)
	for character in characters:
		if character.has("Items"):
			var items = character["Items"]
			for item in items:
				insert_item(item, filesList)

func insert_item(item, filesList):
	item["icon"] = iconPath + "error.png"
	var found = false
	var counter = 0
	var itemName = item["Name"].to_lower()
	if !generated_Items.has(itemName):
		while !found && counter < len(filesList):
			var fileName = filesList[counter]
			if itemName in fileName:
				item["icon"] = iconPath + fileName
				found = true
			counter += 1
		var config = _get_config()
		if config.has(itemName):
			item["slot"] = config[itemName]["slot"]
		generated_Items[itemName] = item
	
func list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") && not file.ends_with("import"):
			files.append(file)

	return files
	
func get_item(item_id):
	if item_id.to_lower() in generated_Items:
		return generated_Items[item_id.to_lower()]
	else:
		return generated_Items["error"]

func remove_item_from_equipped_if_needed(item):
	if check_if_item_is_equipped(item):
		equipped_items.erase(item["slot"])

func add_item_to_equipped(item):
	if !check_if_item_is_equipped(item):
		if check_if_item_is_in_inventory(item["Name"]):
			var index = gathered_items.find(item)
			gathered_items.remove(index)
		var item_slot = item["slot"]
		equipped_items[item_slot] = item

func check_if_item_is_equipped(item):
	if item.has("slot"):
		var item_slot = item["slot"]
		if equipped_items.has(item_slot):
			var equipped_item_id = equipped_items[item_slot]["Id"]
			print("ileż można ",equipped_item_id, item["Id"], equipped_item_id == item["Id"]) 
			return equipped_item_id == item["Id"]
		else:
			return false
	else:
		return false

func clean_gathered_items():
	gathered_items.clear()

func gather_item(item_name):
	var is_in_equipped_items = false
	for key in equipped_items.keys():
		var equipped_item = equipped_items[key]
		if equipped_item["Name"].to_lower() == item_name:
			is_in_equipped_items = true
	if generated_Items.has(item_name) && !is_in_equipped_items:
		gathered_items.append(generated_Items[item_name])

func check_if_item_is_in_inventory(item_name):
	for item in gathered_items:
		if item["Name"] == item_name:
			return true
	return false
	
func _get_config():
	var loader = load("res://JSONLoader/JSONLoader.gd").new()
	return loader.load_json_file("res://config.json")

func is_item(id):
	for key in generated_Items.keys():
		var item = generated_Items[key]
		if item.has("Id"):
			if item["Id"] == id:
				return true
	return false

func check_if_item_is_owned(id):
	for gathered_item in gathered_items:
		if gathered_item["Id"] == id:
			return true
	for equipped_item in equipped_items:
		if equipped_item["Id"] == id:
			return true
	return false

