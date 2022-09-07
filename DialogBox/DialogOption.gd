extends NinePatchRect

signal location_change
signal production_execution

var variant
var production

onready var label = $Label

func _ready():
	label.set_autowrap(true)
	
func set_text(text):
	label.text = text

func set_variant(variant):
	self.variant = variant
	
func set_production(production):
	self.production = production
	
func _on_Button_pressed():
	var text = label.text
	emit_signal("location_change", production, variant)
	emit_signal("production_execution", production, variant)
