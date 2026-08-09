extends Node2D
## Cuarto isométrico: decorar + cuidar a Miel.

signal floor_changed(variant_id: String)
signal wall_left_changed(variant_id: String)
signal wall_right_changed(variant_id: String)
signal window_changed(variant_id: String)
signal light_changed(variant_id: String)
signal wallpaper_changed(variant_id: String)
signal rug_changed(variant_id: String)
signal bed_changed(variant_id: String)
signal bowl_changed(variant_id: String)
signal scratcher_changed(variant_id: String)
signal toy_changed(variant_id: String)

const ROOM_SIZE := Vector2i(8, 8)
const WALL_HEIGHT := 64
const WINDOW_SLOT_X := 3 # posición en la pared derecha
const RUG_ORIGIN := Vector2i(3, 3) # huella 2×2
const BED_ORIGIN := Vector2i(5, 2) # huella ~2×2
const BOWL_ORIGIN := Vector2i(2, 5) # huella 1×1
const SCRATCHER_ORIGIN := Vector2i(1, 2) # huella 1×2
const TOY_ORIGIN := Vector2i(4, 5) # huella 1×1

@onready var room_root: Node2D = $RoomRoot
@onready var floor_layer: Node2D = $RoomRoot/FloorLayer
@onready var rug_layer: Node2D = $RoomRoot/RugLayer
@onready var furniture_layer: Node2D = $RoomRoot/FurnitureLayer
@onready var wall_left_layer: Node2D = $RoomRoot/WallLeftLayer
@onready var wall_right_layer: Node2D = $RoomRoot/WallRightLayer
@onready var wallpaper_left_layer: Node2D = $RoomRoot/WallpaperLeftLayer
@onready var wallpaper_right_layer: Node2D = $RoomRoot/WallpaperRightLayer
@onready var window_layer: Node2D = $RoomRoot/WindowLayer
@onready var light_layer: Node2D = $RoomRoot/LightLayer
@onready var background: Polygon2D = $Background
@onready var title_label: Label = $IsoHUD/Safe/VBox/TopRow/Title
@onready var gameplay: Node = $Gameplay
@onready var hint_label: Label = $IsoHUD/Safe/VBox/Hint
@onready var tab_bar: HBoxContainer = $IsoHUD/Safe/VBox/TabBar
@onready var item_tab_bar: HBoxContainer = $IsoHUD/Safe/VBox/ItemTabBar
@onready var variant_bar: HBoxContainer = $IsoHUD/Safe/VBox/VariantBar

var _floor_textures: Dictionary = {}
var _wall_left_textures: Dictionary = {}
var _wall_right_textures: Dictionary = {}
var _window_textures: Dictionary = {}
var _light_textures: Dictionary = {}
var _wallpaper_left_textures: Dictionary = {}
var _wallpaper_right_textures: Dictionary = {}
var _rug_textures: Dictionary = {}
var _bed_textures: Dictionary = {}
var _bowl_textures: Dictionary = {}
var _scratcher_textures: Dictionary = {}
var _toy_textures: Dictionary = {}
var _floor_tiles: Dictionary = {}
var _wall_left_tiles: Array[Sprite2D] = []
var _wall_right_tiles: Array[Sprite2D] = []
var _wallpaper_left_tiles: Array[Sprite2D] = []
var _wallpaper_right_tiles: Array[Sprite2D] = []
var _window_sprite: Sprite2D
var _light_sprite: Sprite2D
var _rug_sprite: Sprite2D
var _bed_sprite: Sprite2D
var _bowl_sprite: Sprite2D
var _scratcher_sprite: Sprite2D
var _toy_sprite: Sprite2D

var _current_floor: String = "floor_wood_light"
var _current_wall_left: String = "wall_left_cream"
var _current_wall_right: String = "wall_right_cream"
var _current_window: String = "window_small_day"
var _current_light: String = "light_ceiling_warm"
var _current_wallpaper: String = "wallpaper_none"
var _current_rug: String = "rug_small_blush"
var _current_bed: String = "bed_cat_none"
var _current_bowl: String = "bowl_food_full"
var _current_scratcher: String = "scratcher_wood"
var _current_toy: String = "toy_ball_red"
var _edit_target: String = "floor"
var _placed_notified: Dictionary = {}
var _gameplay_ready: bool = false

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

