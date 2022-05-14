extends WorldMachine


func handle() -> void:
	other.plugs[1].value = other.plugs[0].value
	other.plugs[2].value = other.plugs[0].value
	other.plugs[3].value = other.plugs[0].value
