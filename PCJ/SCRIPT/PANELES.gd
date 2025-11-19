extends VBoxContainer

# Referencias a los paneles y barra de navegación
@onready var panel_equipo = $PanelEquipo
@onready var panel_pc = $PanelPC
@onready var panel_captura = $PanelCaptura
@onready var barra_navegacion = $BarraNavegacion
@onready var btn_equipo = $BarraNavegacion/BtnEquipo
@onready var btn_pc = $BarraNavegacion/BtnPC
@onready var btn_captura = $BarraNavegacion/BtnCaptura
@onready var scroll_captura = $PanelCaptura/ScrollContainer
@onready var grid_captura = $PanelCaptura/ScrollContainer/GridContainer
@onready var confirmacion = $CONFIRMACION

var dialogo_confirmacion
var nombre_pokemon_seleccionado = ""

func _ready():
	mostrar_seccion("equipo")
	btn_equipo.pressed.connect(func(): mostrar_seccion("equipo"))
	btn_pc.pressed.connect(func(): mostrar_seccion("pc"))
	btn_captura.pressed.connect(func(): mostrar_seccion("captura"))
	dialogo_confirmacion = $CONFIRMACION

func mostrar_seccion(seccion):
	panel_equipo.visible = (seccion == "equipo")
	panel_pc.visible = (seccion == "pc")
	panel_captura.visible = (seccion == "captura")
	# Para que el panel visible se muestre arriba, lo movemos al inicio del VBoxContainer
	if seccion == "equipo":
		move_child(panel_equipo, 0)
	elif seccion == "pc":
		move_child(panel_pc, 0)
	elif seccion == "captura":
		move_child(panel_captura, 0)
		mostrar_tarjetas_captura()

func mostrar_tarjetas_captura():
	# Eliminar todos los hijos del GridContainer manualmente
	for child in grid_captura.get_children():
		child.queue_free()
	# Configurar columnas del GridContainer (por si acaso)
	if grid_captura.has_method("set_columns"):
		grid_captura.set_columns(2)
	# Leer el JSON de la base de datos de Pokémon
	var pokedex_json = FileAccess.open("res://SCRIPT/POKEMON_DB.json", FileAccess.READ)
	if pokedex_json:
		var data = pokedex_json.get_as_text()
		var pokemons = []
		if data:
			pokemons = JSON.parse_string(data)
		if typeof(pokemons) == TYPE_ARRAY:
			# Ordenar por id (asumiendo que es string tipo '001', '002', ...)
			pokemons.sort_custom(func(a, b): return int(a["id"]) < int(b["id"]))
			for poke in pokemons:
				var tarjeta_escena = load("res://SCENE/PokemonCard.tscn")
				if tarjeta_escena:
					var tarjeta = tarjeta_escena.instantiate()
					# Obtener la ruta de la imagen correctamente
					var imagen_path = poke.get("img_link", "")
					var ps = int(poke.get("ps_actual", 0))
					var ps_max = int(poke.get("ps_max", 0))
					var exp = int(poke.get("exp_actual", 0))
					var exp_max = int(poke.get("exp_evo", 0))
					tarjeta.call_deferred("configurar", imagen_path, ps, ps_max, exp, exp_max)
					tarjeta.connect("tarjeta_presionada", Callable(self, "mostrar_confirmacion").bind(poke.get("nombre", "")))
					grid_captura.add_child(tarjeta)
	else:
		print("No se pudo abrir el archivo POKEMON_DB.json")

func mostrar_confirmacion(nombre_pokemon):
	nombre_pokemon_seleccionado = nombre_pokemon
	confirmacion.dialog_text = "¿CAPTURASTE A %s?" % nombre_pokemon
	confirmacion.popup_centered()
