extends VBoxContainer

@onready var imagen = $ImagenContainer/TextureRect
@onready var ps_max_label = $HBoxContainer/Panel/PS_MAX # Label para PS máximo
@onready var exp_actual_label = $HBoxContainer/Panel/EXP_ACT # Label para experiencia actual

func configurar(ruta_imagen: String, ps_max: int, exp_actual: int):
	if imagen and ResourceLoader.exists(ruta_imagen):
		var textura = load(ruta_imagen)
		if typeof(textura) == TYPE_OBJECT and textura is Texture2D:
			imagen.texture = textura
		else:
			imagen.texture = null
	else:
		imagen.texture = null
	# Mostrar PS máximo y experiencia actual
	if ps_max_label:
		ps_max_label.text = str(ps_max)
	if exp_actual_label:
		exp_actual_label.text = str(exp_actual)
