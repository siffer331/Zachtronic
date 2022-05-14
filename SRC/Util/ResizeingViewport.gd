extends ViewportContainer


func _ready() -> void:
	connect("resized", self, "_on_resized")
	for child in get_children():
		if len(child.get_children()) > 0:
			for node in child.get_child(0).get_children():
				if node is MoveableCamera:
					connect("gui_input", node, "_input", [true])
	_on_resized()


func _on_resized() -> void:
	for child in get_children():
		child.size = rect_size
