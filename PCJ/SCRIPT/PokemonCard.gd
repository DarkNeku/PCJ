extends VBoxContainer

# Referencias a los nodos hijos A
@onready var imagen = $TextureRect
@onready var barra_ps = $BARRAS/SALUD/ProgressBar
@onready var barra_exp = $BARRAS/EXPERIENCIA/ProgressBar

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
