extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var image = Image.new()
	image.load("res://Map/map.png")
	image.resize(1400, 900)
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	$TextureRect.texture = texture
