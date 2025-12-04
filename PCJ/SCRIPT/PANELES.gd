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
@onready var grid_equipo = $PanelEquipo/Panel/GridContainer
@onready var lista_equipo = $ListaEquipo
@onready var popup_tarjeta = $PopupTarjetaPokemon
@onready var contenedor_tarjeta = $PopupTarjetaPokemon/ContenedorTarjeta
@onready var btn_cerrar_popup = $PopupTarjetaPokemon/BtnCerrarPopup
@onready var btn_guardar_popup = $PopupTarjetaPokemon/BTNGUARDARPOPUP
@onready var alert_guardado = $ALERT_GUARDADO
@onready var panel_control = $PANEL_CONTROL
@onready var panel_vacio = $PANEL_VACIO
@onready var btn_centro_pokemon = $PANEL_CONTROL/CENTRO_POKEMON
@onready var panel_mochila = $CanvasLayer/PanelMochila
@onready var btn_mochila = $PANEL_CONTROL/MOCHILA
@onready var animation_player = $CanvasLayer/AnimationPlayer
@onready var btn_cerrar_mochila = $CanvasLayer/PanelMochila/VBoxContainer/Control/CERRAR_MOCHILA
@onready var btn_ficha_jugador = $PANEL_CONTROL/FICHA_JUGADOR
@onready var btn_cerrar_ficha = $CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/Control/BTN_CERRAR_FICHA # Asumiendo que este es el botón de cerrar ficha
@onready var label_nombre_jugador = $CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer/Control2/NOMBRE_JUGADOR
@onready var lineedit_dinero = $CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer/Control/HBoxContainer/dinero
@onready var lineedit_casilla_actual = $CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/Control/casilla_actual

const JSON_PATH_RES = "res://SCRIPT/POKEMON_DB.json"
const JSON_PATH_USER = "user://POKEMON_DB.json"

var dialogo_confirmacion
var nombre_pokemon_seleccionado = ""
var id_pokemon_seleccionado = ""
var filtro_busqueda = ""
var filtro_busqueda_pc = ""
var pokemons_db = []
var json_utils = preload("res://SCRIPT/json_utils.gd").new()
var confirm_action = "" # 'capture' or 'move_pc_to_team'

# Referencias a los CheckBox de objetos_unicos
@onready var checkboxes_objetos_unicos := [
	$CanvasLayer/PanelMochila/VBoxContainer/VBoxContainer2/Panel2/uo1,
	$CanvasLayer/PanelMochila/VBoxContainer/VBoxContainer2/Panel2/uo2,
	$CanvasLayer/PanelMochila/VBoxContainer/VBoxContainer2/Panel2/uo3,
	$CanvasLayer/PanelMochila/VBoxContainer/VBoxContainer2/Panel2/uo4,
	$CanvasLayer/PanelMochila/VBoxContainer/VBoxContainer2/Panel2/uo5,
	$CanvasLayer/PanelMochila/VBoxContainer/VBoxContainer2/Panel2/uo6,
	$CanvasLayer/PanelMochila/VBoxContainer/VBoxContainer2/Panel2/uo7,
	$CanvasLayer/PanelMochila/VBoxContainer/VBoxContainer2/Panel2/uo8,
	$CanvasLayer/PanelMochila/VBoxContainer/VBoxContainer2/Panel2/uo9,
	$CanvasLayer/PanelMochila/VBoxContainer/VBoxContainer2/Panel2/uo10,
	$CanvasLayer/PanelMochila/VBoxContainer/VBoxContainer2/Panel2/uo11
]