var _light_variants := [
	{"id": "light_ceiling_warm", "name": "Cálida"},
	{"id": "light_ceiling_rose", "name": "Rosa"},
	{"id": "light_ceiling_off", "name": "Apagada"},
]

var _wallpaper_variants := [
	{"id": "wallpaper_none", "name": "Ninguno"},
	{"id": "wallpaper_dots", "name": "Puntos"},
	{"id": "wallpaper_stripe", "name": "Rayas"},
]

var _rug_variants := [
	{"id": "rug_small_none", "name": "Ninguna"},
	{"id": "rug_small_blush", "name": "Rubor"},
	{"id": "rug_small_sage", "name": "Salvia"},
	{"id": "rug_small_sky", "name": "Cielo"},
]

var _bed_variants := [
	{"id": "bed_cat_none", "name": "Ninguna"},
	{"id": "bed_cat_cream", "name": "Crema"},
	{"id": "bed_cat_blush", "name": "Rubor"},
	{"id": "bed_cat_mint", "name": "Menta"},
]

var _bowl_variants := [
	{"id": "bowl_food_none", "name": "Ninguno"},
	{"id": "bowl_food_full", "name": "Lleno"},
	{"id": "bowl_food_half", "name": "Medio"},
	{"id": "bowl_food_empty", "name": "Vacío"},
]

var _scratcher_variants := [
	{"id": "scratcher_none", "name": "Ninguno"},
	{"id": "scratcher_wood", "name": "Madera"},
	{"id": "scratcher_blush", "name": "Rubor"},
	{"id": "scratcher_mint", "name": "Menta"},
]

var _toy_variants := [
	{"id": "toy_ball_none", "name": "Ninguna"},
	{"id": "toy_ball_red", "name": "Roja"},
	{"id": "toy_ball_sky", "name": "Cielo"},
	{"id": "toy_ball_sun", "name": "Sol"},
]


func _ready() -> void:
	_load_textures()
	_center_room()
	_build_floor()
	_build_wall_left()
	_build_wall_right()
	_build_wallpaper()
	_build_window()
	_build_light()
	_build_rug()
	_build_bed()
	_build_bowl()
	_build_scratcher()
	_build_toy()
	_build_tabs()
	_rebuild_variant_buttons()
	title_label.text = "Casa de Gatos"
	set_floor_variant(_current_floor)
	set_wall_left_variant(_current_wall_left)
	set_wall_right_variant(_current_wall_right)
	set_wallpaper_variant(_current_wallpaper)
	set_window_variant(_current_window)
	set_light_variant(_current_light)
	set_rug_variant(_current_rug)
	set_bed_variant(_current_bed)
	set_bowl_variant(_current_bowl)
	set_scratcher_variant(_current_scratcher)
	set_toy_variant(_current_toy)
	_set_edit_target("floor")
	_setup_gameplay()



