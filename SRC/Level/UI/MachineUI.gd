extends MarginContainer

signal placed(data)

export(Resource) var data

func _ready() -> void:
	if data is MachineData:
		$Split/TitleLayout/Titel.text = data.name
		$Split/Description.text = data.description
		$Split/TitleLayout/CenterContainer/Sprite.texture = data.sprite

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("pickup"):
		emit_signal("placed", data)
