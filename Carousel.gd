extends ScrollContainer

#const BUFFER = 10 #not necessity but preference; could be removed or set to 0
#var scroll_size = 0
#const SCROLL_DELAY = 200
#onready var last_scroll = OS.get_ticks_msec()
#onready var box = get_node("HBoxContainer")
#onready var box_children = box.get_child_count() - 1
#onready var size_y = get_rect().size.x
#
#func _ready():
#	get_h_scrollbar().connect("scrolling", self, "process_scroll")
#	pass
#
#func process_scroll():
#	if last_scroll < OS.get_ticks_msec() - SCROLL_DELAY:
#		last_scroll = OS.get_ticks_msec()
#		check_loop()
#
#func check_loop():
#	var scroll_size = get_h_scrollbar().max_value #not ideal to check each time, but always returns 100 when in _ready()
#	if scroll_vertical + size_y >= scroll_size - BUFFER:
#		box.move_child(box.get_child(0), box_children)
#	elif scroll_vertical <= BUFFER:
#		box.move_child(box.get_child(box_children), 0)