func _setup_gameplay() -> void:
	gameplay.mode_bar = $IsoHUD/Safe/VBox/ModeBar
	gameplay.decorate_tabs = [
		$IsoHUD/Safe/VBox/TabBar,
		$IsoHUD/Safe/VBox/ItemTabBar,
		$IsoHUD/Safe/VBox/VariantBar,
	]
	gameplay.care_panel = $IsoHUD/Safe/VBox/CarePanel
	gameplay.care_bar = $IsoHUD/Safe/VBox/CareBar
	gameplay.mission_panel = $IsoHUD/Safe/MissionPanel
	gameplay.shop_panel = $IsoHUD/Safe/ShopPanel
	gameplay.toast_label = $IsoHUD/Safe/VBox/Toast
	gameplay.huellitas_label = $IsoHUD/Safe/VBox/TopRow/HuellitasLabel
	gameplay.mission_hint = $IsoHUD/Safe/VBox/MissionHint
	gameplay.hunger_bar = $IsoHUD/Safe/VBox/CarePanel/VBox/HungerRow/HungerBar
	gameplay.energy_bar = $IsoHUD/Safe/VBox/CarePanel/VBox/EnergyRow/EnergyBar
	gameplay.happiness_bar = $IsoHUD/Safe/VBox/CarePanel/VBox/HappyRow/HappyBar
	gameplay.cat_title = $IsoHUD/Safe/VBox/CarePanel/VBox/CatTitle
	gameplay.mission_title = $IsoHUD/Safe/MissionPanel/VBox/MissionTitle
	gameplay.mission_progress = $IsoHUD/Safe/MissionPanel/VBox/MissionProgress
	gameplay.mission_detail = $IsoHUD/Safe/MissionPanel/VBox/MissionDetail
	gameplay.mission_reward = $IsoHUD/Safe/MissionPanel/VBox/MissionReward
	$IsoHUD/Safe/MissionPanel/VBox/CloseMission.pressed.connect(gameplay.close_mission)
	$IsoHUD/Safe/ShopPanel/VBox/CloseShop.pressed.connect(gameplay.close_shop)
	_build_mode_bar()
	_build_care_bar()
	gameplay.setup(self)
	_gameplay_ready = true
	title_label.text = "Casa de Gatos"


func _build_mode_bar() -> void:
	var bar: HBoxContainer = $IsoHUD/Safe/VBox/ModeBar
	for child in bar.get_children():
		child.queue_free()
	for label_target in [["Cuidar", "care"], ["Decorar", "decorate"], ["Misión", "mission"], ["Tienda", "shop"]]:
		var button := Button.new()
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(0, 48)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 15)
		button.text = label_target[0]
		var target := str(label_target[1])
		button.pressed.connect(func() -> void:
			match target:
				"care":
					gameplay.set_mode("care")
					hint_label.text = "Toca a Miel para cuidarla"
				"decorate":
					gameplay.set_mode("decorate")
					hint_label.text = "Elige qué quieres cambiar"
					_set_edit_target(_edit_target)
				"mission":
					gameplay.open_mission()
				"shop":
					gameplay.open_shop()
		)
		bar.add_child(button)


func _build_care_bar() -> void:
	var bar: HBoxContainer = $IsoHUD/Safe/VBox/CareBar
	for child in bar.get_children():
		child.queue_free()
	for label_action in [["Comer", "feed"], ["Mimos", "pet"], ["Jugar", "play"], ["Dormir", "sleep"]]:
		var button := Button.new()
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(0, 56)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 16)
		button.text = label_action[0]
		var action := str(label_action[1])
		button.pressed.connect(func() -> void:
			gameplay.do_care(action)
		)
		bar.add_child(button)


func _unhandled_input(event: InputEvent) -> void:
	var tap_pos: Variant = null
	if event is InputEventScreenTouch and event.pressed:
		tap_pos = event.position
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		tap_pos = event.position
	if tap_pos != null:
		if gameplay.handle_tap(tap_pos):
			get_viewport().set_input_as_handled()


func on_cat_fed() -> void:
	# El plato se vacía un poco al comer.
	match _current_bowl:
		"bowl_food_full":
			set_bowl_variant("bowl_food_half")
		"bowl_food_half":
			set_bowl_variant("bowl_food_empty")


func _notify_place_once(item_id: String, is_present: bool) -> void:
	if not _gameplay_ready or not is_present:
		return
	if bool(_placed_notified.get(item_id, false)):
		return
	_placed_notified[item_id] = true
	gameplay.notify_furniture_placed(item_id)


