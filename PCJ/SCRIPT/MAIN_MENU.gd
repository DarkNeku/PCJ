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
		# Configurar el window como exclusivo para evitar conflictos
		if window.has_method("set_flag"):
			window.set_flag(Window.FLAG_POPUP, true)
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
	# Cerrar el window primero para evitar eventos pendientes
	var window = $Panel/Window
	if window and window.is_inside_tree():
		# Desactivar botones dentro del window para evitar más eventos
		var btn_continuar = window.get_node_or_null("Panel/VBoxContainer/HBoxContainer5/CONTINUAR")
		var btn_volver = window.get_node_or_null("Panel/VBoxContainer/HBoxContainer5/VOLVER")
		if btn_continuar:
			btn_continuar.disabled = true
		if btn_volver:
			btn_volver.disabled = true
		# Desactivar procesamiento del window
		if window.has_method("set_process_input"):
			window.set_process_input(false)
			window.set_process_unhandled_input(false)
		# Ocultar el window
		if window.visible:
			window.hide()
	# Esperar un frame para que se procesen los eventos del window
	await get_tree().process_frame
	# Desactivar procesamiento de input antes de cambiar escena
	set_process_input(false)
	set_process_unhandled_input(false)
	# Cambiar escena
	get_tree().change_scene_to_file("res://SCENE/PANELES.tscn")

func _exit_tree():
	# Limpiar procesamiento de input al salir
	set_process_input(false)
	set_process_unhandled_input(false)
	# Desconectar señales del window y botones
	var window = $Panel/Window
	if window:
		var btn_continuar = window.get_node_or_null("Panel/VBoxContainer/HBoxContainer5/CONTINUAR")
		var btn_volver = window.get_node_or_null("Panel/VBoxContainer/HBoxContainer5/VOLVER")
		if btn_continuar and btn_continuar.is_connected("pressed", Callable(self, "_ir_a_paneles")):
			btn_continuar.disconnect("pressed", Callable(self, "_ir_a_paneles"))
		if btn_volver and btn_volver.is_connected("pressed", Callable(self, "_cerrar_window_datos")):
			btn_volver.disconnect("pressed", Callable(self, "_cerrar_window_datos"))
