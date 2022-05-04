class_name Machine
extends Node2D

const GRID_SIZE = 40

export var size: Vector2
export(Array, Array) var plug_counts: Array
export var transpose_plugs: bool

signal picked_up(node, pressed)

var plugs := []

func _ready() -> void:
	$Panel.rect_size = size * GRID_SIZE
	for i in range(len(plug_counts)):
		var ar = plug_counts[i]
		for j in range(len(ar)):
			var plug := Plug.new()
			plug.type = ar[j]
			$Panel.add_child(plug)
			if transpose_plugs:
				plug.rect_position = Vector2((i+.5)/len(plug_counts)*size.x, (j+.5)/len(ar)*size.y)*GRID_SIZE
			else:
				plug.rect_position = Vector2((j+.5)/len(ar)*size.x, (i+.5)/len(plug_counts)*size.y)*GRID_SIZE
			plug.rect_position -= Vector2(10,10)

func get_plugs() -> Array:
	return $Panel.get_children()

func _on_Panel_gui_input(event: InputEvent) -> void:
	if event.is_action("pickup"):
		emit_signal("picked_up", self, event.is_pressed())