func _load_textures() -> void:
	for v in _floor_variants:
		_floor_textures[str(v["id"])] = load("res://assets/art/iso/floors/%s.png" % str(v["id"]))
	for v in _wall_left_variants:
		_wall_left_textures[str(v["id"])] = load("res://assets/art/iso/walls/%s.png" % str(v["id"]))
	for v in _wall_right_variants:
		_wall_right_textures[str(v["id"])] = load("res://assets/art/iso/walls/%s.png" % str(v["id"]))
	for v in _window_variants:
		_window_textures[str(v["id"])] = load("res://assets/art/iso/windows/%s.png" % str(v["id"]))
	for v in _light_variants:
		_light_textures[str(v["id"])] = load("res://assets/art/iso/lights/%s.png" % str(v["id"]))
	for v in _wallpaper_variants:
		var wid := str(v["id"])
		if wid == "wallpaper_none":
			_wallpaper_left_textures[wid] = null
			_wallpaper_right_textures[wid] = null
		else:
			var style := wid.replace("wallpaper_", "")
			_wallpaper_left_textures[wid] = load("res://assets/art/iso/wallpaper/wallpaper_left_%s.png" % style)
			_wallpaper_right_textures[wid] = load("res://assets/art/iso/wallpaper/wallpaper_right_%s.png" % style)
	for v in _rug_variants:
		var rid := str(v["id"])
		if rid == "rug_small_none":
			_rug_textures[rid] = null
		else:
			_rug_textures[rid] = load("res://assets/art/iso/rugs/%s.png" % rid)
	for v in _bed_variants:
		var bid := str(v["id"])
		if bid == "bed_cat_none":
			_bed_textures[bid] = null
		else:
			_bed_textures[bid] = load("res://assets/art/iso/furniture/%s.png" % bid)
	for v in _bowl_variants:
		var oid := str(v["id"])
		if oid == "bowl_food_none":
			_bowl_textures[oid] = null
		else:
			_bowl_textures[oid] = load("res://assets/art/iso/furniture/%s.png" % oid)
	for v in _scratcher_variants:
		var sid := str(v["id"])
		if sid == "scratcher_none":
			_scratcher_textures[sid] = null
		else:
			_scratcher_textures[sid] = load("res://assets/art/iso/furniture/%s.png" % sid)
	for v in _toy_variants:
		var tid := str(v["id"])
		if tid == "toy_ball_none":
			_toy_textures[tid] = null
		else:
			_toy_textures[tid] = load("res://assets/art/iso/furniture/%s.png" % tid)


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



func _build_wallpaper() -> void:
	for child in wallpaper_left_layer.get_children():
		child.queue_free()
	for child in wallpaper_right_layer.get_children():
		child.queue_free()
	_wallpaper_left_tiles.clear()
	_wallpaper_right_tiles.clear()
	for y in ROOM_SIZE.y:
		var sprite := Sprite2D.new()
		sprite.centered = false
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var anchor := IsoMath.grid_to_screen(Vector2i(0, y))
		sprite.position = anchor - Vector2(IsoMath.TILE_W / 2, WALL_HEIGHT)
		sprite.z_index = 5 + y + 1
		wallpaper_left_layer.add_child(sprite)
		_wallpaper_left_tiles.append(sprite)
	for x in ROOM_SIZE.x:
		var sprite := Sprite2D.new()
		sprite.centered = false
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var anchor := IsoMath.grid_to_screen(Vector2i(x, 0))
		sprite.position = anchor - Vector2(0, WALL_HEIGHT)
		sprite.z_index = 4 + x + 1
		wallpaper_right_layer.add_child(sprite)
		_wallpaper_right_tiles.append(sprite)


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


func _build_light() -> void:
	for child in light_layer.get_children():
		child.queue_free()
	_light_sprite = Sprite2D.new()
	_light_sprite.centered = false
	_light_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# Cuelga cerca del centro del cuarto.
	var anchor := IsoMath.grid_to_screen(Vector2i(ROOM_SIZE.x / 2, ROOM_SIZE.y / 2))
	_light_sprite.position = anchor + Vector2(-14, -118)
	_light_sprite.z_index = 80
	light_layer.add_child(_light_sprite)



