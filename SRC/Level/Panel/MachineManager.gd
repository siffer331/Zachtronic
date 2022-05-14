class_name MachineManager
extends Node2D

export var grabing_colour: Color
export var invalid_colour: Color

var holding: Machine
var holding_start_coord: Vector2
var wires := {}
var used_space := {}
var dragging: Wire
var speed := 1.0
var start: Vector2
var visited = {}
var machines := {}
var locked := false

func _ready() -> void:
	for machine in get_children():
		if machine is Machine:
			ready_machine(machine)


func _process(delta: float) -> void:
	if holding:
		var mouse_coord = _get_coord(_get_mouse())
		var machice_coord = _get_coord(holding.position)
		holding.position = mouse_coord*Machine.GRID_SIZE
		if machice_coord !=  mouse_coord:
			for plug in holding.get_plugs():
				if plug in wires:
					wires[plug].setup()
			if is_space_used(mouse_coord, holding.size):
				holding.modulate = invalid_colour
			else:
				holding.modulate = grabing_colour
	if dragging:
		dragging.setup(_get_mouse())


func _unhandled_input(event: InputEvent) -> void:
	if dragging and event.is_action_released("pickup"):
		wires.erase(dragging.start)
		dragging.queue_free()
		dragging = null


func make_machine(data: MachineData) -> Machine:
	var machine = load("res://SRC/Level/Panel/Machine.tscn").instance()
	machine.data = data
	machine.plug_counts = data.plugs
	machine.position = _get_free_space(data.size)*Machine.GRID_SIZE
	machine.size = data.size
	machine.transpose_plugs = data.transpose_plugs
	machine.colour = data.colour
	add_child(machine)
	ready_machine(machine)
	machines[machine] = 0
	return machine


func delete_machine(machine: Machine) -> void:
	if locked:
		return
	set_machine_space(machine, false)
	for plug in machine.plugs:
		if plug in wires:
			var wire = wires[plug]
			wires.erase(wire.start)
			wires.erase(wire.end)
			wire.queue_free()
	machines.erase(machine)
	machine.queue_free()


func _get_free_space(size: Vector2) -> Vector2:
	var coord = _get_coord($MoveableCamera.position)
	if not is_space_used(coord, size):
		return coord
	var r := 1
	var dirs = [Vector2(-1,0), Vector2(0,-1), Vector2(1,0), Vector2(0,1)]
	while true:
		coord += Vector2.ONE
		for i in range(4):
			for j in range(2*r-1):
				if not is_space_used(coord, size):
					return coord
				coord += dirs[i]
		r += 1
	return Vector2.ZERO


func ready_machine(machine: Machine) -> void:
	machine.position = _get_coord(machine.position)*Machine.GRID_SIZE
	machine.connect("picked_up", self, "_on_Machine_picked_up")
	set_machine_space(machine, true)
	for plug in machine.get_plugs():
		plug.connect("dragged", self, "_on_plug_dragged", [machine])
		plug.connect("dropped", self, "_on_plug_dropped", [machine])


func handle_calculations() -> void:
	visited.clear()
	for machine in machines:
		machine.other.reset()
	for machine in machines:
		machine.other.get_output()
	for machine in machines:
		_handle(machine)


func _handle(machine: Machine) -> void:
	if machine in visited:
		return
	visited[machine] = 0
	for plug in machine.plugs:
		if plug.type == Plug.TYPE.IN and plug in wires:
			var other = wires[plug].start
			if other == plug:
				other = wires[plug].end
			if other.get_node("../../").data.calc:
				_handle(other.get_node("../../"))
			plug.value = clamp(other.value, -99, 99)
	machine.other.handle()


func interact(world: WorldManager) -> void:
	var m := []
	for machine in machines:
		m.append(machine)
	m.sort_custom(self, "_sort")
	for machine in m:
		machine.other.interact(world)


func _sort(a: Machine, b: Machine) -> bool:
	return a.data.priority > b.data.priority


func get_errors() -> Array:
	visited.clear()
	for machine in machines:
		if not machine in visited:
			var res = _search(machine)
			if len(res) > 0:
				return res[1]
	return []


func _search(machine: Machine) -> Array:
	if not machine.data.calc:
		return []
	visited[machine] = 0
	for plug in machine.plugs:
		if plug.type == Plug.TYPE.OUT and plug in wires:
			var other = wires[plug].start
			if other == plug:
				other = wires[plug].end
			var other_machine = other.get_node("../../")
			if other_machine in visited and visited[other_machine] == 0:
				return [other_machine, [wires[plug]], true]
			var res = _search(other_machine)
			if len(res) > 0:
				if res[2]:
					res[1].append(wires[plug])
				if res[0] == machine:
					res[2] = false
				return res
	visited[machine] = 1
	return []


func _on_Machine_picked_up(machine: Machine, pressed: bool) -> void:
	if pressed:
		if locked:
			return
		machine.z_index = 2
		_init_mouse(machine.position)
		holding = machine
		holding_start_coord = _get_coord(machine.position)
		holding.modulate = grabing_colour
		set_machine_space(holding, false)
	else:
		machine.z_index = 0
		if is_space_used(_get_coord(holding.position), holding.size):
			holding.position = holding_start_coord*Machine.GRID_SIZE
		set_machine_space(machine, true)
		holding.modulate = Color.white
		holding = null


func _on_plug_dragged(plug: Plug, machine: Machine) -> void:
	if locked:
		return
	_init_mouse(plug.get_position())
	if plug in wires:
		if wires[plug].start == plug:
			wires[plug].start = wires[plug].end
		wires[plug].steady = false
		dragging = wires[plug]
		wires.erase(plug)
	else:
		var wire = Wire.new()
		add_child(wire)
		wires[plug] = wire
		wire.start = plug
		dragging = wire


func _on_plug_dropped(plug: Plug, machine: Machine) -> void:
	if dragging.start.get_parent() == plug.get_parent() or dragging.start.type == plug.type:
		wires.erase(dragging.start)
		dragging.queue_free()
		return
	wires[plug] = dragging
	dragging.steady = true
	dragging.end = plug
	dragging = null


func set_machine_space(machine: Machine, value: bool) -> void:
	var coord = _get_coord(machine.position)
	for i in range(int(machine.size.x)):
		for j in range(int(machine.size.y)):
			var p := Vector2(int(coord.x)+i, int(coord.y)+j)
			if value:
				used_space[p] = 1
			else:
				if p in used_space:
					used_space.erase(p)


func is_space_used(coord: Vector2, size: Vector2) -> bool:
	for i in range(int(size.x)):
		for j in range(int(size.y)):
			if Vector2(int(coord.x)+i, int(coord.y)+j) in used_space:
				return true
	return false


func _get_coord(val: Vector2) -> Vector2:
	return val.snapped(Vector2.ONE*Machine.GRID_SIZE)/Machine.GRID_SIZE


func _init_mouse(var from: Vector2 = Vector2.ZERO) -> void:
	speed = 512/get_viewport().get_parent().get_viewport().size.x
	start = get_viewport().get_mouse_position()*speed - from


func _get_mouse() -> Vector2:
	return get_viewport().get_mouse_position()*speed - start
