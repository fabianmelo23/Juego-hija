extends Node2D
## Shell isométrico — Ítem 01 piso + Ítem 02 pared izquierda.

signal floor_changed(variant_id: String)
signal wall_left_changed(variant_id: String)

const ROOM_SIZE := Vector2i(8, 8)
const WALL_HEIGHT := 64

@onready var room_root: Node2D = $RoomRoot
@onready var floor_layer: Node2D = $RoomRoot/FloorLayer
@onready var wall_left_layer: Node2D = $RoomRoot/WallLeftLayer
@onready var title_label: Label = $IsoHUD/Safe/VBox/Title
@onready var hint_label: Label = $IsoHUD/Safe/VBox/Hint
@onready var tab_bar: HBoxContainer = $IsoHUD/Safe/VBox/TabBar
@onready var variant_bar: HBoxContainer = $IsoHUD/Safe/VBox/VariantBar

var _floor_textures: Dictionary = {}
var _wall_left_textures: Dictionary = {}
var _floor_tiles: Dictionary = {}
var _wall_left_tiles: Array[Sprite2D] = []

var _current_floor: String = "floor_wood_light"
var _current_wall_left: String = "wall_left_cream"
var _edit_target: String = "floor" # floor | wall_left

var _floor_variants := [
	{"id": "floor_wood_light", "name": "Madera clara"},
	{"id": "floor_wood_warm", "name": "Madera cálida"},
	{"id": "floor_pastel_blue", "name": "Azul suave"},
]

var _wall_left_variants := [
	{"id": "wall_left_cream", "name": "Crema"},
	{"id": "wall_left_blush", "name": "Rubor"},
	{"id": "wall_left_sage", "name": "Salvia"},
]


func _ready() -> void:
	_load_textures()
	_center_room()
	_build_floor()
	_build_wall_left()
	_build_tabs()
	_rebuild_variant_buttons()
	title_label.text = "Casa de Gatos — Cuarto iso"
	set_floor_variant(_current_floor)
	set_wall_left_variant(_current_wall_left)
	_set_edit_target("wall_left")


func _load_textures() -> void:
	for v in _floor_variants:
		var path := "res://assets/art/iso/floors/%s.png" % str(v["id"])
		_floor_textures[str(v["id"])] = load(path)
	for v in _wall_left_variants:
		var path := "res://assets/art/iso/walls/%s.png" % str(v["id"])
		_wall_left_textures[str(v["id"])] = load(path)


func _center_room() -> void:
	var mid := Vector2i(ROOM_SIZE.x / 2, ROOM_SIZE.y / 2)
	var mid_screen := IsoMath.grid_to_screen(mid)
	room_root.position = Vector2(360, 560) - mid_screen


func _build_floor() -> void:
	for child in floor_layer.get_children():
		child.queue_free()
	_floor_tiles.clear()
	for y in ROOM_SIZE.y:
		for x in ROOM_SIZE.x:
			var sprite := Sprite2D.new()
			sprite.centered = false
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			sprite.position = IsoMath.grid_to_screen(Vector2i(x, y)) - Vector2(IsoMath.TILE_W / 2, 0)
			sprite.z_index = 10 + x + y
			floor_layer.add_child(sprite)
			_floor_tiles["%d,%d" % [x, y]] = sprite


func _build_wall_left() -> void:
	for child in wall_left_layer.get_children():
		child.queue_free()
	_wall_left_tiles.clear()
	# Pared oeste: una columna a lo largo de x = 0.
	for y in ROOM_SIZE.y:
		var sprite := Sprite2D.new()
		sprite.centered = false
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var anchor := IsoMath.grid_to_screen(Vector2i(0, y))
		# Ancla al borde izquierdo del diamante del piso.
		sprite.position = anchor - Vector2(IsoMath.TILE_W / 2, WALL_HEIGHT)
		sprite.z_index = 5 + y # detrás del piso de esa fila
		wall_left_layer.add_child(sprite)
		_wall_left_tiles.append(sprite)


func _build_tabs() -> void:
	for child in tab_bar.get_children():
		child.queue_free()
	_add_tab_button("Piso", "floor")
	_add_tab_button("Pared izq.", "wall_left")


func _add_tab_button(label: String, target: String) -> void:
	var button := Button.new()
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(0, 52)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 20)
	button.text = label
	button.pressed.connect(func() -> void:
		_set_edit_target(target)
	)
	tab_bar.add_child(button)


func _set_edit_target(target: String) -> void:
	_edit_target = target
	_rebuild_variant_buttons()
	if target == "floor":
		hint_label.text = "Editando: Piso · %s" % _nice_name(_floor_variants, _current_floor)
	else:
		hint_label.text = "Editando: Pared izquierda · %s" % _nice_name(_wall_left_variants, _current_wall_left)


func _rebuild_variant_buttons() -> void:
	for child in variant_bar.get_children():
		child.queue_free()
	var list: Array = _floor_variants if _edit_target == "floor" else _wall_left_variants
	for v in list:
		var button := Button.new()
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(0, 64)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 18)
		button.text = str(v["name"])
		var id := str(v["id"])
		button.pressed.connect(func() -> void:
			if _edit_target == "floor":
				set_floor_variant(id)
			else:
				set_wall_left_variant(id)
		)
		variant_bar.add_child(button)


func set_floor_variant(variant_id: String) -> void:
	if not _floor_textures.has(variant_id):
		return
	_current_floor = variant_id
	var tex: Texture2D = _floor_textures[variant_id]
	for key in _floor_tiles.keys():
		(_floor_tiles[key] as Sprite2D).texture = tex
	if _edit_target == "floor":
		hint_label.text = "Editando: Piso · %s" % _nice_name(_floor_variants, variant_id)
	floor_changed.emit(variant_id)


func set_wall_left_variant(variant_id: String) -> void:
	if not _wall_left_textures.has(variant_id):
		return
	_current_wall_left = variant_id
	var tex: Texture2D = _wall_left_textures[variant_id]
	for sprite in _wall_left_tiles:
		sprite.texture = tex
	if _edit_target == "wall_left":
		hint_label.text = "Editando: Pared izquierda · %s" % _nice_name(_wall_left_variants, variant_id)
	wall_left_changed.emit(variant_id)


func get_current_floor_variant() -> String:
	return _current_floor


func get_current_wall_left_variant() -> String:
	return _current_wall_left


func _nice_name(list: Array, id: String) -> String:
	for v in list:
		if str(v["id"]) == id:
			return str(v["name"])
	return id