func _build_rug() -> void:
	for child in rug_layer.get_children():
		child.queue_free()
	_rug_sprite = Sprite2D.new()
	_rug_sprite.centered = false
	_rug_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var anchor := IsoMath.grid_to_screen(RUG_ORIGIN)
	# PNG 128×72 con 4px de padding superior sobre el diamante 2×2.
	_rug_sprite.position = anchor - Vector2(64, 4)
	_rug_sprite.z_index = 20 + RUG_ORIGIN.x + RUG_ORIGIN.y
	rug_layer.add_child(_rug_sprite)



func _build_bed() -> void:
	if _bed_sprite != null and is_instance_valid(_bed_sprite):
		_bed_sprite.queue_free()
	_bed_sprite = Sprite2D.new()
	_bed_sprite.name = "Bed"
	_bed_sprite.centered = false
	_bed_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var anchor := IsoMath.grid_to_screen(BED_ORIGIN)
	# Sprite 96×64 anclado al tip norte del tile origen.
	_bed_sprite.position = anchor - Vector2(48, 28)
	_bed_sprite.z_index = 30 + BED_ORIGIN.x + BED_ORIGIN.y
	furniture_layer.add_child(_bed_sprite)


func _build_bowl() -> void:
	if _bowl_sprite != null and is_instance_valid(_bowl_sprite):
		_bowl_sprite.queue_free()
	_bowl_sprite = Sprite2D.new()
	_bowl_sprite.name = "Bowl"
	_bowl_sprite.centered = false
	_bowl_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var anchor := IsoMath.grid_to_screen(BOWL_ORIGIN)
	_bowl_sprite.position = anchor - Vector2(20, 8)
	_bowl_sprite.z_index = 30 + BOWL_ORIGIN.x + BOWL_ORIGIN.y
	furniture_layer.add_child(_bowl_sprite)


func _build_scratcher() -> void:
	if _scratcher_sprite != null and is_instance_valid(_scratcher_sprite):
		_scratcher_sprite.queue_free()
	_scratcher_sprite = Sprite2D.new()
	_scratcher_sprite.name = "Scratcher"
	_scratcher_sprite.centered = false
	_scratcher_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var anchor := IsoMath.grid_to_screen(SCRATCHER_ORIGIN)
	# Poste alto 48×80; base cerca del tip del tile.
	_scratcher_sprite.position = anchor - Vector2(24, 64)
	_scratcher_sprite.z_index = 30 + SCRATCHER_ORIGIN.x + SCRATCHER_ORIGIN.y
	furniture_layer.add_child(_scratcher_sprite)



func _build_toy() -> void:
	if _toy_sprite != null and is_instance_valid(_toy_sprite):
		_toy_sprite.queue_free()
	_toy_sprite = Sprite2D.new()
	_toy_sprite.name = "Toy"
	_toy_sprite.centered = false
	_toy_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var anchor := IsoMath.grid_to_screen(TOY_ORIGIN)
	_toy_sprite.position = anchor - Vector2(16, 8)
	_toy_sprite.z_index = 30 + TOY_ORIGIN.x + TOY_ORIGIN.y
	furniture_layer.add_child(_toy_sprite)


func _build_tabs() -> void:
	for child in tab_bar.get_children():
		child.queue_free()
	for child in item_tab_bar.get_children():
		child.queue_free()
	_add_tab_button(tab_bar, "Piso", "floor")
	_add_tab_button(tab_bar, "Izq", "wall_left")
	_add_tab_button(tab_bar, "Der", "wall_right")
	_add_tab_button(tab_bar, "Papel", "wallpaper")
	_add_tab_button(tab_bar, "Vent", "window")
	_add_tab_button(tab_bar, "Luz", "light")
	_add_tab_button(item_tab_bar, "Alfom", "rug")
	_add_tab_button(item_tab_bar, "Cama", "bed")
	_add_tab_button(item_tab_bar, "Plato", "bowl")
	_add_tab_button(item_tab_bar, "Rasca", "scratcher")
	_add_tab_button(item_tab_bar, "Pelota", "toy")


