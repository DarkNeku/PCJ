extends Control

func _ready():
	$Panel/VBoxContainer/Button2.pressed.connect(_cambiar_escena)
	$Panel/VBoxContainer/Button_CONTINUE.pressed.connect(_mostrar_window_datos)
	var datos = _leer_datos_usuario()
	var btn_continuar = $Panel/Window/Panel/VBoxContainer/HBoxContainer5/CONTINUAR
	var jugador = datos.get("jugador", {})
	if jugador.get("usuario", "") == "" or jugador.get("usuario", "-") == "-":
		btn_continuar.disabled = true
	else:
		btn_continuar.disabled = false
	# Conectar el botón VOLVER para cerrar la ventana
	var btn_volver = $Panel/Window/Panel/VBoxContainer/HBoxContainer5/VOLVER
	btn_volver.pressed.connect(_cerrar_window_datos)
	# Conectar el botón CONTINUAR para ir a PANELES
	btn_continuar.pressed.connect(_ir_a_paneles)

func _cambiar_escena():
	get_tree().change_scene_to_file("res://SCENE/NUEVA_PARTIDA.tscn")

func _mostrar_window_datos():
	var window = $Panel/Window
	if window and window.is_inside_tree():
		var nombre_label = window.get_node("Panel/VBoxContainer/HBoxContainer/NOMBRE_JUGADOR")
		var genero_label = window.get_node("Panel/VBoxContainer/HBoxContainer2/GENERO_JUGADOR")
		var avatar_label = window.get_node("Panel/VBoxContainer/HBoxContainer3/AVATAR_JUGADOR")
		var ultima_label = window.get_node("Panel/VBoxContainer/HBoxContainer4/ULTIMA_SESION")
		var datos = _leer_datos_usuario()
		var jugador = datos.get("jugador", {})
		if nombre_label:
			nombre_label.text = jugador.get("usuario", "-")
		if genero_label:
			genero_label.text = jugador.get("genero", "-")
		if avatar_label:
			avatar_label.text = jugador.get("avatar", "-")
		if ultima_label:
			ultima_label.text = jugador.get("fecha_ultima", "-")
		window.popup_centered()

func _cerrar_window_datos():
	var window = $Panel/Window
	if window and window.is_inside_tree():
		window.hide()

func _leer_datos_usuario():
	var path = "user://POKEMON_DB.json"
	if not FileAccess.file_exists(path):
		path = "res://SCRIPT/POKEMON_DB.json"
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		var json = JSON.parse_string(json_text)
		if typeof(json) == TYPE_DICTIONARY:
			return json
		elif typeof(json) == TYPE_ARRAY:
			return {}
	return {}

func _ir_a_paneles():
	get_tree().change_scene_to_file("res://SCENE/PANELES.tscn")
