class_name WorldManager
extends Node2D

signal done
signal error(message)
signal output(shape, values, cell_id)

export var grabing_colour: Color
export var invalid_colour: Color
export var timescale := 0.5

var time := 0.0
var playing := false
var next_id := 0
var positions := {}
var cells := {}
var translations := {}
var rotations := {}
var machines := {}
var speed := 1.0
var start := Vector2.ZERO
var changes := [[],[]]
var locked := false

var dragging: WorldMachine = null
var dragging_from := Vector3.ZERO
var _cell = preload("res://SRC/Level/World/Cell.tscn")
var dirs := [Vector3(1,-1,0),Vector3(1,0,-1),Vector3(0,1,-1),Vector3(-1,1,0),Vector3(-1,0,1),Vector3(0,-1,1)]


func _process(delta: float) -> void:
	if playing:
		time += delta*timescale
		if time >= 1.0:
			time = 1.0
			playing = false
		for id in translations:
			cells[id].position = lerp(
				WorldMachine.coord_to_world(cells[id].coord-translations[id]),
				WorldMachine.coord_to_world(cells[id].coord),
				time
			)
		for id in rotations:
			cells[id].rotation = lerp(0, PI*rotations[id]/3, time)
		if not playing:
			for id in rotations:
				for coord in cells[id].cells:
					cells[id].cells[coord].position = WorldMachine.coord_to_world(coord)
				cells[id].rotation = 0
			translations.clear()
			rotations.clear()
			emit_signal("done")
	if dragging:
		var coord := WorldMachine.world_to_coord(_get_mouse())
		dragging.position = WorldMachine.coord_to_world(coord)
		dragging.coord = coord
		if _is_free(coord, dragging.shape):
			dragging.modulate = grabing_colour
		else:
			dragging.modulate = invalid_colour


func _input(event: InputEvent) -> void:
	if dragging:
		if event.is_action_pressed("scroll_down"):
			dragging.rotate_machine(1)
		if event.is_action_pressed("scroll_up"):
			dragging.rotate_machine(-1)


func make_input(shape: Array, value: Array) -> void:
	for i in range(len(shape)):
		if shape[i] in positions:
			make_error("Cant place input.")
			return
		make_new_cell(shape[i], value[i])


func make_error(msg: String):
	playing = false
	emit_signal("error", msg)


func get_cell(pos: Vector3) -> Cell:
	if pos in positions:
		return cells[positions[pos]].cells[pos-cells[positions[pos]].coord]
	return null


func place_machine(data: MachineData) -> WorldMachine:
	var coord := _get_free_spot(data.shape)
	var scene := "res://SRC/Machines/BasicMachine.tscn"
	if data.scene != "":
		scene = data.scene
	var machine = load(scene).instance()
	machine.connect("picked_up", self, "_on_Machine_picked_up")
	machine.position = WorldMachine.coord_to_world(coord)
	machine.shape = data.shape
	machine.coord = coord
	machine.solid = data.solid
	add_child(machine)
	for p in data.shape:
		machines[coord+p] = machine
	return machine


func delete_machine(machine: WorldMachine) -> void:
	for point in machine.shape:
		machines.erase(machine.coord + point)
	machine.queue_free()


func _get_free_spot(shape: Array) -> Vector3:
	var coord = WorldMachine.world_to_coord($MoveableCamera.position)
	if _is_free(coord, shape):
		return coord
	var r := 1
	while true:
		coord += dirs[4]
		for i in range(6):
			for j in range(r):
				if _is_free(coord, shape):
					return coord
				coord += dirs[i]
		r += 1
	return Vector3.ZERO


func _is_free(coord: Vector3, shape: Array) -> bool:
	for p in shape:
		if coord + p in machines:
			return false
	return true


func make_new_cell(pos: Vector3, value := 0) -> int:
	if pos in positions:
		return -1
	var cell: Cell = _cell.instance()
	cell.connect("collided", self, "_on_cell_collided")
	var node := Group.new()
	node.cells[Vector3.ZERO] = cell
	node.add_child(cell)
	node.position = WorldMachine.coord_to_world(pos)
	node.coord = pos
	add_child(node)
	cell.value = value
	cells[next_id] = node
	positions[pos] = next_id
	next_id += 1
	return next_id-1


func move_cell(cell_id: int, dir: Vector3) -> void:
	if not cell_id in cells or cell_id in translations or cell_id in rotations:
		return
	var cell: Group = cells[cell_id]
	for pos in cell.cells:
		changes[0].append(cell.coord+pos)
	cell.coord += dir
	for pos in cell.cells:
		changes[1].append([cell.coord+pos, cell_id])
	translations[cell_id] = dir


func move_position(pos: Vector3, dir: Vector3) -> void:
	if pos in positions:
		move_cell(positions[pos], dir)


func rotate_position(pos: Vector3, dir: int) -> void:
	if pos in positions:
		var cell_id = positions[pos]
		if cell_id in translations or cell_id in rotations:
			return
		var cell: Group = cells[cell_id]
		var new_cells := {}
		for coord in cell.cells:
			changes[0].append(cell.coord+coord)
			var child = cell.cells[coord]
			child.position -= WorldMachine.coord_to_world(pos-cell.coord)
			
			var new_coord = rotate_around(coord - pos + cell.coord, Vector3.ZERO, dir)
			new_cells[new_coord] = cell.cells[coord]
			changes[1].append([pos+new_coord, cell_id])
		cell.cells = new_cells
		cell.coord = pos
		cell.position = WorldMachine.coord_to_world(pos)
		rotations[cell_id] = dir