func _add_tab_button(parent: HBoxContainer, label: String, target: String) -> void:
	var button := Button.new()
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(0, 48)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 12)
	button.text = label
	button.pressed.connect(func() -> void:
		_set_edit_target(target)
	)
	parent.add_child(button)


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
		"light":
			hint_label.text = "Editando: Lámpara · %s" % _nice_name(_light_variants, _current_light)
		"wallpaper":
			hint_label.text = "Editando: Papel · %s" % _nice_name(_wallpaper_variants, _current_wallpaper)
		"rug":
			hint_label.text = "Editando: Alfombra · %s" % _nice_name(_rug_variants, _current_rug)
		"bed":
			hint_label.text = "Editando: Cama · %s" % _nice_name(_bed_variants, _current_bed)
		"bowl":
			hint_label.text = "Editando: Plato · %s" % _nice_name(_bowl_variants, _current_bowl)
		"scratcher":
			hint_label.text = "Editando: Rascador · %s" % _nice_name(_scratcher_variants, _current_scratcher)
		"toy":
			hint_label.text = "Editando: Pelota · %s" % _nice_name(_toy_variants, _current_toy)


func _variants_for_target() -> Array:
	match _edit_target:
		"wall_left":
			return _wall_left_variants
		"wall_right":
			return _wall_right_variants
		"window":
			return _window_variants
		"light":
			return _light_variants
		"wallpaper":
			return _wallpaper_variants
		"rug":
			return _rug_variants
		"bed":
			return _bed_variants
		"bowl":
			return _bowl_variants
		"scratcher":
			return _scratcher_variants
		"toy":
			return _toy_variants
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
				"light":
					set_light_variant(id)
				"wallpaper":
					set_wallpaper_variant(id)
				"rug":
					set_rug_variant(id)
				"bed":
					set_bed_variant(id)
				"bowl":
					set_bowl_variant(id)
				"scratcher":
					set_scratcher_variant(id)
				"toy":
					set_toy_variant(id)
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
	_apply_room_mood()
	if _edit_target == "window":
		hint_label.text = "Editando: Ventana · %s" % _nice_name(_window_variants, variant_id)
	window_changed.emit(variant_id)


func set_light_variant(variant_id: String) -> void:
	if not _light_textures.has(variant_id) or _light_sprite == null:
		return
	_current_light = variant_id
	_light_sprite.texture = _light_textures[variant_id]
	_apply_room_mood()
	if _edit_target == "light":
		hint_label.text = "Editando: Lámpara · %s" % _nice_name(_light_variants, variant_id)
	light_changed.emit(variant_id)


func _apply_room_mood() -> void:
	# Combina cielo de ventana + estado de lámpara.
	var base: Color
	match _current_window:
		"window_small_evening":
			base = Color(0.90, 0.78, 0.68, 1)
		"window_small_night":
			base = Color(0.35, 0.42, 0.55, 1)
		_:
			base = Color(0.78, 0.86, 0.90, 1)

	match _current_light:
		"light_ceiling_warm":
			base = base.lerp(Color(1.0, 0.92, 0.75, 1), 0.28)
			room_root.modulate = Color(1.05, 1.0, 0.94, 1)
		"light_ceiling_rose":
			base = base.lerp(Color(1.0, 0.82, 0.88, 1), 0.30)
			room_root.modulate = Color(1.04, 0.96, 0.98, 1)
		_:
			# Apagada: cuarto un poco más frío/oscuro.
			base = base.lerp(Color(0.22, 0.24, 0.32, 1), 0.35)
			room_root.modulate = Color(0.78, 0.80, 0.88, 1)

	background.color = base



