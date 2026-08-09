extends Node2D
## Shell isométrico + Ítem 07 ventana pequeña.

signal floor_changed(variant_id: String)
signal wall_left_changed(variant_id: String)
signal wall_right_changed(variant_id: String)
signal window_changed(variant_id: String)

const ROOM_SIZE := Vector2i(8, 8)
const WALL_HEIGHT := 64
const WINDOW_SLOT_X := 3 # posición en la pared derecha

@onready var room_root: Node2D = $RoomRoot
@onready var floor_layer: Node2D = $RoomRoot/FloorLayer
@onready var wall_left_layer: Node2D = $RoomRoot/WallLeftLayer
@onready var wall_right_layer: Node2D = $RoomRoot/WallRightLayer
@onready var window_layer: Node2D = $RoomRoot/WindowLayer
@onready var background: Polygon2D = $Background
@onready var title_label: Label = $IsoHUD/Safe/VBox/Title
@onready var hint_label: Label = $IsoHUD/Safe/VBox/Hint
@onready var tab_bar: HBoxContainer = $IsoHUD/Safe/VBox/TabBar
@onready var variant_bar: HBoxContainer = $IsoHUD/Safe/VBox/VariantBar

var _floor_textures: Dictionary = {}
var _wall_left_textures: Dictionary = {}
var _wall_right_textures: Dictionary = {}
var _window_textures: Dictionary = {}
var _floor_tiles: Dictionary = {}
var _wall_left_tiles: Array[Sprite2D] = []
var _wall_right_tiles: Array[Sprite2D] = []
var _window_sprite: Sprite2D

var _current_floor: String = "floor_wood_light"
var _current_wall_left: String = "wall_left_cream"
var _current_wall_right: String = "wall_right_cream"
var _current_window: String = "window_small_day"
var _edit_target: String = "window"

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

var _wall_right_variants := [
	{"id": "wall_right_cream", "name": "Crema"},
	{"id": "wall_right_blush", "name": "Rubor"},
	{"id": "wall_right_sage", "name": "Salvia"},
]

var _window_variants := [
	{"id": "window_small_day", "name": "Día"},
	{"id": "window_small_evening", "name": "Tarde"},
	{"id": "window_small_night", "name": "Noche"},
]


func _ready() -> void:
	_load_textures()
	_center_room()
	_build_floor()
	_build_wall_left()
	_build_wall_right()
	_build_window()
	_build_tabs()
	_rebuild_variant_buttons()
	title_label.text = "Casa de Gatos — Cuarto iso"
	set_floor_variant(_current_floor)
	set_wall_left_variant(_current_wall_left)
	set_wall_right_variant(_current_wall_right)
	set_window_variant(_current_window)
	_set_edit_target("window")


func _load_textures() -> void:
	for v in _floor_variants:
		_floor_textures[str(v["id"])] = load("res://assets/art/iso/floors/%s.png" % str(v["id"]))
	for v in _wall_left_variants:
		_wall_left_textures[str(v["id"])] = load("res://assets/art/iso/walls/%s.png" % str(v["id"]))
	for v in _wall_right_variants:
		_wall_right_textures[str(v["id"])] = load("res://assets/art/iso/walls/%s.png" % str(v["id"]))
	for v in _window_variants:
		_window_textures[str(v["id"])] = load("res://assets/art/iso/windows/%s.png" % str(v["id"]))


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
	for y in ROOM_SIZE.y:
		var sprite := Sprite2D.new()
		sprite.centered = false
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var anchor := IsoMath.grid_to_screen(Vector2i(0, y))
		sprite.position = anchor - Vector2(IsoMath.TILE_W / 2, WALL_HEIGHT)
		sprite.z_index = 5 + y
		wall_left_layer.add_child(sprite)
		_wall_left_tiles.append(sprite)


func _build_wall_right() -> void:
	for child in wall_right_layer.get_children():
		child.queue_free()
	_wall_right_tiles.clear()
	for x in ROOM_SIZE.x:
		var sprite := Sprite2D.new()
		sprite.centered = false
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var anchor := IsoMath.grid_to_screen(Vector2i(x, 0))
		sprite.position = anchor - Vector2(0, WALL_HEIGHT)
		sprite.z_index = 4 + x
		wall_right_layer.add_child(sprite)
		_wall_right_tiles.append(sprite)


