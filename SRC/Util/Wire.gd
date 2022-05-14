class_name Wire
extends Line2D


var start: Plug setget _set_start
var end: Plug setget _set_end
var steady := false
var curve := Curve2D.new()


func _init() -> void:
	default_color = Color.from_hsv(randf(), 0.4, 0.6)
	joint_mode = Line2D.LINE_JOINT_ROUND
	begin_cap_mode = Line2D.LINE_CAP_ROUND
	end_cap_mode = Line2D.LINE_CAP_ROUND
	width =5


func setup(mouse: Vector2 = Vector2.ZERO) -> void:
	z_index = 1
	curve.clear_points()
	curve.add_point(start.get_position(), Vector2.ZERO, Vector2(0,15))
	var endPosition = Vector2.ZERO
	if end:
		endPosition = end.get_position()
	else:
		steady = false
	if not steady:
		endPosition = mouse
	curve.add_point(endPosition, Vector2(0,15))
	points = curve.tessellate(10)


func _set_start(val: Plug) -> void:
	start = val
	setup()
	


func _set_end(val: Plug) -> void:
	end = val
	setup()

