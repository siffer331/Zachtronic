class_name MoveableCamera
extends Camera2D

export var local := false
export var zoom_factor := 1.15
export var min_zoom := 0.5
export var max_zoom := 2
export var can_zoom := false
var speed := 1.0

var is_panning := false
var focus_point: Vector2


func _process(delta: float) -> void:
	if is_panning:
		#print(focus_point - get_global_mouse_position(), " ", position)
		position = focus_point - get_viewport().get_mouse_position()*speed*zoom


func _input(event: InputEvent, other = false) -> void:
	if local or other:
		if event.is_action_pressed("pan"):
			is_panning = true
			speed = 512/get_viewport().get_parent().get_viewport().size.x
			focus_point = get_viewport().get_mouse_position()*speed*zoom + position
		if event.is_action_released("pan"):
			is_panning = false
		if event is InputEventMouse and event.is_pressed() and can_zoom:
			#var distance: Vector2 = get_parent().get_local_mouse_position() - position
			var old_scale := zoom.x
			if event.button_index == BUTTON_WHEEL_UP:
				zoom = Vector2(max(min_zoom, old_scale/zoom_factor), max(min_zoom, old_scale/zoom_factor))
				#position += distance*(old_scale/zoom.x-1)
			if event.button_index == BUTTON_WHEEL_DOWN:
				zoom = Vector2(min(max_zoom, old_scale*zoom_factor), min(max_zoom, old_scale*zoom_factor))
				#position += distance*(old_scale/zoom.x-1)
