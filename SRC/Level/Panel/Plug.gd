class_name Plug
extends TextureRect

signal dragged
signal dropped

enum TYPE {IN, OUT}
export(TYPE) var type: int

var value := 0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	if type == TYPE.IN:
		texture = load("res://Assets/PlugIn.png")
	else:
		texture = load("res://Assets/PlugOut.png")
	rect_size = Vector2(1,1)


func get_position() -> Vector2:
	var res = rect_position + Vector2(5,5)
	var node = get_parent()
	while node is Control:
		res += node.rect_position
		node = node.get_parent()
	return res + node.global_position


func drop_data(position: Vector2, data) -> void:
	emit_signal("dropped", self)


func can_drop_data(position: Vector2, data) -> bool:
	return data == "Plug"


func get_drag_data(position: Vector2) -> String:
	emit_signal("dragged", self)
	return "Plug"
