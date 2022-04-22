extends Node2D


const iconPath = "res://items32px/"

#const itemss = {
#	"sword": {
#		"icon": iconPath + "sword_of_lumberjack.png",
#		"slot": "MAIN_HAND"
#	},
#	"axe": {
#		"icon": iconPath + "axe.png",
#		"slot": "MAIN_HAND"
#	},
#	"breastplate": {
#		"icon": iconPath + "breastplate.png",
#		"slot": "CHEST"
#	},
#	"torch": {
#		"icon": iconPath + "torch.png",
#		"slot": "OFF_HAND"
#	},
#	"coin": {
#		"icon": iconPath + "coin.png",
#		"slot": "NONE"
#	},
#	"coins1": {
#		"icon": iconPath + "coins1.png",
#		"slot": "NONE"
#	},
#	"coins2": {
#		"icon": iconPath + "coins2.png",
#		"slot": "NONE"
#	},
#	"coins3": {
#		"icon": iconPath + "coins3.png",
#		"slot": "NONE"
#	},
#	"coins4": {
#		"icon": iconPath + "coins4.png",
#		"slot": "NONE"
#	},
#	"coins5": {
#		"icon": iconPath + "coins5.png",
#		"slot": "NONE"
#	},
#	"egg": {
#		"icon": iconPath + "egg.png",
#		"slot": "NONE"
#	},
#	"eggs": {
#		"icon": iconPath + "eggs.png",
#		"slot": "NONE"
#	},
#	"eggs2": {
#		"icon": iconPath + "eggs2.png",
#		"slot": "NONE"
#	},
#	"elixir_blue": {
#		"icon": iconPath + "elixir_blue.png",
#		"slot": "NONE"
#	},
#	"dragon_egg": {
#		"icon": iconPath + "dragon_egg.png",
#		"slot": "NONE"
#	},
#	"herbs_blue": {
#		"icon": iconPath + "herbs_blue.png",
#		"slot": "NONE"
#	},
#	"herbs_yellow": {
#		"icon": iconPath + "herbs_yellow.png",
#		"slot": "NONE"
#	},
#	"error":{
#		"icon": iconPath + "error.png",
#		"slot": "NONE"
#	}
#}

var generated_Items = {
	"error":{
		"icon": iconPath + "error.png",
		"slot": "NONE"
	}
}

func build_items(locations):
	var filesList = list_files_in_directory("res://items32px")
	for location in locations:
		if location.has("Items"):
			var items = location["Items"]
			for item in items:
				insert_item(item, filesList)

func insert_item(item, filesList):
	item["icon"] = iconPath + "error.png"
	var found = false
	var counter = 0
	while !found && counter < len(filesList):
		var fileName = filesList[counter]
		if item["Name"].to_lower() in fileName:
			item["icon"] = iconPath + fileName
			found = true
		counter += 1 
	generated_Items[item["Name"].to_lower()] = item
	
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
	if item_id in generated_Items:
		return generated_Items[item_id]
	else:
		return generated_Items["error"]
