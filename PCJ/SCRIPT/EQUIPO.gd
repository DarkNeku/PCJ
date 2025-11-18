extends Node2D

# Referencia al GridContainer donde se mostrarán las tarjetas
@onready var grid_container = $Panel/GridContainer

func _ready():
	mostrar_equipo()

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
