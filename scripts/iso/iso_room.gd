extends Node2D
## Ítem 01 — Shell de habitación: piso isométrico 8×8 con variantes.

signal floor_changed(variant_id: String)

const ROOM_SIZE := Vector2i(8, 8)

@onready var room_root: Node2D = $RoomRoot
@onready var floor_layer: Node2D = $RoomRoot/FloorLayer
@onready var hud: CanvasLayer = $IsoHUD
@onready var title_label: Label = $IsoHUD/Safe/VBox/Title
@onready var hint_label: Label = $IsoHUD/Safe/VBox/Hint
@onready var variant_bar: HBoxContainer = $IsoHUD/Safe/VBox/VariantBar

var _floor_textures: Dictionary = {}
var _tiles: Dictionary = {} # "x,y" -> Sprite2D
var _current_variant: String = "floor_wood_light"

var _variants := [
	{"id": "floor_wood_light", "name": "Madera clara"},
	{"id": "floor_wood_warm", "name": "Madera cálida"},
	{"id": "floor_pastel_blue", "name": "Azul suave"},
]


func _ready() -> void:
	_load_textures()
	_center_room()
	_build_floor()
	_build_variant_buttons()
	title_label.text = "Casa de Gatos — Cuarto iso"
	hint_label.text = "Ítem 01: Piso base · toca una variante"
	set_floor_variant(_current_variant)


func _load_textures() -> void:
	for v in _variants:
		var path := "res://assets/art/iso/floors/%s.png" % str(v["id"])
		_floor_textures[str(v["id"])] = load(path)


func _center_room() -> void:
	# Centra el diamante 8×8 en el viewport 720×1280.
	var mid := Vector2i(ROOM_SIZE.x / 2, ROOM_SIZE.y / 2)
	var mid_screen := IsoMath.grid_to_screen(mid)
	room_root.position = Vector2(360, 520) - mid_screen


func _build_floor() -> void:
	for child in floor_layer.get_children():
		child.queue_free()
	_tiles.clear()
	for y in ROOM_SIZE.y:
		for x in ROOM_SIZE.x:
			var sprite := Sprite2D.new()
			sprite.centered = false
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			sprite.position = IsoMath.grid_to_screen(Vector2i(x, y))
			# Offset para que el diamante quede anclado al top del tile.
			sprite.position -= Vector2(IsoMath.TILE_W / 2, 0)
			sprite.z_index = x + y
			floor_layer.add_child(sprite)
			_tiles["%d,%d" % [x, y]] = sprite


func _build_variant_buttons() -> void:
	for child in variant_bar.get_children():
		child.queue_free()
	for v in _variants:
		var button := Button.new()
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(0, 64)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 18)
		button.text = str(v["name"])
		var id := str(v["id"])
		button.pressed.connect(func() -> void:
			set_floor_variant(id)
		)
		variant_bar.add_child(button)


func set_floor_variant(variant_id: String) -> void:
	if not _floor_textures.has(variant_id):
		return
	_current_variant = variant_id
	var tex: Texture2D = _floor_textures[variant_id]
	for key in _tiles.keys():
		var sprite: Sprite2D = _tiles[key]
		sprite.texture = tex
	var nice := variant_id
	for v in _variants:
		if str(v["id"]) == variant_id:
			nice = str(v["name"])
			break
	hint_label.text = "Piso: %s" % nice
	floor_changed.emit(variant_id)


func get_current_floor_variant() -> String:
	return _current_variant
