class_name Machine
extends Node2D

const GRID_SIZE = 15

export var size: Vector2
export(Array, Array) var plug_counts: Array
export var transpose_plugs: bool

signal picked_up(node, pressed)
signal delete(node)

var other
var plugs := []
var colour: Color
var data: MachineData

func _ready() -> void:
	$Panel.self_modulate = colour
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
			plug.rect_position -= Vector2(4.5,4.5)
			plugs.append(plug)


func get_plugs() -> Array:
	return $Panel.get_children()


func _on_Panel_gui_input(event: InputEvent) -> void:
	if event.is_action("pickup"):
		emit_signal("picked_up", self, event.is_pressed())
	if event.is_action_pressed("delete"):
		emit_signal("delete", self)


func _prod(a: Vector2, b: Vector2) -> Vector2:
	return Vector2(a.x*b.x, a.y*b.y)


func _on_Panel_mouse_entered() -> void:
	if other:
		other.modulate = Color(2,2,2)
		modulate = Color(2,2,2)


func _on_Panel_mouse_exited() -> void:
	if other:
		other.modulate = Color(1,1,1)
		modulate = Color(1,1,1)
