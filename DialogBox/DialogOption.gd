extends NinePatchRect

signal location_change
signal production_execution

var variant
var production
var fighting_productions = []
var characterId

onready var label = $Label

func _ready():
	label.set_autowrap(true)
	
func set_text(text):
	label.text = text

func set_variant(variant):
	self.variant = variant
	
func set_production(production):
	self.production = production

func set_fight_productions(productions, characterId):
	fighting_productions = productions
	self.characterId = characterId
	
func _on_Button_pressed():
	var text = label.text
	var production_to_execute = production
	var variant_to_execute = variant
	if fighting_productions != []:
		if len(fighting_productions) == 1:
			var only_production = fighting_productions[0]
			var variants = only_production["production"]["variants"]
			var variants_count = len(variants)
			var nums = []
			for i in variants_count:
				for node in variants[i]:
						if node["WorldNodeName"] == characterId:
							nums.append(i)
			var variant_index = nums[randi() % nums.size()]
			production_to_execute = only_production["production"]
			variant_to_execute = variants[variant_index]
		else:
			var percent = randf()
			if (percent > 0.7):
				var ending_with_death_production
				for production in fighting_productions:
					if "death" in production["production"]["prod"]["Title"].to_lower():
						ending_with_death_production = production
				var variants = ending_with_death_production["production"]["variants"]
				var variants_count = len(variants)
				var nums = []
				for i in variants_count:
					for node in variants[i]:
						print("WorldNodeName fight", node["WorldNodeName"], " ", node["WorldNodeName"] == characterId)
						if node["WorldNodeName"] == characterId:
							nums.append(i)
				var nums_size = nums.size()
				randomize()
				prints(randi(), nums_size)
				var chosen_index = randi() % nums.size()
				var variant_index = nums[chosen_index]
				production_to_execute = ending_with_death_production["production"]
				variant_to_execute = variants[variant_index]
			else:
				var ending_with_escape_production
				for production in fighting_productions:
					if production["production"]["prod"]["Title"].to_lower().find("death") == -1:
						ending_with_escape_production = production
				var variants = ending_with_escape_production["production"]["variants"]
				var variants_count = len(variants)
				var nums = []
				for i in variants_count:
					for node in variants[i]:
						if node["WorldNodeName"] == characterId:
							nums.append(i)
				var variant_index = nums[randi() % nums.size()]
				production_to_execute = ending_with_escape_production["production"]
				variant_to_execute = variants[variant_index]
	emit_signal("location_change", production_to_execute, variant_to_execute)
	emit_signal("production_execution", production_to_execute, variant_to_execute)
