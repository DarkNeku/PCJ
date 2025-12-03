extends Control

@onready var texto_label = $Panel/Panel2/RichTextLabel
@onready var boton_continuar = $Panel/Panel/VBoxContainer/Button
@onready var Panel_datos = $Panel/Panel
@onready var line_edit_nombre = $Panel/Panel/VBoxContainer/HBoxContainer/NOMBRE_USUARIO
@onready var option_genero = $Panel/Panel/VBoxContainer/HBoxContainer2/OptionButton_GENERO
@onready var option_avatar = $Panel/Panel/VBoxContainer/HBoxContainer3/OptionButton_AVATAR

# Texto completo a mostrar
var texto_completo = "HOLA, BIENVENIDO A POKÉMON CHAMPION'S JOURNEY, POR FAVOR DIME TU NOMBRE, SI ERES CHICO O CHICA Y CUAL ES TU AVATAR... LUEGO PRESIONA CONTINUAR PARA INCIAR LA PARTIDA."

# Configuración del efecto
var velocidad_escritura = 0.08  # Segundos entre cada letra (ajusta este valor)
var texto_actual = ""
var indice_letra = 0
var escribiendo = false

func _ready():
	# Verificar que los nodos existen
	if texto_label == null:
		push_error("No se encontró el RichTextLabel. Verifica la ruta.")
		return
	
	if boton_continuar == null:
		push_error("No se encontró el Button. Verifica la ruta.")
		return
	
	# Conectar el botón para cambiar de escena
	boton_continuar.pressed.connect(_cambiar_escena)
	
	# Conectar señales para validar cuando cambien los campos
	line_edit_nombre.text_changed.connect(_validar_formulario)
	option_genero.item_selected.connect(_on_option_selected)
	option_avatar.item_selected.connect(_on_option_selected)
	
	# Ocultar y desactivar el botón continuar al inicio
	boton_continuar.visible = false
	boton_continuar.disabled = true
	
	Panel_datos.visible = false
	
	# Limpiar el texto inicial
	texto_label.text = ""
	
	# Iniciar el efecto después de un pequeño delay
	await get_tree().create_timer(0.5).timeout
	iniciar_efecto_escritura()

func iniciar_efecto_escritura():
	escribiendo = true
	indice_letra = 0
	texto_actual = ""
	
	# Iniciar el timer para escribir letra por letra
	var timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_escribir)
	timer.wait_time = velocidad_escritura
	timer.start()

func _on_timer_escribir():
	if indice_letra < texto_completo.length():
		# Añadir la siguiente letra
		texto_actual += texto_completo[indice_letra]
		texto_label.text = texto_actual
		indice_letra += 1
	else:
		# Terminar el efecto
		escribiendo = false
		# Detener y eliminar el timer
		for child in get_children():
			if child is Timer:
				child.stop()
				if child.is_inside_tree():
					child.queue_free()

		# Mostrar el panel de datos y el botón (pero desactivado)
		boton_continuar.visible = true
		Panel_datos.visible = true
		
		# Validar si ya se puede activar
		_validar_formulario()

func _on_option_selected(_index):
	_validar_formulario()

func _validar_formulario(_texto = ""):
	# Verificar que el nombre no esté vacío
	var nombre_valido = line_edit_nombre.text.strip_edges().length() > 0
	
	# Verificar que se haya seleccionado un género (índice mayor a 0, asumiendo que 0 es "Selecciona...")
	var genero_seleccionado = option_genero.selected > 0
	
	# Verificar que se haya seleccionado un avatar (índice mayor a 0)
	var avatar_seleccionado = option_avatar.selected > 0
	
	# Activar el botón solo si todas las condiciones se cumplen
	if nombre_valido and genero_seleccionado and avatar_seleccionado:
		boton_continuar.disabled = false
	else:
		boton_continuar.disabled = true

func _cambiar_escena():
	# Guardar datos del usuario y resetear campos
	var file = FileAccess.open("res://SCRIPT/POKEMON_DB.json", FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()
	var data = JSON.parse_string(json_text)

	# Guardar datos del usuario
	data["jugador"]["usuario"] = line_edit_nombre.text.strip_edges()
	data["jugador"]["genero"] = option_genero.get_item_text(option_genero.selected)
	data["jugador"]["avatar"] = option_avatar.get_item_text(option_avatar.selected)
	data["jugador"]["fecha_inicio"] = Time.get_date_string_from_system()

	# Resetear medallas, MO, objetos_unicos, inventario
	for key in data["medallas"]:
		data["medallas"][key] = 0
	for key in data["MO"]:
		data["MO"][key] = 0
	for key in data["objetos_unicos"]:
		data["objetos_unicos"][key] = 0
	for key in data["inventario"]:
		data["inventario"][key] = 0

	# Resetear campos de cada Pokémon en la pokedex
	for poke in data["pokedex"]:
		poke["atrapado"] = 0
		poke["equipo"] = 0
		poke["estado"] = ""
		poke["exp_actual"] = 0
		poke["exp_evo"] = 0
		poke["ps_actual"] = poke["ps_max"]
		poke["ubicacion"] = ""

	# Guardar el JSON actualizado en ambos archivos
	file = FileAccess.open("res://SCRIPT/POKEMON_DB.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	var user_file = FileAccess.open("user://POKEMON_DB.json", FileAccess.WRITE)
	if user_file:
		user_file.store_string(JSON.stringify(data, "\t"))
		user_file.close()

	get_tree().change_scene_to_file("res://SCENE/PANELES.tscn")

# Opcional: permite saltarse el efecto al hacer clic
func _input(event):
	if escribiendo and event is InputEventMouseButton and event.pressed:
		_completar_texto_inmediatamente()
	elif escribiendo and event.is_action_pressed("ui_accept"):
		_completar_texto_inmediatamente()

func _completar_texto_inmediatamente():
	# Detener y eliminar timers
	for child in get_children():
		if child is Timer:
			child.stop()
			if child.is_inside_tree():
				child.queue_free()

	# Mostrar texto completo
	texto_label.text = texto_completo
	escribiendo = false
	boton_continuar.visible = true
	Panel_datos.visible = true
	
	# Validar el formulario
	_validar_formulario()
