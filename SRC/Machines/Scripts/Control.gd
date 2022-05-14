extends WorldMachine


func handle() -> void:
	other.plugs[2].value = 0
	if other.plugs[1].value != 0:
		other.plugs[2].value = other.plugs[0].value
