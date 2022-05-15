extends WorldMachine

var value := 0

func rotate_machine(dir: int) -> void:
	self.frame = (self.frame + 6 + dir) % 6


func handle() -> void:
	value = other.plugs[0].value


func interact(world: WorldManager) -> void:
	if value > 0:
		world.output_position(coord, world.dirs[self.frame])
	if value < 0:
		world.delete_position(coord, world.dirs[self.frame])

