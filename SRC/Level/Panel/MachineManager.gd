class_name MachineManager
extends Node2D

export var space: Vector2
export var offset: Vector2
export var grabing_colour: Color
export var invalid_colour: Color

var holding: Machine
var grap_offset: Vector2
var holding_start_coord: Vector2

var used_space := []


func _ready() -> void:
	for i in range(int(space.x)):
		used_space.append([])
		for j in range(int(space.y)):
			used_space[i].append(false)
	for machine in get_children():
		if machine is Machine:
			readyMachine(machine)


func _process(delta: float) -> void:
	if holding:
		var mouse_coord = _contain(_get_coord(get_local_mouse_position()+grap_offset), holding.size)
		if _get_coord(holding.position) !=  mouse_coord:
			if is_space_used(mouse_coord, holding.size):
				holding.modulate = invalid_colour
			else:
				holding.modulate = grabing_colour
		holding.position = offset + mouse_coord*Machine.GRID_SIZE


func readyMachine(machine: Machine) -> void:
	machine.position = offset + _get_coord(machine.position)*Machine.GRID_SIZE
	machine.connect("picked_up", self, "_on_Machine_picked_up")
	set_machine_space(machine, true)


func _on_Machine_picked_up(machine: Machine, pressed: bool) -> void:
	if pressed:
		holding = machine
		holding_start_coord = _get_coord(machine.position)
		grap_offset = machine.position - get_local_mouse_position()
		holding.modulate = grabing_colour
		set_machine_space(holding, false)
	else:
		if is_space_used(_get_coord(holding.position), holding.size):
			holding.position = holding_start_coord*Machine.GRID_SIZE + offset
		set_machine_space(machine, true)
		holding.modulate = Color.white
		holding = null


func set_machine_space(machine: Machine, value: bool) -> void:
	var pos = _get_coord(machine.position)
	for i in range(int(machine.size.x)):
		for j in range(int(machine.size.y)):
			used_space[int(pos.x)+i][int(pos.y)+j] = value


func is_space_used(coord: Vector2, size: Vector2) -> bool:
	for i in range(int(size.x)):
		for j in range(int(size.y)):
			if used_space[int(coord.x)+i][int(coord.y)+j]:
				return true
	return false


func _contain(coord: Vector2, size: Vector2) -> Vector2:
	return Vector2(min(max(coord.x, 0), space.x-size.x), min(max(coord.y, 0), space.y-size.y))


func _get_coord(val: Vector2) -> Vector2:
	return (val-offset).snapped(Vector2.ONE*Machine.GRID_SIZE)/Machine.GRID_SIZE
