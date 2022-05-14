extends WorldMachine

var value := false

func handle() -> void:
	value = other.plugs[0].value != 0


func interact(world) -> void:
	if value:
		world.make_new_cell(coord)
