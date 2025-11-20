# Utilidad para guardar JSON con formato bonito en Godot
extends Node

# Guarda un array o diccionario en formato JSON bonito (indentado)
func save_pretty_json(path: String, data):
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		var json_text = JSON.stringify(data, "\t") # Indentación con tabulación
		file.store_string(json_text)
		file.close()
		return true
	else:
		return false

# Ejemplo de uso:
# var data = [{"nombre": "Bulbasaur", "numero": "001"}, ...]
# save_pretty_json("res://SCRIPT/POKEMON_DB.json", data)
