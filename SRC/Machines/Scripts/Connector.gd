extends WorldMachine

var sprite_pos := [Vector2(8,6), Vector2(8,6), Vector2(0,6), Vector2(-8,6), Vector2(0,-6), Vector2(8,-6)]
var rot := 0
var value := false

func rotate_machine(dir: int) -> void:
	rot = (rot + 6 + dir) % 6
	$Sprite.frame = rot % 3
	$Sprite.position = sprite_pos[rot]
	shape[1] = rotate_vec(shape[1], dir)
	_calibrate()


func handle() -> void:
	value = other.plugs[0].value != 0


func interact(world: WorldManager) -> void:
	if value:
		world.join_positions(coord, coord + world.dirs[(rot+1)%6])
