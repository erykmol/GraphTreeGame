extends HTTPRequest

signal get_world
signal get_productions

func _ready():
	pass

func get_world():
	# Create an HTTP request node and connect its completion signal.
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_http_request_completed")

	var error = http_request.request("http://127.0.0.1:8000/getWorld")
	if error != OK:
		push_error("An error occurred in the HTTP request.")


func post_new_world(world, production, variant, object):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_http_request_completed")
	var body = JSON.print({"world": world, "production": production["prod"], "variant": variant, "object": object})
	var headers = ["Content-Type: application/json"]
	var error = http_request.request("http://127.0.0.1:8000/postNewWorld", headers, false, HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("An error occurred in the HTTP request.")


func get_map(world):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_get_map_http_request_completed")
	var body = JSON.print({"whole": world})
#	print(body)
	var headers = ["Content-Type: application/json"]
	var error = http_request.request("http://127.0.0.1:8000/generateMap", headers, false, HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	var response = parse_json(body.get_string_from_utf8())
	var world = response["world"]
#	print("world: ",response["available_productions"])
	get_map(world)
	emit_signal("get_productions", response["available_productions"])
	emit_signal("get_world", world)

func _get_map_http_request_completed(result, response_code, headers, body):
	var image = Image.new()
	var image_error = image.load_png_from_buffer(body)
	if image_error != OK:
		print("An error occurred while trying to display the image.")
	image.save_png("res://Map/map.png")
