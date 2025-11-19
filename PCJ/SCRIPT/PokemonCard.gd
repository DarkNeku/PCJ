extends VBoxContainer

# Referencias a los nodos hijos A
@onready var imagen = $TextureRect
@onready var barra_ps = $BARRAS/SALUD/ProgressBar
@onready var barra_exp = $BARRAS/EXPERIENCIA/ProgressBar

# Señal para detectar el click en la tarjeta
signal tarjeta_presionada

# Función para configurar la tarjeta con los datos del Pokémon
func configurar(ruta_imagen: String, ps_actual: int, ps_maximo: int, exp_actual: int, exp_maximo: int):
	# Cargar y asignar la imagen solo si el nodo existe y el recurso es válido
	if imagen and ResourceLoader.exists(ruta_imagen):
		var textura = load(ruta_imagen)
		if typeof(textura) == TYPE_OBJECT and textura is Texture2D:
			imagen.texture = textura
		else:
			imagen.texture = null
	else:
		imagen.texture = null
	# Configurar barra de PS
	if barra_ps:
		barra_ps.max_value = ps_maximo
		barra_ps.value = ps_actual
	# Configurar barra de EXP
	if barra_exp:
		barra_exp.max_value = exp_maximo
		barra_exp.value = exp_actual

func _ready():
	# Habilitar la detección de clics en la tarjeta
	self.mouse_filter = Control.MOUSE_FILTER_PASS
	connect("gui_input", Callable(self, "_on_gui_input"))

func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("tarjeta_presionada")
