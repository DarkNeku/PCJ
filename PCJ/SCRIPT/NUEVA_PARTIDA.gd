extends Control
func _ready():
	$Panel/Panel/VBoxContainer/Button.pressed.connect(_cambiar_escena)

func _cambiar_escena():
	get_tree().change_scene_to_file("res://SCENE/PANELES.tscn")
