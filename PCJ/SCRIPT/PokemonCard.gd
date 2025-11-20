extends VBoxContainer

# Referencias a los nodos hijos
@onready var imagen = $ImagenContainer/TextureRect
@onready var barra_ps = $BARRAS/SALUD/ProgressBar
@onready var sello = $ImagenContainer/SELLO
@onready var ps_actual_label = $BARRAS/SALUD/PS_ACTUAL
@onready var ps_max_label = $BARRAS/SALUD/PS_MAX
@onready var exp_actual_label = $BARRAS/EXPERIENCIA/EXP_ACTUAL

# Señal para detectar el click en la tarjeta
signal tarjeta_presionada

# Función para configurar la tarjeta con los datos del Pokémon
func configurar(ruta_imagen: String, ps_actual: int, ps_maximo: int, exp_actual: int, exp_maximo: int, atrapado := 0, mostrar_sello := true, nombre := "", mostrar_barras := true, es_pc := false):
	# Cargar y asignar la imagen solo si el nodo existe y el recurso es válido
	if imagen and ResourceLoader.exists(ruta_imagen):
		var textura = load(ruta_imagen)
		if typeof(textura) == TYPE_OBJECT and textura is Texture2D:
			imagen.texture = textura
		else:
			imagen.texture = null
	else:
		imagen.texture = null
	# En PC, ps_actual siempre igual a ps_maximo
	if es_pc:
		ps_actual = ps_maximo
	# Configurar barra de PS
	if barra_ps:
		barra_ps.max_value = ps_maximo
		barra_ps.value = ps_actual
		barra_ps.visible = mostrar_barras
		# Cambiar color según porcentaje
		var porcentaje = float(ps_actual) / float(ps_maximo) * 100.0 if ps_maximo > 0 else 0.0
		if porcentaje >= 50.0:
			barra_ps.add_theme_color_override("fg", Color(0, 1, 0)) # Verde
		elif porcentaje >= 10.0:
			barra_ps.add_theme_color_override("fg", Color(1, 1, 0)) # Amarillo
		else:
			barra_ps.add_theme_color_override("fg", Color(1, 0, 0)) # Rojo
	# Mostrar valores en los labels
	if ps_actual_label:
		ps_actual_label.text = str(ps_actual)
	if ps_max_label:
		ps_max_label.text = str(ps_maximo)
	# Mostrar experiencia
	if exp_actual_label:
		if exp_actual == null:
			exp_actual_label.text = "0"
		else:
			exp_actual_label.text = str(exp_actual)
	# Mostrar el sello solo si mostrar_sello es true y está atrapado
	if sello:
		sello.visible = mostrar_sello and atrapado == 1

var touch_start_pos = null
var touch_moved = false
const TAP_THRESHOLD = 20 # píxeles

func _ready():
	# Habilitar la detección de clics en la tarjeta
	self.mouse_filter = Control.MOUSE_FILTER_PASS
	connect("gui_input", Callable(self, "_on_gui_input"))

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			touch_start_pos = event.position
			touch_moved = false
		elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT and touch_start_pos != null:
			if not touch_moved:
				emit_signal("tarjeta_presionada")
			touch_start_pos = null
	elif event is InputEventMouseMotion and touch_start_pos != null:
		if event.position.distance_to(touch_start_pos) > TAP_THRESHOLD:
			touch_moved = true