func set_wallpaper_variant(variant_id: String) -> void:
	if not _wallpaper_left_textures.has(variant_id):
		return
	_current_wallpaper = variant_id
	var left_tex = _wallpaper_left_textures[variant_id]
	var right_tex = _wallpaper_right_textures[variant_id]
	for sprite in _wallpaper_left_tiles:
		sprite.texture = left_tex
		sprite.visible = left_tex != null
	for sprite in _wallpaper_right_tiles:
		sprite.texture = right_tex
		sprite.visible = right_tex != null
	if _edit_target == "wallpaper":
		hint_label.text = "Editando: Papel · %s" % _nice_name(_wallpaper_variants, variant_id)
	wallpaper_changed.emit(variant_id)



func set_rug_variant(variant_id: String) -> void:
	if not _rug_textures.has(variant_id) or _rug_sprite == null:
		return
	_current_rug = variant_id
	var tex = _rug_textures[variant_id]
	_rug_sprite.texture = tex
	_rug_sprite.visible = tex != null
	if _edit_target == "rug":
		hint_label.text = "Editando: Alfombra · %s" % _nice_name(_rug_variants, variant_id)
	rug_changed.emit(variant_id)
	_notify_place_once("rug", variant_id != "rug_small_none")



func set_bed_variant(variant_id: String) -> void:
	if not _bed_textures.has(variant_id) or _bed_sprite == null:
		return
	_current_bed = variant_id
	var tex = _bed_textures[variant_id]
	_bed_sprite.texture = tex
	_bed_sprite.visible = tex != null
	if _edit_target == "bed":
		hint_label.text = "Editando: Cama · %s" % _nice_name(_bed_variants, variant_id)
	bed_changed.emit(variant_id)
	_notify_place_once("bed", variant_id != "bed_cat_none")



func set_bowl_variant(variant_id: String) -> void:
	if not _bowl_textures.has(variant_id) or _bowl_sprite == null:
		return
	_current_bowl = variant_id
	var tex = _bowl_textures[variant_id]
	_bowl_sprite.texture = tex
	_bowl_sprite.visible = tex != null
	if _edit_target == "bowl":
		hint_label.text = "Editando: Plato · %s" % _nice_name(_bowl_variants, variant_id)
	bowl_changed.emit(variant_id)
	_notify_place_once("bowl", variant_id != "bowl_food_none")


func set_scratcher_variant(variant_id: String) -> void:
	if not _scratcher_textures.has(variant_id) or _scratcher_sprite == null:
		return
	_current_scratcher = variant_id
	var tex = _scratcher_textures[variant_id]
	_scratcher_sprite.texture = tex
	_scratcher_sprite.visible = tex != null
	if _edit_target == "scratcher":
		hint_label.text = "Editando: Rascador · %s" % _nice_name(_scratcher_variants, variant_id)
	scratcher_changed.emit(variant_id)
	_notify_place_once("scratcher", variant_id != "scratcher_none")



func set_toy_variant(variant_id: String) -> void:
	if not _toy_textures.has(variant_id) or _toy_sprite == null:
		return
	_current_toy = variant_id
	var tex = _toy_textures[variant_id]
	_toy_sprite.texture = tex
	_toy_sprite.visible = tex != null
	if _edit_target == "toy":
		hint_label.text = "Editando: Pelota · %s" % _nice_name(_toy_variants, variant_id)
	toy_changed.emit(variant_id)
	_notify_place_once("toy", variant_id != "toy_ball_none")


func get_current_floor_variant() -> String:
	return _current_floor


func get_current_wall_left_variant() -> String:
	return _current_wall_left


func get_current_wall_right_variant() -> String:
	return _current_wall_right


func get_current_window_variant() -> String:
	return _current_window


func get_current_light_variant() -> String:
	return _current_light

func get_current_wallpaper_variant() -> String:
	return _current_wallpaper

func get_current_rug_variant() -> String:
	return _current_rug

func get_current_bed_variant() -> String:
	return _current_bed

func get_current_bowl_variant() -> String:
	return _current_bowl


func get_current_scratcher_variant() -> String:
	return _current_scratcher

func get_current_toy_variant() -> String:
	return _current_toy












func _nice_name(list: Array, id: String) -> String:
	for v in list:
		if str(v["id"]) == id:
			return str(v["name"])
	return id