func _build_window() -> void:
	for child in window_layer.get_children():
		child.queue_free()
	_window_sprite = Sprite2D.new()
	_window_sprite.centered = false
	_window_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var anchor := IsoMath.grid_to_screen(Vector2i(WINDOW_SLOT_X, 0))
	# Sobre la pared derecha, un poco centrada en el panel.
	_window_sprite.position = anchor + Vector2(2, -WALL_HEIGHT + 10)
	_window_sprite.z_index = 6 + WINDOW_SLOT_X
	window_layer.add_child(_window_sprite)


func _build_tabs() -> void:
	for child in tab_bar.get_children():
		child.queue_free()
	_add_tab_button("Piso", "floor")
	_add_tab_button("P.izq", "wall_left")
	_add_tab_button("P.der", "wall_right")
	_add_tab_button("Ventana", "window")


func _add_tab_button(label: String, target: String) -> void:
	var button := Button.new()
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(0, 52)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 16)
	button.text = label
	button.pressed.connect(func() -> void:
		_set_edit_target(target)
	)
	tab_bar.add_child(button)


func _set_edit_target(target: String) -> void:
	_edit_target = target
	_rebuild_variant_buttons()
	match target:
		"floor":
			hint_label.text = "Editando: Piso · %s" % _nice_name(_floor_variants, _current_floor)
		"wall_left":
			hint_label.text = "Editando: Pared izquierda · %s" % _nice_name(_wall_left_variants, _current_wall_left)
		"wall_right":
			hint_label.text = "Editando: Pared derecha · %s" % _nice_name(_wall_right_variants, _current_wall_right)
		"window":
			hint_label.text = "Editando: Ventana · %s" % _nice_name(_window_variants, _current_window)


func _variants_for_target() -> Array:
	match _edit_target:
		"wall_left":
			return _wall_left_variants
		"wall_right":
			return _wall_right_variants
		"window":
			return _window_variants
		_:
			return _floor_variants


func _rebuild_variant_buttons() -> void:
	for child in variant_bar.get_children():
		child.queue_free()
	for v in _variants_for_target():
		var button := Button.new()
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(0, 64)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 18)
		button.text = str(v["name"])
		var id := str(v["id"])
		button.pressed.connect(func() -> void:
			match _edit_target:
				"floor":
					set_floor_variant(id)
				"wall_left":
					set_wall_left_variant(id)
				"wall_right":
					set_wall_right_variant(id)
				"window":
					set_window_variant(id)
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


func set_wall_right_variant(variant_id: String) -> void:
	if not _wall_right_textures.has(variant_id):
		return
	_current_wall_right = variant_id
	var tex: Texture2D = _wall_right_textures[variant_id]
	for sprite in _wall_right_tiles:
		sprite.texture = tex
	if _edit_target == "wall_right":
		hint_label.text = "Editando: Pared derecha · %s" % _nice_name(_wall_right_variants, variant_id)
	wall_right_changed.emit(variant_id)


func set_window_variant(variant_id: String) -> void:
	if not _window_textures.has(variant_id) or _window_sprite == null:
		return
	_current_window = variant_id
	_window_sprite.texture = _window_textures[variant_id]
	_apply_window_mood(variant_id)
	if _edit_target == "window":
		hint_label.text = "Editando: Ventana · %s" % _nice_name(_window_variants, variant_id)
	window_changed.emit(variant_id)


func _apply_window_mood(variant_id: String) -> void:
	match variant_id:
		"window_small_evening":
			background.color = Color(0.90, 0.78, 0.68, 1)
		"window_small_night":
			background.color = Color(0.35, 0.42, 0.55, 1)
		_:
			background.color = Color(0.78, 0.86, 0.90, 1)


func get_current_floor_variant() -> String:
	return _current_floor


func get_current_wall_left_variant() -> String:
	return _current_wall_left


func get_current_wall_right_variant() -> String:
	return _current_wall_right


func get_current_window_variant() -> String:
	return _current_window


func _nice_name(list: Array, id: String) -> String:
	for v in list:
		if str(v["id"]) == id:
			return str(v["name"])
	return id
