extends Panel

export var world_path: NodePath
export var manager_path: NodePath
var manager: MachineManager
var world: WorldManager
var playing: bool setget _set_playing
var level_index := 0
var error := false

func _ready() -> void:
	manager = get_node(manager_path)
	world = get_node(world_path)
	var dir := Directory.new()
	var path := "res://Data/"
	dir.open(path)
	dir.list_dir_begin()
	var file = dir.get_next()
	var files = []
	while file != "":
		if file[0] != '.':
			files.append(path + file)
		file = dir.get_next()
	dir.list_dir_end()
	
	var resource = load("res://SRC/Level/UI/Machine.tscn")
	
	for data in files:
		var ui = resource.instance()
		ui.data = load(data)
		$Margin/Split/Split/Tools/Scroll/Split.add_child(ui)
		ui.connect("placed", self, "_on_MachineUI_placed")
	_make_input(0)


func _on_MachineUI_placed(data: MachineData) -> void:
	if playing:
		return
	var world_machine := world.place_machine(data)
	var machine := manager.make_machine(data)
	machine.other = world_machine
	world_machine.other = machine
	machine.connect("delete", self, "_on_Machine_delete")
	world_machine.connect("delete", self, "_on_WorldMachine_delete")


func _on_Machine_delete(machine: Machine) -> void:
	world.delete_machine(machine.other)
	manager.delete_machine(machine)


func _on_WorldMachine_delete(machine: WorldMachine) -> void:
	manager.delete_machine(machine.other)
	world.delete_machine(machine)


func _on_Play_pressed() -> void:
	if not playing:
		var errors = manager.get_errors()
		if len(errors) > 0:
			for wire in errors:
				$Tween.interpolate_property(wire, "modulate", Color(8,.5,.5), Color(1,1,1), 5, Tween.TRANS_EXPO, Tween.EASE_IN)
			$Tween.start()
		else:
			level_index = 0
			error = false
			self.playing = true
			world.stop()
			_make_input(0)
			_on_World_done()
	else:
		self.playing = false
		world.stop()
		_make_input(0)


func _make_input(index: int) -> void:
	world.make_input(GM.level.input_shape, GM.level.input_values[index])


func _set_playing(val: bool) -> void:
	playing = val
	world.locked = val
	manager.locked = val
	var button = $Margin/Split/Split/Play/Margin/Split/Play
	if not playing:
		button.texture_normal = load("res://Assets/UI/PlayPause1.png")
		button.texture_hover = load("res://Assets/UI/PlayPause2.png")
		button.texture_pressed = load("res://Assets/UI/PlayPause3.png")
	else:
		button.texture_normal = load("res://Assets/UI/PlayPause4.png")
		button.texture_hover = load("res://Assets/UI/PlayPause5.png")
		button.texture_pressed = load("res://Assets/UI/PlayPause6.png")


func _on_World_done() -> void:
	if error:
		return
	manager.handle_calculations()
	manager.interact(world)
	world.start()


func _on_World_error(message: String) -> void:
	if playing:
		$Popup/Panel/Center/Label.text = "Error:\n" + message
		$Popup.popup()


func _on_Slider_value_changed(value: float) -> void:
	world.timescale = value


func _on_Task_pressed() -> void:
	$Popup/Panel/Center/Label.text = GM.level.task
	$Popup.popup()


func _on_World_output(shape: Array, values: Array, cell_id: int) -> void:
	if world.compare_shapes(shape, values, GM.level.output_shapes[level_index], GM.level.output_values[level_index]):
		level_index += 1
		print("k ", level_index)
		if level_index == len(GM.level.input_values):
			error = true
			$Popup/Panel/Center/Label.text = "You win the level!"
			$Popup.popup()
		else:
			world.clear_cell(cell_id)
			_make_input(level_index)
	else:
		error = true
		_on_World_error("Wrong output")
