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
@onready var barra_busqueda = $PanelCaptura/BarraBusqueda
@onready var grid_pc = $PanelPC/ScrollContainer/GridContainer
@onready var busquedaPC = $PanelPC/busquedaPC
@onready var grid_equipo = $PanelEquipo/GridContainer
@onready var lista_equipo = $ListaEquipo

var dialogo_confirmacion
var nombre_pokemon_seleccionado = ""
var id_pokemon_seleccionado = ""
var filtro_busqueda = ""
var filtro_busqueda_pc = ""
var pokemons_db = []
var json_utils = preload("res://SCRIPT/json_utils.gd").new()

func _ready():
	mostrar_seccion("equipo")
	btn_equipo.pressed.connect(func(): mostrar_seccion("equipo"))
	btn_pc.pressed.connect(func(): mostrar_seccion("pc"))
	btn_captura.pressed.connect(func(): mostrar_seccion("captura"))
	dialogo_confirmacion = $CONFIRMACION
	if barra_busqueda:
		barra_busqueda.text_changed.connect(_on_busqueda_text_changed)
	if busquedaPC:
		busquedaPC.text_changed.connect(_on_busquedaPC_text_changed)
	lista_equipo.id_pressed.connect(_on_ListaEquipo_id_pressed)

func mostrar_seccion(seccion):
	panel_equipo.visible = (seccion == "equipo")
	panel_pc.visible = (seccion == "pc")
	panel_captura.visible = (seccion == "captura")
	# Para que el panel visible se muestre arriba, lo movemos al inicio del VBoxContainer
	if seccion == "equipo":
		move_child(panel_equipo, 0)
		mostrar_tarjetas_equipo()
	elif seccion == "pc":
		move_child(panel_pc, 0)
		mostrar_tarjetas_pc()
	elif seccion == "captura":
		move_child(panel_captura, 0)
		mostrar_tarjetas_captura()

func _on_busqueda_text_changed(nuevo_texto):
	filtro_busqueda = nuevo_texto
	mostrar_tarjetas_captura()

func _on_busquedaPC_text_changed(nuevo_texto):
	filtro_busqueda_pc = nuevo_texto
	mostrar_tarjetas_pc()

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
		pokemons_db = []
		if data:
			pokemons_db = JSON.parse_string(data)
		if typeof(pokemons_db) == TYPE_ARRAY:
			pokemons_db.sort_custom(func(a, b): return int(a["id"]) < int(b["id"]))
			for poke in pokemons_db:
				if filtro_busqueda == "" or poke.get("nombre", "").to_lower().find(filtro_busqueda.to_lower()) != -1:
					var tarjeta_escena = load("res://SCENE/PokemonCard.tscn")
					if tarjeta_escena:
						var tarjeta = tarjeta_escena.instantiate()
						var imagen_path = poke.get("img_link", "")
						var ps = poke.get("ps_actual", "")
						if ps == "":
							ps = poke.get("ps_max", 0)
						ps = int(ps)
						var ps_max = int(poke.get("ps_max", 0))
						var exp = poke.get("exp_actual", "")
						if exp == "":
							exp = 0
						exp = int(exp)
						var exp_max = int(poke.get("exp_evo", 0))
						var atrapado = int(poke.get("atrapado", 0))
						var id_poke = poke.get("id", "")
						# En captura, mostrar_sello = true
						tarjeta.call_deferred("configurar", imagen_path, ps, ps_max, exp, exp_max, atrapado, true, poke.get("nombre", ""), false)
						tarjeta.connect("tarjeta_presionada", Callable(self, "mostrar_confirmacion").bind(id_poke, poke.get("nombre", "")))
						grid_captura.add_child(tarjeta)
	else:
		print("No se pudo abrir el archivo POKEMON_DB.json")

