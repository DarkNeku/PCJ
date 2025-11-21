extends VBoxContainer

@onready var imagen = $ImagenContainer/TextureRect
@onready var ps_max_label = $HBoxContainer/Panel/PS_MAX # Label para PS máximo
@onready var exp_actual_label = $HBoxContainer/Panel/EXP_ACT # Label para experiencia actual
@onready var ps_line_edit = $HBoxContainer/Panel/PS_LINE # LineEdit para PS actual
@onready var exp_line_edit = $HBoxContainer/Panel/EXP_LINE # LineEdit para experiencia actual
@onready var btn_mas_ps = $HBoxContainer/Panel/MAS_PS
@onready var btn_menos_ps = $HBoxContainer/Panel/MENOS_PS
@onready var btn_mas_exp = $HBoxContainer/Panel/MAS_EXP
@onready var btn_menos_exp = $HBoxContainer/Panel/MENOS_EXP

var id_pokemon = ""

func configurar(ruta_imagen: String, ps_max: int, exp_actual: int, ps_actual: int = -1, id: String = ""):
	id_pokemon = id
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
	# Inicializar los LineEdit con los valores actuales
	if ps_line_edit:
		ps_line_edit.text = str(ps_actual if ps_actual != -1 else ps_max)
	if exp_line_edit:
		exp_line_edit.text = str(exp_actual)

func _ready():
	if btn_mas_ps:
		btn_mas_ps.pressed.connect(_on_mas_ps_pressed)
	if btn_menos_ps:
		btn_menos_ps.pressed.connect(_on_menos_ps_pressed)
	if btn_mas_exp:
		btn_mas_exp.pressed.connect(_on_mas_exp_pressed)
	if btn_menos_exp:
		btn_menos_exp.pressed.connect(_on_menos_exp_pressed)

func _on_mas_ps_pressed():
	if ps_line_edit and ps_max_label:
		var valor_actual = int(ps_line_edit.text)
		var valor_max = int(ps_max_label.text)
		if valor_actual < valor_max:
			ps_line_edit.text = str(valor_actual + 1)

func _on_menos_ps_pressed():
	if ps_line_edit:
		var valor_actual = int(ps_line_edit.text)
		if valor_actual > 0:
			ps_line_edit.text = str(valor_actual - 1)

func _on_mas_exp_pressed():
	if exp_line_edit:
		var valor_actual = int(exp_line_edit.text)
		if valor_actual < 999:
			exp_line_edit.text = str(valor_actual + 1)

func _on_menos_exp_pressed():
	if exp_line_edit:
		var valor_actual = int(exp_line_edit.text)
		if valor_actual > 0:
			exp_line_edit.text = str(valor_actual - 1)

func get_id():
	return id_pokemon