func join_cells(cell_id_a: int, cell_id_b: int) -> void:
	if cell_id_a != cell_id_b:
		var cell_a: Group = cells[cell_id_a]
		var cell_b: Group = cells[cell_id_b]
		for pos in cell_b.cells:
			var child = cell_b.cells[pos]
			cell_a.cells[pos + cell_b.coord - cell_a.coord] = child
			positions[pos + cell_b.coord] = cell_id_a
			var child_pos = child.global_position
			cell_b.remove_child(child)
			cell_a.add_child(child)
			child.global_position = child_pos
		clear_cell(cell_id_b)


func output_position(coord: Vector3) -> void:
	if coord in positions:
		var shape := []
		var values := []
		var group: Group = cells[positions[coord]]
		for pos in group.cells:
			shape.append(pos)
			values.append(group.cells[pos].value)
		emit_signal("output", shape, values, positions[coord])


func clear_cell(cell_id: int) -> void:
	if not cell_id in cells:
		return
	for coord in cells[cell_id].cells:
		positions.erase(coord + cells[cell_id].coord)
	cells[cell_id].queue_free()
	cells.erase(cell_id)


func delete_position(coord: Vector3) -> void:
	if coord in positions:
		clear_cell(positions[coord])


func join_positions(pos_a: Vector3, pos_b: Vector3) -> void:
	if pos_a in positions and pos_b in positions:
		join_cells(positions[pos_a], positions[pos_b])


func start() -> void:
	for pos in changes[0]:
		positions.erase(pos)
	for ar in changes[1]:
		positions[ar[0]] = ar[1]
	changes = [[],[]]
	time = 0.0
	playing = true


func stop() -> void:
	time = 0.0
	playing = false
	for id in cells:
		cells[id].queue_free()
	cells.clear()
	positions.clear()
	translations.clear()
	rotations.clear()


func rotate_around(pos1: Vector3, pos2: Vector3, dir: int) -> Vector3:
	var dif := pos1 - pos2
	for i in range((dir+6)%6):
		dif = Vector3(-dif.y, -dif.z, -dif.x)
	return pos2 + dif


func _on_Machine_picked_up(machine: WorldMachine, pressed: bool) -> void:
	if pressed:
		if locked:
			return
		_init_mouse(machine.position)
		for point in machine.shape:
			machines.erase(machine.coord + point)
		dragging = machine
		dragging.modulate = grabing_colour
		dragging_from = machine.coord
	else:
		if not _is_free(machine.coord, machine.shape):
			machine.coord = dragging_from
		machine.position = WorldMachine.coord_to_world(machine.coord)
		for point in machine.shape:
			machines[machine.coord + point] = machine
			dragging = null


func _on_cell_collided() -> void:
	make_error("Cells collided.")


func get_point_on_line(from: Vector3, dir: Vector3) -> Vector3:
	var best := from
	var score = 2000000
	for pos in positions:
		var d = _is_on_line(pos, from, dir)
		if d > 0 and d < score:
			score = d
			best = pos
	return best


func _is_on_line(point: Vector3, from: Vector3, dir: Vector3) -> int:
	var dif := point - from
	if abs(dir.x) > 0:
		if sign(dif.x) != sign(dir.x):
			return -1
		if dif == dir*(dif.x/dir.x):
			return int(abs(dif.x))
	else:
		if sign(dif.y) != sign(dir.y):
			return -1
		if dif == dir*(dif.y/dir.y):
			return int(abs(dif.y))
	return -1


func _init_mouse(var from: Vector2 = Vector2.ZERO) -> void:
	speed = 512/get_viewport().get_parent().get_viewport().size.x
	start = get_viewport().get_mouse_position()*speed - from


func _get_mouse() -> Vector2:
	return get_viewport().get_mouse_position()*speed - start


func compare_shapes(shape_a: Array, values_a: Array, shape_b: Array, values_b: Array) -> bool:
	shape_a = shape_a.duplicate(true)
	shape_b = shape_b.duplicate(true)
	values_a = values_a.duplicate(true)
	values_b = values_b.duplicate(true)
	if len(shape_a) != len(shape_b):
		return false
	var best_b: Vector3 = shape_b[0]
	for shape in shape_b:
		best_b.x = min(shape.x, best_b.x)
		best_b.y = min(shape.y, best_b.y)
	for j in range(len(shape_b)):
		shape_b[j] -= best_b
	for i in range(6):
		var best: Vector3 = shape_a[0]
		for shape in shape_a:
			best.x = min(shape.x, best.x)
			best.y = min(shape.y, best.y)
		var found := {}
		for j in range(len(shape_a)):
			shape_a[j] -= best
			found[shape_a[j]] = values_a[j]
		var b := true
		for j in range(len(shape_b)):
			if not shape_b[j] in found or (found[shape_b[j]] != values_b[j] and max(found[shape_b[j]], values_b[j]) != 100):
				b = false
				break
		if b:
			return true
		if i != 5:
			for j in range(len(shape_a)):
				shape_a[j] = rotate_around(shape_a[j], Vector3.ZERO, 1)
	return false
