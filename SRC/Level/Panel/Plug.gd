class_name Plug
extends TextureRect

signal grabbed

enum TYPE {IN, OUT}
export(TYPE) var type: int


func _ready() -> void:
	connect("gui_input", self, "_on_gui_input")
	mouse_filter = Control.MOUSE_FILTER_STOP
	if type == TYPE.IN:
		texture = load("res://Assets/PlugIn.png")
	else:
		texture = load("res://Assets/PlugOut.png")
	rect_size = Vector2(20,20)


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action("pickup"):
		print("k")
		emit_signal("grabbed", self, event.is_pressed())
