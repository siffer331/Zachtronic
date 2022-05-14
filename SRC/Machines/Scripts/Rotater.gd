extends WorldMachine

var value := 0


func handle() -> void:
	value = sign(other.plugs[0].value)


func interact(world: WorldManager) -> void:
	if value != 0:
		world.rotate_position(coord, value)
