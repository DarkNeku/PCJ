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
	print("=== NUEVA_PARTIDA _ready iniciado ===")
	# Verificar que los nodos existen
	if texto_label == null:
		push_error("No se encontró el RichTextLabel. Verifica la ruta.")
		return
	else:
		print("✓ texto_label encontrado")

	if boton_continuar == null:
		push_error("No se encontró el Button. Verifica la ruta.")
		return
	else:
		print("✓ boton_continuar encontrado")

	if Panel_datos == null:
		push_error("No se encontró el Panel_datos. Verifica la ruta.")
		return
	else:
		print("✓ Panel_datos encontrado")

	# Conectar el botón para cambiar de escena
	boton_continuar.pressed.connect(_cambiar_escena)
	
	# Conectar señales para validar cuando cambien los campos
	line_edit_nombre.text_changed.connect(_validar_formulario)
	option_genero.item_selected.connect(_on_option_selected)
	option_avatar.item_selected.connect(_on_option_selected)
	
	# Ocultar y desactivar el botón continuar al inicio
	print("Ocultando Panel_datos y botón al inicio")
	boton_continuar.visible = false
	boton_continuar.disabled = true
	
	# Asegurar que Panel_datos esté al frente cuando sea visible
	if Panel_datos.get_parent():
		Panel_datos.get_parent().move_child(Panel_datos, -1)

	Panel_datos.visible = false
	print("Panel_datos.visible inicial = ", Panel_datos.visible)

	# Limpiar el texto inicial
	texto_label.text = ""
	
	# Iniciar el efecto después de un pequeño delay
	print("Esperando 0.5 segundos antes de iniciar efecto de escritura...")
	await get_tree().create_timer(0.5).timeout
	print("Iniciando efecto de escritura")
	iniciar_efecto_escritura()

	# Timeout de seguridad: si después de 20 segundos no se mostró el panel, mostrarlo forzadamente
	await get_tree().create_timer(20.0).timeout
	if not Panel_datos.visible:
		print("⚠ TIMEOUT: Mostrando Panel_datos forzadamente")
		_completar_texto_inmediatamente()

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
		print("=== Efecto de escritura terminado ===")
		# Detener y eliminar el timer
		for child in get_children():
			if child is Timer:
				child.stop()
				if child.is_inside_tree():
					child.queue_free()

		# Mostrar el panel de datos y el botón (pero desactivado)
		print("Mostrando Panel_datos y botón continuar")
		boton_continuar.visible = true
		Panel_datos.visible = true
		print("Panel_datos.visible = ", Panel_datos.visible)
		print("boton_continuar.visible = ", boton_continuar.visible)

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
	print("=== NUEVA_PARTIDA: Iniciando cambio de escena ===")

	# Guardar datos del usuario y resetear campos
	# Leer siempre desde res:// (archivo base)
	var file = FileAccess.open("res://SCRIPT/POKEMON_DB.json", FileAccess.READ)
	if not file:
		push_error("No se pudo abrir POKEMON_DB.json")
		print("ERROR: No se pudo abrir res://SCRIPT/POKEMON_DB.json")
		return

	print("Archivo JSON abierto correctamente")
	var json_text = file.get_as_text()
	file.close()

	var data = JSON.parse_string(json_text)
	if not data:
		push_error("Error al parsear JSON")
		print("ERROR: JSON parse falló")
		return

	print("JSON parseado correctamente")

	# Guardar datos del usuario
	data["jugador"]["usuario"] = line_edit_nombre.text.strip_edges()
	data["jugador"]["genero"] = option_genero.get_item_text(option_genero.selected)
	data["jugador"]["avatar"] = option_avatar.get_item_text(option_avatar.selected)
	# Obtener fecha en formato DD/MM/YYYY (compatible con Android)
	var datetime = Time.get_date_dict_from_system()
	var fecha_inicio = "%02d/%02d/%04d" % [datetime["day"], datetime["month"], datetime["year"]]
	print("DEBUG Fecha inicio guardada: ", fecha_inicio, " (día:", datetime["day"], " mes:", datetime["month"], " año:", datetime["year"], ")")
	data["jugador"]["fecha_inicio"] = fecha_inicio

	# Resetear dinero y casilla del jugador
	data["jugador"]["dinero"] = 0
	data["jugador"]["casilla_actual"] = 0

	# Resetear medallas a 0
	if data.has("medallas"):
		for key in data["medallas"]:
			data["medallas"][key] = 0

	# Resetear MO a 0
	if data.has("MO"):
		for key in data["MO"]:
			data["MO"][key] = 0

	# Resetear objetos_unicos a 0
	if data.has("objetos_unicos"):
		for key in data["objetos_unicos"]:
			data["objetos_unicos"][key] = 0

	# Resetear inventario a 0
	if data.has("inventario"):
		for key in data["inventario"]:
			data["inventario"][key] = 0

	# Resetear todas las casillas a 0
	if data.has("casillas"):
		for key in data["casillas"]:
			data["casillas"][key] = 0

	# Resetear campos de cada Pokémon en la pokedex
	for poke in data["pokedex"]:
		poke["atrapado"] = 0
		poke["equipo"] = 0
		poke["estado"] = ""
		poke["exp_actual"] = 0
		poke["exp_evo"] = 0
		poke["ps_actual"] = poke["ps_max"]
		poke["ubicacion"] = ""

	# Convertir todos los valores numéricos a enteros antes de guardar
	data = _convertir_a_enteros(data)

	# Guardar el JSON actualizado SOLO en user:// (res:// es de solo lectura en Android)
	print("Intentando guardar en user://POKEMON_DB.json")
	var user_file = FileAccess.open("user://POKEMON_DB.json", FileAccess.WRITE)
	if user_file:
		user_file.store_string(JSON.stringify(data, "\t"))
		user_file.close()
		print("✓ Datos guardados exitosamente en user://POKEMON_DB.json")
	else:
		push_error("No se pudo guardar en user://POKEMON_DB.json")
		print("ERROR: No se pudo guardar en user://")
		return

	# Esperar un frame antes de cambiar escena
	print("Esperando frame antes de cambiar escena...")
	await get_tree().process_frame

	print("Desactivando procesamiento de input...")
	# Desactivar procesamiento de input antes de cambiar escena
	set_process_input(false)
	set_process_unhandled_input(false)

	print("Cambiando a escena PANELES...")
	get_tree().change_scene_to_file("res://SCENE/PANELES.tscn")
	print("=== Cambio de escena completado ===")

