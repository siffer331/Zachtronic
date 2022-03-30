extends Node2D

export var coord_scale_x := 20.0
export var coord_scale_y := 17.0

var next_id := 0
var positions := {}
var cells := {}

var _cell = preload("res://SRC/Level/Cell.tscn")

func _ready() -> void:
	make_new_cell(Vector3.ZERO)
	make_new_cell(Vector3(1,-1,0))
	make_new_cell(Vector3(-1,1,0))
	make_new_cell(Vector3(1,0,-1))
	make_new_cell(Vector3(-1,0,1))
	make_new_cell(Vector3(0,1,-1))
	make_new_cell(Vector3(0,-1,1))
	move_cell(1, Vector3(1,-1,0))
	

func make_new_cell(pos: Vector3) -> int:
	var cell: Cell = _cell.instance()
	cell.position = coord_to_world(pos)
	cell.coord = pos
	add_child(cell)
	cells[next_id] = cell
	positions[pos] = next_id
	next_id += 1
	return next_id-1

func move_cell(cell_id: int, dir: Vector3) -> void:
	if not cell_id in cells:
		return
	var cell: Cell = cells[cell_id]
	positions.erase(cell.coord)
	cell.coord += dir
	positions[cell.coord] = cell
	cell.position = coord_to_world(cell.coord)

func move_position(pos: Vector3, dir: Vector3) -> void:
	if pos in cells:
		move_cell(cells[pos], dir)

func coord_to_world(pos: Vector3) -> Vector2:
	return Vector2((pos.x-pos.z)*coord_scale_x/2,pos.y*coord_scale_y)

func world_to_coord(pos: Vector2) -> Vector3:
	pos = Vector2(pos.x/coord_scale_x, pos.y/coord_scale_y)
	return Vector3(round((pos.x*2-pos.y)/2), round(pos.y), round((-pos.y-pos.x*2)/2))
