extends WorldMachine

var value := 0

func handle() -> void:
	value = other.plugs[0].value


func get_output() -> void:
	var cell = get_parent().get_cell(coord)
	other.plugs[2].value = 0
	if cell:
		other.plugs[1].value = cell.value
		other.plugs[2].value = 1


func reset() -> void:
	other.plugs[0].value = 100


func interact(world: WorldManager) -> void:
	var cell := world.get_cell(coord)
	if cell and value != 100:
		cell.value = value