# Opcional: permite saltarse el efecto al hacer clic
func _input(event):
	if not is_inside_tree():
		return
	if escribiendo and event is InputEventMouseButton and event.pressed:
		_completar_texto_inmediatamente()
	elif escribiendo and event.is_action_pressed("ui_accept"):
		_completar_texto_inmediatamente()

func _completar_texto_inmediatamente():
	print("=== Completando texto inmediatamente ===")
	# Detener y eliminar timers
	for child in get_children():
		if child is Timer:
			child.stop()
			if child.is_inside_tree():
				child.queue_free()

	# Mostrar texto completo
	texto_label.text = texto_completo
	escribiendo = false

	# Mostrar el panel de datos y el botón
	print("Mostrando Panel_datos y botón desde _completar_texto_inmediatamente")
	boton_continuar.visible = true
	Panel_datos.visible = true
	print("Panel_datos.visible = ", Panel_datos.visible)

	# Validar si ya se puede activar
	_validar_formulario()

func _convertir_a_enteros(valor, key_name = ""):
	# Lista de claves que deben permanecer como string
	var campos_string = ["id", "numero", "img_link", "nombre", "estado", "ubicacion", "usuario", "genero", "avatar", "fecha_inicio", "fecha_ultima"]

	# Función recursiva para convertir todos los números a enteros
	if typeof(valor) == TYPE_DICTIONARY:
		var nuevo_dict = {}
		for key in valor:
			# Pasar el nombre de la clave para verificar si debe ser string
			nuevo_dict[key] = _convertir_a_enteros(valor[key], key)
		return nuevo_dict
	elif typeof(valor) == TYPE_ARRAY:
		var nuevo_array = []
		for item in valor:
			nuevo_array.append(_convertir_a_enteros(item, key_name))
		return nuevo_array
	elif typeof(valor) == TYPE_FLOAT:
		return int(valor)
	elif typeof(valor) == TYPE_STRING:
		# Si la clave está en la lista de campos que deben ser string, no convertir
		if key_name in campos_string:
			return valor
		# Si es un string que representa un número, convertirlo a entero
		if valor.is_valid_int():
			return int(valor)
		elif valor.is_valid_float():
			return int(float(valor))
		else:
			return valor
	else:
		return valor
	boton_continuar.visible = true
	Panel_datos.visible = true
	
	# Validar el formulario
	_validar_formulario()

func _exit_tree():
	# Limpiar procesamiento de input al salir
	set_process_input(false)
	set_process_unhandled_input(false)
	# Limpiar timers
	for child in get_children():
		if child is Timer:
			child.stop()
			if child.is_inside_tree():
				child.queue_free()


func _on_button_pressed() -> void:
	$AudioBoton.play() # Replace with function body.