# Referencias a los SpinBox de inventario
@onready var spinboxes_inventario := [
	$CanvasLayer/PanelMochila/VBoxContainer/VBoxContainer/SC_ITEM/ListaItems/HBoxContainer/POKEBALL,
	$CanvasLayer/PanelMochila/VBoxContainer/VBoxContainer/SC_ITEM/ListaItems/HBoxContainer2/SUPERBALL,
	$CanvasLayer/PanelMochila/VBoxContainer/VBoxContainer/SC_ITEM/ListaItems/HBoxContainer3/ULTRABALL,
	$CanvasLayer/PanelMochila/VBoxContainer/VBoxContainer/SC_ITEM/ListaItems/HBoxContainer4/POCION,
	$CanvasLayer/PanelMochila/VBoxContainer/VBoxContainer/SC_ITEM/ListaItems/HBoxContainer5/SUPER_POCION,
	$CanvasLayer/PanelMochila/VBoxContainer/VBoxContainer/SC_ITEM/ListaItems/HBoxContainer6/CUERDA_HUIDA,
	$CanvasLayer/PanelMochila/VBoxContainer/VBoxContainer/SC_ITEM/ListaItems/HBoxContainer7/CHALECO_ASALTO,
	$CanvasLayer/PanelMochila/VBoxContainer/VBoxContainer/SC_ITEM/ListaItems/HBoxContainer8/CINTA_ELECCION,
	$CanvasLayer/PanelMochila/VBoxContainer/VBoxContainer/SC_ITEM/ListaItems/HBoxContainer9/PUERRO,
	$CanvasLayer/PanelMochila/VBoxContainer/VBoxContainer/SC_ITEM/ListaItems/HBoxContainer10/REVIVIR,
	$CanvasLayer/PanelMochila/VBoxContainer/VBoxContainer/SC_ITEM/ListaItems/HBoxContainer11/PIEDRA_FUEGO,
	$CanvasLayer/PanelMochila/VBoxContainer/VBoxContainer/SC_ITEM/ListaItems/HBoxContainer12/PIEDRA_AGUA,
	$CanvasLayer/PanelMochila/VBoxContainer/VBoxContainer/SC_ITEM/ListaItems/HBoxContainer13/PIEDRA_TRUENO,
	$CanvasLayer/PanelMochila/VBoxContainer/VBoxContainer/SC_ITEM/ListaItems/HBoxContainer14/PIEDRA_HOJA,
	$CanvasLayer/PanelMochila/VBoxContainer/VBoxContainer/SC_ITEM/ListaItems/HBoxContainer15/PIEDRA_LUNAR,
	$CanvasLayer/PanelMochila/VBoxContainer/VBoxContainer/SC_ITEM/ListaItems/HBoxContainer16/RESTAURAR_TODO,
	$CanvasLayer/PanelMochila/VBoxContainer/VBoxContainer/SC_ITEM/ListaItems/HBoxContainer17/REVIVIR_MAXIMO,
	$CanvasLayer/PanelMochila/VBoxContainer/VBoxContainer/SC_ITEM/ListaItems/HBoxContainer18/CARAMELO_RARO
]

# Referencias a los CheckBox de MO
@onready var checkboxes_mo := [
	$CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer/HBoxContainer/Panel/corte,
	$CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer/HBoxContainer/Panel/vuelo,
	$CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer/HBoxContainer/Panel/surf,
	$CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer/HBoxContainer/Panel/fuerza
]

# Referencias a los CheckBox de casillas (35 checkboxes)
@onready var checkboxes_casillas := [
	$"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/11",
	$"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/27", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/33", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/38", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/42", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/56", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/69", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/77", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/84", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/100", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/113", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/124", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/144", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/147", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/161", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/165", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/171", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/179", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/194", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/204", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/207", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/220", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/243", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/280", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/297", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/311", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/320", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/342", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/399", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/445", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/451", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/480", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/488", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/492", $"CanvasLayer/PanelEntrenador/VBoxContainer/VBoxContainer2/HBoxContainer/CASILLAS_OBJETOS/495"
]

