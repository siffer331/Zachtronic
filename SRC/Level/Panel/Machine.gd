class_name Machine
extends Node2D

export var size: Vector2

signal picked_up(node)

func _ready() -> void:
	$Panel.rect_size = size * 50
	$Area/Col.position = size * 25
	$Area/Col.shape.extents = size*25


func _on_Area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	print("k")
	if event.is_action("pickup"):
		emit_signal("picked_up", self)


func _on_Area_mouse_entered() -> void:
	print("l")
