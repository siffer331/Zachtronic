extends Panel


func _ready() -> void:
	var dir := Directory.new()
	var path := "res://Levels/"
	dir.open(path)
	dir.list_dir_begin()
	var file = dir.get_next()
	var files = []
	while file != "":
		if file[0] != '.':
			files.append(path + file)
		file = dir.get_next()
	dir.list_dir_end()
	var i := 1
	files.sort()
	for data in files:
		var button := Button.new()
		button.rect_min_size = Vector2(60,60)
		$Margin/Center/Grid.add_child(button)
		button.text = "Level" + str(i)
		i += 1
		button.connect("pressed", self, "_on_Button_pressed", [data])


func _on_Button_pressed(data: String) -> void:
	GM.level = load(data)
	print(data)
	get_tree().change_scene("res://SRC/Level/LevelUI.tscn")