func mostrar_tarjetas_pc():
	# Eliminar todos los hijos del GridContainer manualmente
	for child in grid_pc.get_children():
		child.queue_free()
	# Configurar columnas del GridContainer (por si acaso)
	if grid_pc.has_method("set_columns"):
		grid_pc.set_columns(2)
	# Leer el JSON de la base de datos de Pokémon
	var pokedex_json = FileAccess.open("res://SCRIPT/POKEMON_DB.json", FileAccess.READ)
	if pokedex_json:
		var data = pokedex_json.get_as_text()
		var pokemons_db_local = []
		if data:
			pokemons_db_local = JSON.parse_string(data)
		if typeof(pokemons_db_local) == TYPE_ARRAY:
			pokemons_db_local.sort_custom(func(a, b): return int(a["id"]) < int(b["id"]))
			for poke in pokemons_db_local:
				if int(poke.get("atrapado", 0)) == 1 and int(poke.get("equipo", 0)) == 0 and (filtro_busqueda_pc == "" or poke.get("nombre", "").to_lower().find(filtro_busqueda_pc.to_lower()) != -1):
					var tarjeta_escena = load("res://SCENE/PokemonCard.tscn")
					if tarjeta_escena:
						var tarjeta = tarjeta_escena.instantiate()
						var imagen_path = poke.get("img_link", "")
						var ps = poke.get("ps_actual", "")
						if ps == "":
							ps = poke.get("ps_max", 0)
						ps = int(ps)
						var ps_max = int(poke.get("ps_max", 0))
						var exp = poke.get("exp_actual", "")
						if exp == "":
							exp = 0
						exp = int(exp)
						var exp_max = int(poke.get("exp_evo", 0))
						var atrapado = int(poke.get("atrapado", 0))
						# En cada llamada a configurar, agrega el parámetro nombre
						# En PC, mostrar_sello = false, mostrar_barras = true, es_pc = true
						tarjeta.call_deferred("configurar", imagen_path, ps, ps_max, exp, exp_max, atrapado, false, poke.get("nombre", ""), true, true)
						tarjeta.connect("tarjeta_presionada", Callable(self, "mostrar_confirmacion_pc").bind(poke.get("id", ""), poke.get("nombre", "")))
						grid_pc.add_child(tarjeta)
	else:
		print("No se pudo abrir el archivo POKEMON_DB.json")

func mostrar_tarjetas_equipo():
	# Eliminar todos los hijos del GridContainer manualmente
	for child in grid_equipo.get_children():
		child.queue_free()
	# Configurar columnas del GridContainer (por si acaso)
	if grid_equipo.has_method("set_columns"):
		grid_equipo.set_columns(2)
	# Leer el JSON de la base de datos de Pokémon
	var pokedex_json = FileAccess.open("res://SCRIPT/POKEMON_DB.json", FileAccess.READ)
	if pokedex_json:
		var data = pokedex_json.get_as_text()
		var pokemons_db_local = []
		if data:
			pokemons_db_local = JSON.parse_string(data)
		if typeof(pokemons_db_local) == TYPE_ARRAY:
			pokemons_db_local.sort_custom(func(a, b): return int(a["equipo"]) < int(b["equipo"]))
			for poke in pokemons_db_local:
				var eq = int(poke.get("equipo", 0))
				if eq > 0 and eq <= 6:
					var tarjeta_escena = load("res://SCENE/PokemonCard.tscn")
					if tarjeta_escena:
						var tarjeta = tarjeta_escena.instantiate()
						var imagen_path = poke.get("img_link", "")
						var ps = poke.get("ps_actual", "")
						if ps == "":
							ps = poke.get("ps_max", 0)
						ps = int(ps)
						var ps_max = int(poke.get("ps_max", 0))
						var exp = poke.get("exp_actual", "")
						if exp == "":
							exp = 0
						exp = int(exp)
						var exp_max = int(poke.get("exp_evo", 0))
						var atrapado = int(poke.get("atrapado", 0))
						# En cada llamada a configurar, agrega el parámetro nombre
						# En equipo, mostrar_sello = false
						tarjeta.call_deferred("configurar", imagen_path, ps, ps_max, exp, exp_max, atrapado, false, poke.get("nombre", ""), true)
						grid_equipo.add_child(tarjeta)
	else:
		print("No se pudo abrir el archivo POKEMON_DB.json")