func _ready():
	mostrar_seccion("equipo")
	btn_equipo.pressed.connect(func(): mostrar_seccion("equipo"))
	btn_pc.pressed.connect(func(): mostrar_seccion("pc"))
	btn_captura.pressed.connect(func(): mostrar_seccion("captura"))
	btn_mochila.pressed.connect(_on_btn_mochila_pressed)
	btn_cerrar_mochila.pressed.connect(_on_btn_cerrar_mochila_pressed)
	dialogo_confirmacion = $CONFIRMACION
	if barra_busqueda:
		barra_busqueda.text_changed.connect(_on_busqueda_text_changed)
	if busquedaPC:
		busquedaPC.text_changed.connect(_on_busquedaPC_text_changed)
	lista_equipo.id_pressed.connect(_on_ListaEquipo_id_pressed)
	btn_cerrar_popup.pressed.connect(func(): cerrar_popup_tarjeta())
	btn_guardar_popup.pressed.connect(_on_btn_guardar_popup_pressed)
	btn_centro_pokemon.pressed.connect(_on_btn_centro_pokemon_pressed)
	btn_ficha_jugador.pressed.connect(_on_btn_ficha_jugador_pressed)
	btn_cerrar_ficha.pressed.connect(_on_btn_cerrar_ficha_pressed)
	# Conectar la señal 'confirmed' del dialogo de confirmación una sola vez (Godot 4: usar Callable)
	var cb_confirm = Callable(self, "_on_confirmation_dialog_confirmed")
	if not confirmacion.is_connected("confirmed", cb_confirm):
		confirmacion.connect("confirmed", cb_confirm)
	# Forzar el popup a ser modal (opcional, puedes dejarlo en false si prefieres)
	if popup_tarjeta.has_method("set_modal"):
		popup_tarjeta.set_modal(true)
	elif "modal" in popup_tarjeta:
		popup_tarjeta.modal = true
	if alert_guardado:
		alert_guardado.confirmed.connect(_on_alert_guardado_confirmed)
	# Conectar la señal de cierre de la ventana para restaurar la UI
	if popup_tarjeta.has_signal("close_requested"):
		popup_tarjeta.close_requested.connect(cerrar_popup_tarjeta)
	# Modificar el texto del cuadro de curación
	var label_curacion = $PANEL_CONTROL/CONFIRMAR_CURACION.get_label()
	if label_curacion:
		label_curacion.add_theme_font_size_override("font_size", 50)
		label_curacion.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label_curacion.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# Inicializar tamaño y centrado del popup de curación
	var dialog = $PANEL_CONTROL/CONFIRMAR_CURACION
	dialog.set_size(Vector2(400, 200))
	dialog.popup_centered()
	dialog.hide()
	$PANEL_CONTROL/CONFIRMAR_CURACION.confirmed.connect(_on_confirmar_curacion_confirmed)
	animation_player.connect("animation_finished", Callable(self, "_on_animation_finished"))

	# Cargar el JSON una sola vez y reutilizar la variable
	var db = cargar_json()
	# Mostrar el nombre del jugador en el label correspondiente
	if db.has("jugador") and db["jugador"].has("usuario"):
		label_nombre_jugador.text = db["jugador"]["usuario"]
	# Mostrar el dinero actual en el LineEdit (siempre como entero)
	if db.has("jugador") and db["jugador"].has("dinero"):
		lineedit_dinero.text = str(int(db["jugador"]["dinero"]))
	else:
		lineedit_dinero.text = "0"
	# Mostrar la casilla actual en el LineEdit (siempre como entero)
	if db.has("jugador") and db["jugador"].has("casilla_actual"):
		lineedit_casilla_actual.text = str(int(db["jugador"]["casilla_actual"]))
	else:
		lineedit_casilla_actual.text = "0"
	# Conectar el evento de cambio de texto
	lineedit_dinero.text_submitted.connect(_on_dinero_text_submitted)
	lineedit_dinero.focus_exited.connect(_on_dinero_focus_exited)
	lineedit_casilla_actual.text_submitted.connect(_on_casilla_actual_text_submitted)
	lineedit_casilla_actual.focus_exited.connect(_on_casilla_actual_focus_exited)
	# Conectar los CheckBox de objetos_unicos
	for cb in checkboxes_objetos_unicos:
		cb.toggled.connect(_on_objeto_unico_toggled.bind(cb))
	# Al iniciar, cargar el estado desde la base de datos
	if db.has("objetos_unicos"):
		for cb in checkboxes_objetos_unicos:
			var nombre = cb.name
			if db["objetos_unicos"].has(nombre):
				cb.button_pressed = int(db["objetos_unicos"][nombre]) == 1
	# Conectar los SpinBox de inventario
	for sb in spinboxes_inventario:
		# Configurar SpinBox para que solo acepte enteros
		sb.step = 1.0
		sb.rounded = true
		sb.value_changed.connect(_on_inventario_value_changed.bind(sb))
	# Al iniciar, cargar el estado desde la base de datos
	if db.has("inventario"):
		for sb in spinboxes_inventario:
			var nombre = sb.name.to_lower()
			if db["inventario"].has(nombre):
				sb.value = int(db["inventario"][nombre])
	# Conectar los CheckBox de MO
	for cb in checkboxes_mo:
		cb.toggled.connect(_on_mo_toggled.bind(cb))
	# Al iniciar, cargar el estado desde la base de datos
	if db.has("MO"):
		for cb in checkboxes_mo:
			var nombre = cb.name
			if db["MO"].has(nombre):
				cb.button_pressed = int(db["MO"][nombre]) == 1
	# Conectar los CheckBox de casillas
	for cb in checkboxes_casillas:
		cb.toggled.connect(_on_casilla_toggled.bind(cb))
	# Al iniciar, cargar el estado desde la base de datos
	if db.has("casillas"):
		for cb in checkboxes_casillas:
			# El texto del checkbox es el número de casilla (ej: "11", "27", "33")
			var numero_casilla = cb.text
			if db["casillas"].has(numero_casilla):
				cb.button_pressed = int(db["casillas"][numero_casilla]) == 1

func _on_alert_guardado_confirmed():
	# Refresca el banner EXP_ACT en PokemonCardGrande si está visible
	if contenedor_tarjeta.get_child_count() > 0:
		var tarjeta = contenedor_tarjeta.get_child(0)
		if tarjeta and tarjeta.has_node("HBoxContainer/Panel/EXP_ACT") and tarjeta.has_node("HBoxContainer/Panel/EXP_LINE"):
			var exp_actual_label = tarjeta.get_node("HBoxContainer/Panel/EXP_ACT")
			var exp_line_edit = tarjeta.get_node("HBoxContainer/Panel/EXP_LINE")
			if exp_actual_label and exp_line_edit:
				exp_actual_label.text = exp_line_edit.text
	# Habilitar navegación y panel_control al cerrar la alerta
	btn_equipo.disabled = false
	btn_pc.disabled = false
	btn_captura.disabled = false
	set_panel_control_disabled(false)
	if popup_tarjeta and popup_tarjeta.is_inside_tree() and not popup_tarjeta.visible:
		popup_tarjeta.show()

