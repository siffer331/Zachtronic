extends Sprite

onready var camera = get_node("../MoveableCamera")

func _process(delta: float) -> void:
	position = camera.position.snapped(Vector2(16,24)) + Vector2(-2,-6.5)
