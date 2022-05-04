extends Node2D

export var space: Vector2
export var offset: Vector2

var holdning: Machine = null

var used_space := []


func _ready() -> void:
	for i in range(int(space.x)):
		used_space.append([])
		for j in range(int(space.y)):
			used_space[i].append(false)
	for machine in get_children():
		if machine is Machine:
			readyMachine(machine)


func readyMachine(machine: Machine) -> void:
	machine.position = offset + (machine.position-offset).snapped(Vector2(25,25))
	machine.connect("picked_up", self, "_on_Machine_picked_up")


func _on_Machine_picked_up(machine: Machine) -> void:
	holdning = machine