func mostrar_seccion(seccion):
	panel_equipo.visible = (seccion == "equipo")
	panel_pc.visible = (seccion == "pc")
	panel_captura.visible = (seccion == "captura")
	panel_control.visible = (seccion == "equipo")
	panel_vacio.visible = (seccion == "pc" or seccion == "captura")
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
	# Esperar un frame para que se limpien correctamente
	await get_tree().process_frame
	# Configurar columnas del GridContainer (por si acaso)
	if grid_captura.has_method("set_columns"):
		grid_captura.set_columns(2)
	var db = cargar_json()
	var pokemon_lista_captura = db["pokedex"] if db.has("pokedex") else []
	if typeof(pokemon_lista_captura) == TYPE_ARRAY:
		pokemon_lista_captura.sort_custom(func(a, b): return int(a["id"]) < int(b["id"]))
		for poke in pokemon_lista_captura:
			if filtro_busqueda == "" or poke.get("nombre", "").to_lower().find(filtro_busqueda.to_lower()) != -1:
				var tarjeta_escena = load("res://SCENE/PokemonCard.tscn")
				if tarjeta_escena:
					var tarjeta = tarjeta_escena.instantiate()
					var imagen_path = poke.get("img_link", "")
					var ps = poke.get("ps_actual", "")
					if typeof(ps) == TYPE_STRING and ps == "":
						ps = poke.get("ps_max", 0)
					ps = int(ps)
					var ps_max = int(poke.get("ps_max", 0))
					var experiencia_actual = poke.get("exp_actual", "")
					if typeof(experiencia_actual) == TYPE_STRING and experiencia_actual == "":
						experiencia_actual = 0
					experiencia_actual = int(experiencia_actual)
					var exp_max = int(poke.get("exp_evo", 0))
					var atrapado = int(poke.get("atrapado", 0))
					var id_poke = poke.get("id", "")
					# En captura, mostrar_sello = true
					tarjeta.call_deferred("configurar", imagen_path, ps, ps_max, experiencia_actual, exp_max, atrapado, true, poke.get("nombre", ""), false)
					tarjeta.connect("tarjeta_presionada", Callable(self, "mostrar_confirmacion").bind(id_poke, poke.get("nombre", "")))
					grid_captura.add_child(tarjeta)

func mostrar_tarjetas_pc():
	# Eliminar todos los hijos del GridContainer manualmente
	for child in grid_pc.get_children():
		child.queue_free()
	# Esperar un frame para que se limpien correctamente
	await get_tree().process_frame
	# Configurar columnas del GridContainer (por si acaso)
	if grid_pc.has_method("set_columns"):
		grid_pc.set_columns(2)
	var db = cargar_json()
	var pokemon_lista_pc = db["pokedex"] if db.has("pokedex") else []
	if typeof(pokemon_lista_pc) == TYPE_ARRAY:
		pokemon_lista_pc.sort_custom(func(a, b): return int(a["id"]) < int(b["id"]))
		for poke in pokemon_lista_pc:
			if int(poke.get("atrapado", 0)) == 1 and int(poke.get("equipo", 0)) == 0 and (filtro_busqueda_pc == "" or poke.get("nombre", "").to_lower().find(filtro_busqueda_pc.to_lower()) != -1):
				var tarjeta_escena = load("res://SCENE/PokemonCard.tscn")
				if tarjeta_escena:
					var tarjeta = tarjeta_escena.instantiate()
					var imagen_path = poke.get("img_link", "")
					var ps = poke.get("ps_actual", "")
					if typeof(ps) == TYPE_STRING and ps == "":
						ps = poke.get("ps_max", 0)
					ps = int(ps)
					var ps_max = int(poke.get("ps_max", 0))
					var experiencia_actual = poke.get("exp_actual", "")
					if typeof(experiencia_actual) == TYPE_STRING and experiencia_actual == "":
						experiencia_actual = 0
					experiencia_actual = int(experiencia_actual)
					var exp_max = int(poke.get("exp_evo", 0))
					var atrapado = int(poke.get("atrapado", 0))
					# En cada llamada a configurar, agrega el parámetro nombre
					# En PC, mostrar_sello = false, mostrar_barras = true, es_pc = true
					tarjeta.call_deferred("configurar", imagen_path, ps, ps_max, experiencia_actual, exp_max, atrapado, false, poke.get("nombre", ""), true, true)
					tarjeta.connect("tarjeta_presionada", Callable(self, "mostrar_confirmacion_pc").bind(poke.get("id", ""), poke.get("nombre", "")))
					grid_pc.add_child(tarjeta)

