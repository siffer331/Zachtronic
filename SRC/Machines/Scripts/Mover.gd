extends WorldMachine

var value := false


func rotate_machine(dir: int) -> void:
	self.frame = (self.frame + 6 + dir) % 6


func handle() -> void:
	value = other.plugs[0].value != 0


func interact(world: WorldManager) -> void:
	if value:
		world.move_position(world.get_point_on_line(coord, world.dirs[self.frame]), world.dirs[self.frame])
