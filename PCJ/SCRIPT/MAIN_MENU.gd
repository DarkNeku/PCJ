extends Control
func _ready():
	$Panel/VBoxContainer/Button2.pressed.connect(_cambiar_escena)

func _cambiar_escena():
	get_tree().change_scene_to_file("res://SCENE/NUEVA_PARTIDA.tscn")