func mostrar_tarjetas_equipo():
	# Eliminar todos los hijos del GridContainer manualmente
	for child in grid_equipo.get_children():
		child.queue_free()
	# Esperar un frame para que se limpien correctamente
	await get_tree().process_frame
	# Configurar columnas del GridContainer (por si acaso)
	if grid_equipo.has_method("set_columns"):
		grid_equipo.set_columns(2)
	var db = cargar_json()
	var pokemon_lista_equipo = db["pokedex"] if db.has("pokedex") else []
	if typeof(pokemon_lista_equipo) == TYPE_ARRAY:
		pokemon_lista_equipo.sort_custom(func(a, b): return int(a["equipo"]) < int(b["equipo"]))
		for poke in pokemon_lista_equipo:
			var eq = int(poke.get("equipo", 0))
			if eq > 0 and eq <= 6:
				var tarjeta_escena = load("res://SCENE/PokemonCard.tscn")
				if tarjeta_escena:
					var tarjeta = tarjeta_escena.instantiate()
					var imagen_path = poke.get("img_link", "")
					var ps = poke.get("ps_actual", "")
					if typeof(ps) == TYPE_STRING and ps == "":
						ps = poke.get("ps_max", 0)
					ps = int(ps)
					var ps_max = int(poke.get("ps_max", 0))
					var experiencia_actual = poke.get("exp_actual", "")
					if typeof(experiencia_actual) == TYPE_STRING and experiencia_actual == "":
						experiencia_actual = 0
					experiencia_actual = int(experiencia_actual)
					var exp_max = int(poke.get("exp_evo", 0))
					var atrapado = int(poke.get("atrapado", 0))
					# En equipo, mostrar_sello = false
					tarjeta.call_deferred("configurar", imagen_path, ps, ps_max, experiencia_actual, exp_max, atrapado, false, poke.get("nombre", ""), true)
					tarjeta.connect("tarjeta_presionada", Callable(self, "mostrar_popup_tarjeta_equipo").bind(poke))
					grid_equipo.add_child(tarjeta)

func set_panel_control_disabled(disabled: bool):
	for child in panel_control.get_children():
		if child is Button:
			child.disabled = disabled

func mostrar_popup_tarjeta_equipo(poke):
	if confirmacion and confirmacion.is_inside_tree() and confirmacion.visible:
		confirmacion.hide()
	if popup_tarjeta and popup_tarjeta.is_inside_tree():
		popup_tarjeta.hide()
	# Esperar un frame antes de limpiar para evitar errores de input
	await get_tree().process_frame
	for child in contenedor_tarjeta.get_children():
		if child and child.is_inside_tree():
			child.queue_free()
	# Instanciar la tarjeta grande y configurarla con la imagen del Pokémon
	var tarjeta_escena = load("res://SCENE/PokemonCardGrande.tscn")
	if tarjeta_escena:
		var tarjeta = tarjeta_escena.instantiate()
		var imagen_path = poke.get("img_link", "")
		var ps_max = int(poke.get("ps_max", 0))
		var exp_actual = int(poke.get("exp_actual", 0))
		var ps_actual = poke.get("ps_actual", "")
		if typeof(ps_actual) == TYPE_STRING and ps_actual == "":
			ps_actual = ps_max
		ps_actual = int(ps_actual)
		var id_poke = str(poke.get("id", ""))
		tarjeta.call_deferred("configurar", imagen_path, ps_max, exp_actual, ps_actual, id_poke)
		contenedor_tarjeta.add_child(tarjeta)
	# Deshabilitar navegación y panel_control mientras el popup está abierto
	btn_equipo.disabled = true
	btn_pc.disabled = true
	btn_captura.disabled = true
	set_panel_control_disabled(true)
	if popup_tarjeta and popup_tarjeta.is_inside_tree():
		popup_tarjeta.popup_centered()

func cerrar_popup_tarjeta():
	if popup_tarjeta and popup_tarjeta.is_inside_tree():
		popup_tarjeta.hide()
	# Esperar un frame antes de limpiar los hijos para evitar errores de input
	await get_tree().process_frame
	for child in contenedor_tarjeta.get_children():
		if child and child.is_inside_tree():
			child.queue_free()
	# Habilitar navegación y panel_control al cerrar el popup
	btn_equipo.disabled = false
	btn_pc.disabled = false
	btn_captura.disabled = false
	set_panel_control_disabled(false)

func mostrar_confirmacion(id_pokemon, nombre_pokemon):
	confirm_action = "capture"
	id_pokemon_seleccionado = id_pokemon
	nombre_pokemon_seleccionado = nombre_pokemon
	confirmacion.dialog_text = "\n¿CAPTURASTE A %s?\n" % nombre_pokemon
	if confirmacion and confirmacion.is_inside_tree() and confirmacion.visible:
		confirmacion.hide()
	if confirmacion and confirmacion.is_inside_tree():
		confirmacion.popup_centered()

func mostrar_confirmacion_pc(id_pokemon, nombre_pokemon):
	confirm_action = "move_pc_to_team"
	id_pokemon_seleccionado = id_pokemon
	nombre_pokemon_seleccionado = nombre_pokemon
	var mensaje = "\n¿QUIERES MOVER A\n%s AL EQUIPO?\n" % nombre_pokemon
	confirmacion.dialog_text = mensaje
	if confirmacion and confirmacion.is_inside_tree() and confirmacion.visible:
		confirmacion.hide()
	if confirmacion and confirmacion.is_inside_tree():
		confirmacion.popup_centered()

func mostrar_lista_equipo():
	lista_equipo.clear()
	var db = cargar_json()
	var pokemons_db_local = db["pokedex"] if db.has("pokedex") else []
	if typeof(pokemons_db_local) == TYPE_ARRAY:
		for poke in pokemons_db_local:
			var eq = int(poke.get("equipo", 0))
			if eq > 0 and eq <= 6:
				var texto = "%d - %s" % [eq, poke.get("nombre", "")]
				lista_equipo.add_item(texto)
	if lista_equipo and lista_equipo.is_inside_tree():
		lista_equipo.popup_centered()

