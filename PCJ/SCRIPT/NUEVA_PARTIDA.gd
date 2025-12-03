extends Control

@onready var texto_label = $Panel/Panel2/RichTextLabel
@onready var boton_continuar = $Panel/Panel/VBoxContainer/Button
@onready var Panel_datos = $Panel/Panel
@onready var line_edit_nombre = $Panel/Panel/VBoxContainer/HBoxContainer/LineEdit
@onready var option_genero = $Panel/Panel/VBoxContainer/HBoxContainer2/OptionButton
@onready var option_avatar = $Panel/Panel/VBoxContainer/HBoxContainer3/OptionButton2

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
			child.queue_free()
	
	# Mostrar texto completo
	texto_label.text = texto_completo
	escribiendo = false
	boton_continuar.visible = true
	Panel_datos.visible = true
	
	# Validar el formulario
	_validar_formulario()
