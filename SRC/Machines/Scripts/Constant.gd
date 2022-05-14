extends WorldMachine


func get_output() -> void:
	other.plugs[0].value = $Num.value
