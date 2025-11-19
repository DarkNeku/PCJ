extends Node2D

# Referencia al GridContainer donde se mostrarán las tarjetas
@onready var grid_container = $Panel/GridContainer
@onready var popup_captura = $PopupCaptura
@onready var busqueda = $PopupCaptura/VBoxContainer/Busqueda
@onready var grid_pokemon = $PopupCaptura/VBoxContainer/GridPokemon
@onready var boton_captura = $Panel/HBoxContainer/CAPTURA

# Lista de los 150 Pokémon (ejemplo, deberías cargar desde un JSON)
var lista_pokemon = []

func _ready():
	mostrar_equipo()
	boton_captura.pressed.connect(_on_boton_captura_pressed)
	cargar_lista_pokemon()

func mostrar_equipo():
	var pokemones = [
		{"img": "res://ASSET/POKEMON/1.0. Bulbasaur.png", "ps": 20, "ps_max": 20, "exp": 0, "exp_max": 100},
		{"img": "res://ASSET/POKEMON/25.0. Pikachu Inicial (fase 2).png", "ps": 22, "ps_max": 22, "exp": 10, "exp_max": 100},
		{"img": "res://ASSET/POKEMON/133.0. Eevee Inicial (Fase 2).png", "ps": 18, "ps_max": 18, "exp": 20, "exp_max": 100},
		{"img": "res://ASSET/POKEMON/134.0. Vaporeon Inicial (Fase 3).png", "ps": 30, "ps_max": 30, "exp": 50, "exp_max": 100},
		{"img": "res://ASSET/POKEMON/135.0. Jolteon Inicial (Fase 3).png", "ps": 28, "ps_max": 28, "exp": 70, "exp_max": 100},
		{"img": "res://ASSET/POKEMON/136.0. Flareon Inicial (Fase 3).png", "ps": 26, "ps_max": 26, "exp": 90, "exp_max": 100}
	]
	for poke in pokemones:
		# Instanciar la tarjeta de Pokémon
		var tarjeta_escena = load("res://SCENE/PokemonCard.tscn")
		var tarjeta = tarjeta_escena.instantiate()
		# Agregar la tarjeta al GridContainer
		grid_container.add_child(tarjeta)
		# Configurar la tarjeta usando call_deferred para asegurar que los nodos hijos estén listos
		tarjeta.call_deferred("configurar", poke["img"], poke["ps"], poke["ps_max"], poke["exp"], poke["exp_max"])

func _on_boton_captura_pressed():
	popup_captura.popup_centered()
	mostrar_pokemon_en_grilla("")

func cargar_lista_pokemon():
	var file = FileAccess.open("res://SCRIPT/POKEMON_DB.json", FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		var data = JSON.parse_string(json_text)
		if typeof(data) == TYPE_ARRAY:
			lista_pokemon = data
		else:
			print("Error: El archivo JSON no tiene formato de lista.")
	else:
		print("No se pudo abrir el archivo de datos de Pokémon.")

func mostrar_pokemon_en_grilla(filtro):
	grid_pokemon.clear()
	for poke in lista_pokemon:
		if filtro == "" or poke["nombre"].to_lower().find(filtro.to_lower()) != -1:
			var tarjeta = crear_tarjeta_pokemon(poke)
			grid_pokemon.add_child(tarjeta)

func crear_tarjeta_pokemon(poke):
	var tarjeta = VBoxContainer.new()
	var imagen = TextureRect.new()
	if ResourceLoader.exists(poke["img"]):
		imagen.texture = load(poke["img"])
		if poke["capturado"]:
			imagen.modulate = Color(0.5, 0.5, 0.5) # escala de grises
	else:
		imagen.texture = null
	tarjeta.add_child(imagen)
	var label = Label.new()
	label.text = poke["nombre"]
	tarjeta.add_child(label)
	tarjeta.connect("gui_input", Callable(self, "_on_tarjeta_pokemon_pressed").bind(poke))
	return tarjeta

func _on_tarjeta_pokemon_pressed(event, poke):
	if event is InputEventMouseButton and event.pressed:
		mostrar_popup_detalle(poke)

func mostrar_popup_detalle(poke):
	# Aquí deberías mostrar el Pokémon en grande y el botón de capturar
	# Puedes crear otro PopupPanel o reutilizar uno
	pass
