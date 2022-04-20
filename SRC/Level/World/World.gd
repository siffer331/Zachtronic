extends Node2D

signal done

export var coord_scale_x := 20.0
export var coord_scale_y := 17.0
export var timescale := 0.5

var time := 0.0
var playing := false
var next_id := 0
var positions := {}
var cells := {}
var translations := {}
var rotations := {}

var _cell = preload("res://SRC/Level/World/Cell.tscn")

func _ready() -> void:
	make_new_cell(Vector3.ZERO)
	make_new_cell(Vector3(1,-1,0))
	make_new_cell(Vector3(-1,1,0))
	make_new_cell(Vector3(1,0,-1))
	make_new_cell(Vector3(-1,0,1))
	make_new_cell(Vector3(0,1,-1))
	make_new_cell(Vector3(0,-1,1))
	join_positions(Vector3.ZERO, Vector3(1,-1,0))
	move_position(Vector3(1,-1,0), Vector3(1,-1,0))
	start()
	yield(self, "done")
	join_positions(Vector3(0,-1,1),Vector3(1,-1,0))
	move_position(Vector3(1,-1,0), Vector3(1,-1,0))
	start()
	yield(self, "done")
	rotate_position(Vector3(1,-2,1), -2)
	start()

func _process(delta: float) -> void:
	if playing:
		time += delta*timescale
		if time >= 1.0:
			time = 1.0
			playing = false
		for id in translations:
			cells[id].position = lerp(
				coord_to_world(cells[id].coord-translations[id]),
				coord_to_world(cells[id].coord),
				time
			)
		for id in rotations:
			cells[id].rotation = lerp(0, PI*rotations[id]/3, time)
		if not playing:
			for id in rotations:
				var children = cells[id].get_children()
				for i in range(len(cells[id].get_children())):
					children[i].position = coord_to_world(cells[id].cells[i])
				cells[id].rotation = 0
			translations.clear()
			rotations.clear()
			emit_signal("done")

func make_new_cell(pos: Vector3) -> int:
	var cell: Cell = _cell.instance()
	var node := Group.new()
	node.cells.append(Vector3.ZERO)
	node.add_child(cell)
	node.position = coord_to_world(pos)
	node.coord = pos
	add_child(node)
	cells[next_id] = node
	positions[pos] = next_id
	next_id += 1
	return next_id-1

func move_cell(cell_id: int, dir: Vector3) -> void:
	if not cell_id in cells:
		return
	var cell: Group = cells[cell_id]
	for pos in cell.cells:
		positions.erase(cell.coord+pos)
	cell.coord += dir
	for pos in cell.cells:
		positions[cell.coord+pos] = cell_id
	translations[cell_id] = dir

func move_position(pos: Vector3, dir: Vector3) -> void:
	if pos in positions:
		move_cell(positions[pos], dir)

func rotate_position(pos: Vector3, dir: int) -> void:
	if pos in positions:
		var cell_id = positions[pos]
		var cell: Group = cells[cell_id]
		for coord in cell.cells:
			positions.erase(cell.coord+coord)
		for child in cell.get_children():
			child.position -= coord_to_world(pos-cell.coord)
		for i in range(len(cell.cells)):
			cell.cells[i] -= pos-cell.coord
			cell.cells[i] = rotate_around(cell.cells[i], Vector3.ZERO, dir)
			positions[pos+cell.cells[i]] = cell_id
		cell.coord = pos
		cell.position = coord_to_world(pos)
		rotations[cell_id] = dir

func join_cells(cell_id_a: int, cell_id_b: int) -> void:
	if cell_id_a != cell_id_b:
		var cell_a: Group = cells[cell_id_a]
		var cell_b: Group = cells[cell_id_b]
		for pos in cells[cell_id_b].cells:
			cell_a.cells.append(pos + cell_b.coord - cell_a.coord)
			positions[pos + cell_b.coord] = cell_id_a
		for child in cell_b.get_children():
			var pos = child.global_position
			cell_b.remove_child(child)
			cell_a.add_child(child)
			child.global_position = pos
		clear_cell(cell_id_b)


func clear_cell(cell_id: int) -> void:
	if not cell_id in cells:
		return
	cells[cell_id].queue_free()
	cells.erase(cell_id)


func join_positions(pos_a: Vector3, pos_b: Vector3) -> void:
	if pos_a in positions and pos_b in positions:
		join_cells(positions[pos_a], positions[pos_b])

func start() -> void:
	time = 0.0
	playing = true

func coord_to_world(pos: Vector3) -> Vector2:
	return Vector2((pos.x-pos.z)*coord_scale_x/2,pos.y*coord_scale_y)

func world_to_coord(pos: Vector2) -> Vector3:
	pos = Vector2(pos.x/coord_scale_x, pos.y/coord_scale_y)
	return Vector3(round((pos.x*2-pos.y)/2), round(pos.y), round((-pos.y-pos.x*2)/2))

func rotate_around(pos1: Vector3, pos2: Vector3, dir: int) -> Vector3:
	var dif := pos1 - pos2
	for i in range((dir+6)%6):
		dif = Vector3(-dif.y, -dif.z, -dif.x)
	return pos2 + dif



