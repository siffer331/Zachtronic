class_name WorldMachine
extends Node2D

const COORD_SCALE_X := 16
const COORD_SCALE_Y := 12

signal picked_up
signal delete

export(Array, Vector3) var shape := []
export var solid := false

var coord: Vector3
var other

func _ready() -> void:
	if solid:
		var area := Area2D.new()
		add_child(area)
		for point in shape:
			var col := CollisionShape2D.new()
			var col_shape := CircleShape2D.new()
			col_shape.radius = 5
			col.shape = col_shape
			area.add_child(col)
			col.position = coord_to_world(point)
	for point in shape:
		var control := Control.new()
		add_child(control)
		control.rect_position = Vector2(-5,-5) + coord_to_world(point)
		control.rect_size = Vector2(10,10)
		control.connect("gui_input", self, "_on_Control_gui_input")
		control.connect("mouse_entered", self, "_on_Control_mouse_entered")
		control.connect("mouse_exited", self, "_on_Control_mouse_exited")


func _calibrate() -> void:
	var start = len(get_children()) - len(shape)
	if solid:
		for i in range(len(shape)):
			var col = get_child(start+1).get_child(i)
			col.position = coord_to_world(shape[i])
	for i in range(len(shape)):
		var control = get_child(i+start)
		control.rect_position = Vector2(-5,-5) + coord_to_world(shape[i])


func rotate_machine(dir: int) -> void:
	pass


func get_output() -> void:
	pass


func handle() -> void:
	pass


func interact(world) -> void:
	pass


func reset() -> void:
	for plug in other.plugs:
		plug.value = 0


func _on_Control_gui_input(event: InputEvent) -> void:
	if event.is_action("pickup"):
		emit_signal("picked_up", self, event.is_pressed())
	if event.is_action_pressed("delete"):
		emit_signal("delete", self)


func _on_Control_mouse_entered() -> void:
	if other:
		other.modulate = Color(2,2,2)
		modulate = Color(2,2,2)


func _on_Control_mouse_exited() -> void:
	if other:
		other.modulate = Color(1,1,1)
		modulate = Color(1,1,1)


static func coord_to_world(pos: Vector3) -> Vector2:
	return Vector2((pos.x-pos.z)*COORD_SCALE_X/2,pos.y*COORD_SCALE_Y)


static func world_to_coord(pos: Vector2) -> Vector3:
	pos = Vector2(pos.x/COORD_SCALE_X, pos.y/COORD_SCALE_Y)
	var hex = Vector3(pos.x-pos.y/2, pos.y, -pos.y/2-pos.x)
	var rounded = Vector3(round(hex.x), round(hex.y), round(hex.z))
	var dif = rounded - hex
	if dif.x > max(dif.y, dif.z):
		rounded.x = - rounded.y - rounded.z
	elif dif.y > dif.z:
		rounded.y = - rounded.x - rounded.z
	else:
		rounded.z = - rounded.x - rounded.y
	return rounded


func rotate_vec(pos: Vector3, dir: int) -> Vector3:
	for i in range((dir+6)%6):
		pos = Vector3(-pos.y, -pos.z, -pos.x)
	return pos