func _on_confirmation_dialog_confirmed():
	# Determina la acción en base a confirm_action
	if confirm_action == "move_pc_to_team":
		# Mostrar la lista de equipo para elegir a quién reemplazar
		mostrar_lista_equipo()
		# reset action
		confirm_action = ""
		return
	# Por defecto: captura
	confirm_action = ""
	var db = cargar_json()
	var pokemons_db_local = db["pokedex"] if db.has("pokedex") else []
	var equipo_count = 0
	for poke in pokemons_db_local:
		if int(poke.get("equipo", 0)) > 0 and int(poke.get("equipo", 0)) <= 6:
			equipo_count += 1
	# Buscar el Pokémon capturado
	for poke in pokemons_db_local:
		if str(poke.get("id", "")) == str(id_pokemon_seleccionado):
			poke["atrapado"] = 1
			if equipo_count < 6:
				# Asignar al primer slot disponible
				var slot = 1
				var usados = []
				for p in pokemons_db_local:
					usados.append(int(p.get("equipo", 0)))
				while slot in usados:
					slot += 1
				poke["equipo"] = slot
				poke["ubicacion"] = "equipo"
			else:
				poke["equipo"] = 0
				poke["ubicacion"] = "pc"
			break
	db["pokedex"] = pokemons_db_local
	guardar_json(db)
	mostrar_tarjetas_captura()
	mostrar_tarjetas_equipo()
	mostrar_tarjetas_pc()

func _on_ListaEquipo_id_pressed(index):
	# Obtener el número de equipo y nombre del Pokémon seleccionado en la lista
	var texto = lista_equipo.get_item_text(index)
	var partes = texto.split(" - ")
	if partes.size() != 2:
		return
	var num_equipo = int(partes[0])
	var _nombre_equipo = partes[1]  # No usado pero necesario para el split
	# Leer la base de datos
	var db = cargar_json()
	var pokemon_lista_intercambio = db["pokedex"] if db.has("pokedex") else []
	var id_pc = id_pokemon_seleccionado
	var idx_pc = -1
	var idx_eq = -1
	for i in range(pokemon_lista_intercambio.size()):
		var poke = pokemon_lista_intercambio[i]
		if str(poke.get("id", "")) == str(id_pc):
			idx_pc = i
		if int(poke.get("equipo", 0)) == num_equipo:
			idx_eq = i
	# Intercambiar los valores de 'equipo'
	if idx_pc != -1 and idx_eq != -1:
		var slot = int(pokemon_lista_intercambio[idx_eq]["equipo"])
		pokemon_lista_intercambio[idx_eq]["equipo"] = 0
		pokemon_lista_intercambio[idx_eq]["ubicacion"] = "pc"
		pokemon_lista_intercambio[idx_pc]["equipo"] = slot
		pokemon_lista_intercambio[idx_pc]["ubicacion"] = "equipo"
		# Al pasar al PC, ps_actual = ps_max (entero)
		if pokemon_lista_intercambio[idx_eq].has("ps_max"):
			pokemon_lista_intercambio[idx_eq]["ps_actual"] = int(pokemon_lista_intercambio[idx_eq]["ps_max"])
		# Guardar el JSON actualizado en ambos archivos
		db["pokedex"] = pokemon_lista_intercambio
		guardar_json(db)
		# Refrescar las vistas
		mostrar_tarjetas_pc()
		mostrar_tarjetas_equipo()
	lista_equipo.hide()

func cargar_json():
	var file_path = JSON_PATH_USER
	if not FileAccess.file_exists(file_path):
		# Si no existe el archivo de usuario, copiar el de recursos
		var base_file = FileAccess.open(JSON_PATH_RES, FileAccess.READ)
		var base_text = base_file.get_as_text() if base_file else "{}"
		var user_file = FileAccess.open(file_path, FileAccess.WRITE)
		if user_file:
			user_file.store_string(base_text)
			user_file.close()
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		var json = JSON.parse_string(json_text)
		if typeof(json) == TYPE_DICTIONARY:
			return json
		elif typeof(json) == TYPE_ARRAY:
			return {"pokedex": json}
	return {}

func convertir_a_enteros(valor, key_name = ""):
	# Lista de claves que deben permanecer como string
	var campos_string = ["id", "numero", "img_link", "nombre", "estado", "ubicacion", "usuario", "genero", "avatar", "fecha_inicio", "fecha_ultima"]

	# Función recursiva para convertir todos los números a enteros
	if typeof(valor) == TYPE_DICTIONARY:
		var nuevo_dict = {}
		for key in valor:
			# Pasar el nombre de la clave para verificar si debe ser string
			nuevo_dict[key] = convertir_a_enteros(valor[key], key)
		return nuevo_dict
	elif typeof(valor) == TYPE_ARRAY:
		var nuevo_array = []
		for item in valor:
			nuevo_array.append(convertir_a_enteros(item, key_name))
		return nuevo_array
	elif typeof(valor) == TYPE_FLOAT:
		return int(valor)
	elif typeof(valor) == TYPE_STRING:
		# Si la clave está en la lista de campos que deben ser string, no convertir
		if key_name in campos_string:
			return valor
		# Si es un string que representa un número, convertirlo a entero
		if valor.is_valid_int():
			return int(valor)
		elif valor.is_valid_float():
			return int(float(valor))
		else:
			return valor
	else:
		return valor

