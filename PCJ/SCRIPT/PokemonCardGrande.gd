extends VBoxContainer

@onready var imagen = $ImagenContainer/TextureRect

func configurar(ruta_imagen: String):
	if imagen and ResourceLoader.exists(ruta_imagen):
		var textura = load(ruta_imagen)
		if typeof(textura) == TYPE_OBJECT and textura is Texture2D:
			imagen.texture = textura
		else:
			imagen.texture = null
	else:
		imagen.texture = null
