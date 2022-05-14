extends WorldMachine


func handle() -> void:
	other.plugs[3].value = min(other.plugs[0].value, min(other.plugs[1].value, other.plugs[2].value))


func reset() -> void:
	for plug in other.plugs:
		plug.value = 100