func guardar_json(data):
	# Actualizar fecha_ultima dentro de 'jugador' antes de guardar
	if data.has("jugador"):
		# Obtener fecha en formato DD/MM/YYYY (compatible con Android)
		var datetime = Time.get_date_dict_from_system()
		var fecha = "%02d/%02d/%04d" % [datetime["day"], datetime["month"], datetime["year"]]
		print("DEBUG Fecha guardada: ", fecha, " (día:", datetime["day"], " mes:", datetime["month"], " año:", datetime["year"], ")")
		data["jugador"]["fecha_ultima"] = fecha

	# Convertir todos los valores numéricos a enteros antes de guardar
	data = convertir_a_enteros(data)

	# Guardar en user://
	var file_user = FileAccess.open(JSON_PATH_USER, FileAccess.WRITE)
	if file_user:
		file_user.store_string(JSON.stringify(data, "\t"))
		file_user.close()
	# Guardar en res://
	var file_res = FileAccess.open(JSON_PATH_RES, FileAccess.WRITE)
	if file_res:
		file_res.store_string(JSON.stringify(data, "\t"))
		file_res.close()

var popup_confirmacion_actualizacion: AcceptDialog = null
var panel_mensaje_actualizacion: Panel = null

func mostrar_confirmacion_actualizacion():
	if popup_confirmacion_actualizacion:
		popup_confirmacion_actualizacion.queue_free()
	popup_confirmacion_actualizacion = AcceptDialog.new()
	popup_confirmacion_actualizacion.title = ""
	popup_confirmacion_actualizacion.dialog_text = "DATOS ACTUALIZADOS"
	popup_confirmacion_actualizacion.resizable = false
	popup_confirmacion_actualizacion.modal = true
	popup_confirmacion_actualizacion.exclusive = true # Esto evita que se pueda interactuar fuera
	popup_confirmacion_actualizacion.get_ok_button().text = "OK"
	# Deshabilitar cerrar con Escape o clic fuera
	popup_confirmacion_actualizacion.set_close_on_escape(false)
	popup_confirmacion_actualizacion.set_hide_on_ok(true)
	popup_confirmacion_actualizacion.connect("canceled", func(): popup_confirmacion_actualizacion.popup_centered())
	popup_tarjeta.add_child(popup_confirmacion_actualizacion)
	popup_confirmacion_actualizacion.popup_centered()

func mostrar_mensaje_actualizacion():
	if panel_mensaje_actualizacion:
		panel_mensaje_actualizacion.queue_free()
	panel_mensaje_actualizacion = Panel.new()
	panel_mensaje_actualizacion.name = "PanelMensajeActualizacion"
	panel_mensaje_actualizacion.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel_mensaje_actualizacion.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel_mensaje_actualizacion.custom_minimum_size = Vector2(350, 120)
	panel_mensaje_actualizacion.modulate = Color(0.1, 0.1, 0.1, 0.95)
	panel_mensaje_actualizacion.set_anchors_and_margins_preset(Control.PRESET_CENTER)

	var vbox = VBoxContainer.new()
	vbox.anchor_right = 1
	vbox.anchor_bottom = 1
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER

	var label = Label.new()
	label.text = "DATOS ACTUALIZADOS"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 32)
	vbox.add_child(label)

	var btn_ok = Button.new()
	btn_ok.text = "OK"
	btn_ok.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn_ok.pressed.connect(func():
		panel_mensaje_actualizacion.hide()
		panel_mensaje_actualizacion.queue_free()
	)
	vbox.add_child(btn_ok)

	panel_mensaje_actualizacion.add_child(vbox)
	popup_tarjeta.add_child(panel_mensaje_actualizacion)
	panel_mensaje_actualizacion.show()

