extends VBoxContainer

# Referencias a los nodos hijos
@onready var imagen = $TextureRect
@onready var barra_ps = $SALUD/ProgressBar
@onready var barra_exp = $EXPERIENCIA/ProgressBar

# Función para configurar la tarjeta con los datos del Pokémon
func configurar(ruta_imagen: String, ps_actual: int, ps_maximo: int, exp_actual: int, exp_maximo: int):
	# Cargar y asignar la imagen
	if ResourceLoader.exists(ruta_imagen):
		imagen.texture = load(ruta_imagen)
	
	# Configurar barra de PS
	barra_ps.max_value = ps_maximo
	barra_ps.value = ps_actual
	
	# Configurar barra de EXP
	barra_exp.max_value = exp_maximo
	barra_exp.value = exp_actual
