extends Node2D

# Referencia al GridContainer donde se mostrarán las tarjetas
@onready var grid_container = $Panel/GridContainer

func _ready():
	mostrar_bulbasaur()

func mostrar_bulbasaur():
	# Instanciar la tarjeta de Pokémon
	var tarjeta_escena = load("res://SCENE/PokemonCard.tscn")
	var tarjeta = tarjeta_escena.instantiate()
	# Agregar la tarjeta al GridContainer
	grid_container.add_child(tarjeta)
	# Configurar la tarjeta usando call_deferred para asegurar que los nodos hijos estén listos
	tarjeta.call_deferred("configurar", "res://ASSET/POKEMON/1.0. Bulbasaur.png", 20, 20, 0, 100)