func _on_btn_guardar_popup_pressed():
	# Obtener la tarjeta grande actual
	if contenedor_tarjeta.get_child_count() == 0:
		return
	var tarjeta = contenedor_tarjeta.get_child(0)
	# Obtener los valores de los LineEdit
	var ps_line = tarjeta.get_node("HBoxContainer/Panel/PS_LINE")
	var exp_line = tarjeta.get_node("HBoxContainer/Panel/EXP_LINE")
	var ps_max_label = tarjeta.get_node("HBoxContainer/Panel/PS_MAX")
	if not ps_line or not exp_line or not ps_max_label:
		return
	var nuevo_ps = int(ps_line.text)
	var ps_max = int(ps_max_label.text)
	if nuevo_ps > ps_max:
		nuevo_ps = ps_max
		ps_line.text = str(ps_max)
	var nueva_exp = int(exp_line.text)
	# Buscar el Pokémon en la base de datos por id
	var id_poke = null
	if tarjeta.has_method("get_id"):
		id_poke = tarjeta.get_id()
	else:
		id_poke = id_pokemon_seleccionado
	if not id_poke:
		return
	var db = cargar_json()
	var pokemons_db_local = db["pokedex"] if db.has("pokedex") else []
	for poke in pokemons_db_local:
		if str(poke.get("id", "")) == str(id_poke):
			poke["ps_actual"] = nuevo_ps
			poke["exp_actual"] = nueva_exp
			break
	db["pokedex"] = pokemons_db_local
	guardar_json(db)
	mostrar_tarjetas_equipo()
	mostrar_tarjetas_pc()
	mostrar_tarjetas_captura()
	# Ocultar el popup de la tarjeta antes de mostrar ALERT_GUARDADO
	popup_tarjeta.hide()
	# Mostrar el mensaje de guardado
	if alert_guardado:
		alert_guardado.dialog_text = "DATOS GUARDADOS"
		var label = alert_guardado.get_label()
		if label:
			label.add_theme_font_size_override("font_size", 50)
		var ok_button = alert_guardado.get_ok_button()
		if ok_button:
			ok_button.add_theme_font_size_override("font_size", 50)
		alert_guardado.popup_centered()

func _on_btn_centro_pokemon_pressed():
	var dialog = $PANEL_CONTROL/CONFIRMAR_CURACION
	dialog.set_size(Vector2(400, 200)) # Tamaño más grande y estándar
	dialog.popup_centered()
	# Hacer los botones SI y NO grandes
	var ok_button = dialog.get_ok_button()
	if ok_button:
		ok_button.add_theme_font_size_override("font_size", 50)
	var cancel_button = dialog.get_cancel_button()
	if cancel_button:
		cancel_button.add_theme_font_size_override("font_size", 50)

func _on_confirmar_curacion_confirmed():
	var db = cargar_json()
	var pokemons_db_local = db["pokedex"] if db.has("pokedex") else []
	var curados = false
	for poke in pokemons_db_local:
		var eq = int(poke.get("equipo", 0))
		if eq > 0 and eq <= 6:
			if poke.has("ps_max"):
				poke["ps_actual"] = int(poke["ps_max"])
				curados = true
	if curados:
		db["pokedex"] = pokemons_db_local
		guardar_json(db)
		mostrar_tarjetas_equipo()
		mostrar_tarjetas_pc()
		mostrar_tarjetas_captura()

func _on_btn_mochila_pressed():
	panel_mochila.show()
	animation_player.play("mostrar_mochila")

func _on_btn_cerrar_mochila_pressed():
	animation_player.play("ocultar_mochila")

func _on_btn_ficha_jugador_pressed():
	animation_player.play("MOSTRAR_FICHA")

func _on_btn_cerrar_ficha_pressed():
	animation_player.play("OCULTAR_FICHA")

func _on_animation_finished(anim_name):
	if anim_name == "ocultar_mochila":
		panel_mochila.hide()

func _on_objeto_unico_toggled(button_pressed, cb):
	var db = cargar_json()
	if not db.has("objetos_unicos"):
		db["objetos_unicos"] = {}
	db["objetos_unicos"][cb.name] = 1 if button_pressed else 0
	guardar_json(db)

func _on_inventario_value_changed(value, sb):
	var db = cargar_json()
	if not db.has("inventario"):
		db["inventario"] = {}
	db["inventario"][sb.name.to_lower()] = int(value)
	guardar_json(db)

func _on_mo_toggled(button_pressed, cb):
	var db = cargar_json()
	if not db.has("MO"):
		db["MO"] = {}
	db["MO"][cb.name] = 1 if button_pressed else 0
	guardar_json(db)

func _on_dinero_text_submitted(nuevo_valor):
	_actualizar_dinero(nuevo_valor)

func _on_dinero_focus_exited():
	_actualizar_dinero(lineedit_dinero.text)

func _actualizar_dinero(valor):
	var db = cargar_json()
	if not db.has("jugador"):
		db["jugador"] = {}
	var dinero = int(valor) if valor.is_valid_int() else 0
	db["jugador"]["dinero"] = dinero
	guardar_json(db)
	lineedit_dinero.text = str(dinero)

func _on_casilla_actual_text_submitted(nuevo_valor):
	_actualizar_casilla_actual(nuevo_valor)

func _on_casilla_actual_focus_exited():
	_actualizar_casilla_actual(lineedit_casilla_actual.text)

func _actualizar_casilla_actual(valor):
	var db = cargar_json()
	if not db.has("jugador"):
		db["jugador"] = {}
	var casilla = int(valor) if valor.is_valid_int() else 0
	db["jugador"]["casilla_actual"] = casilla
	guardar_json(db)
	lineedit_casilla_actual.text = str(casilla)

func _on_casilla_toggled(button_pressed, cb):
	var db = cargar_json()
	if not db.has("casillas"):
		db["casillas"] = {}
	# El texto del checkbox es el número de casilla (ej: "11", "27", "33")
	var numero_casilla = cb.text
	db["casillas"][numero_casilla] = 1 if button_pressed else 0
	guardar_json(db)