func mostrar_confirmacion(id_pokemon, nombre_pokemon):
	id_pokemon_seleccionado = id_pokemon
	nombre_pokemon_seleccionado = nombre_pokemon
	confirmacion.dialog_text = "\n¿CAPTURASTE A %s?\n" % nombre_pokemon
	if confirmacion.visible:
		confirmacion.hide()
	confirmacion.popup_centered()

func mostrar_confirmacion_pc(id_pokemon, nombre_pokemon):
	id_pokemon_seleccionado = id_pokemon
	nombre_pokemon_seleccionado = nombre_pokemon
	var mensaje = "\n¿QUIERES MOVER A\n%s AL EQUIPO?\n" % nombre_pokemon
	confirmacion.dialog_text = mensaje
	if confirmacion.visible:
		confirmacion.hide()
	confirmacion.popup_centered()

func mostrar_lista_equipo():
	lista_equipo.clear()
	var pokedex_json = FileAccess.open("res://SCRIPT/POKEMON_DB.json", FileAccess.READ)
	if pokedex_json:
		var data = pokedex_json.get_as_text()
		var pokemons_db_local = []
		if data:
			pokemons_db_local = JSON.parse_string(data)
		if typeof(pokemons_db_local) == TYPE_ARRAY:
			for poke in pokemons_db_local:
				var eq = int(poke.get("equipo", 0))
				if eq > 0 and eq <= 6:
					var texto = "%d - %s" % [eq, poke.get("nombre", "")]
					lista_equipo.add_item(texto)
	lista_equipo.popup_centered()

func _on_confirmation_dialog_confirmed():
	# Si la confirmación viene de PanelPC, mostrar la lista de equipo
	if panel_pc.visible:
		mostrar_lista_equipo()
		return
	# Buscar el Pokémon en la base de datos y marcarlo como atrapado usando el id
	for poke in pokemons_db:
		if poke.get("id", "") == id_pokemon_seleccionado:
			poke["atrapado"] = 1
			break
	# Guardar el JSON actualizado (usando JSON.stringify para formato correcto)
	if typeof(pokemons_db) == TYPE_ARRAY:
		json_utils.save_pretty_json("res://SCRIPT/POKEMON_DB.json", pokemons_db)
	else:
		print("Error: pokemons_db no es un array válido")
	# Refrescar la grilla para mostrar el sello
	mostrar_tarjetas_captura()

func _on_ListaEquipo_id_pressed(index):
	# Obtener el número de equipo y nombre del Pokémon seleccionado en la lista
	var texto = lista_equipo.get_item_text(index)
	var partes = texto.split(" - ")
	if partes.size() != 2:
		return
	var num_equipo = int(partes[0])
	var nombre_equipo = partes[1]
	# Leer la base de datos
	var pokedex_json = FileAccess.open("res://SCRIPT/POKEMON_DB.json", FileAccess.READ)
	var pokemons_db_local = []
	if pokedex_json:
		var data = pokedex_json.get_as_text()
		if data:
			pokemons_db_local = JSON.parse_string(data)
	# Buscar el Pokémon del PC y el del equipo
	var id_pc = id_pokemon_seleccionado
	var idx_pc = -1
	var idx_eq = -1
	for i in range(pokemons_db_local.size()):
		var poke = pokemons_db_local[i]
		if poke.get("id", "") == id_pc:
			idx_pc = i
		if int(poke.get("equipo", 0)) == num_equipo:
			idx_eq = i
	# Intercambiar los valores de 'equipo'
	if idx_pc != -1 and idx_eq != -1:
		var temp = pokemons_db_local[idx_eq]["equipo"]
		pokemons_db_local[idx_eq]["equipo"] = 0
		pokemons_db_local[idx_pc]["equipo"] = temp
		pokemons_db_local[idx_pc]["ubicacion"] = "equipo"
		pokemons_db_local[idx_eq]["ubicacion"] = "pc"
		# Guardar el JSON actualizado
		json_utils.save_pretty_json("res://SCRIPT/POKEMON_DB.json", pokemons_db_local)
		# Refrescar las vistas
		mostrar_tarjetas_pc()
		mostrar_tarjetas_equipo()
	lista_equipo.hide()
