extends Control

signal location_change
signal production_execution

var variant
var production

func _ready():
	pass
	
func set_text(text):
	var label = get_child(0).get_child(1)
	label.text = text

func set_variant(variant):
	self.variant = variant
	
func set_production(production):
	self.production = production
	
func _on_Button_pressed():
	var label = get_child(0).get_child(1)
	var text = label.text
	emit_signal("location_change", text, production, variant)
