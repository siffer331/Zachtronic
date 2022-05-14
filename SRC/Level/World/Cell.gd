class_name Cell
extends Sprite

const SIZE := 10

signal collided

var value := 0 setget _set_value
var label: Label

func _ready() -> void:
	label = Label.new()
	label.theme = load("res://Assets/WorldTheme.tres")
	add_child(label)
	label.rect_position = Vector2(-5, -3)
	label.rect_size = Vector2(11,6)
	label.align = Label.ALIGN_CENTER
	label.text = "0"


func _set_value(val: int) -> void:
	value = val
	label.text = str(value)


func _on_Area_area_entered(area: Area2D) -> void:
	emit_signal("collided")
