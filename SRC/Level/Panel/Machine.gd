class_name Machine
extends Node2D

export var size: Vector2

func _ready() -> void:
	$Panel.rect_size = size * 50
	$Area/Col.position = size * 25
	$Area/Col.shape.extents = size*25




func _on_Area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	pass
