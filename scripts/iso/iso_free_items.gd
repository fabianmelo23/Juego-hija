extends Node2D
## Ítems colocables en posición libre (no atados a un tile) + apilado simple.

signal item_placed(item_id: String, variant_id: String)

const SAVE_PATH := "user://iso_free_layout_v2.json"

## stack_h: altura de superficie para poner cosas encima
const DEFS := {
	"bed": {"variants": ["bed_cat_cream", "bed_cat_blush", "bed_cat_mint"], "default": "bed_cat_blush", "stack_h": 0.0, "z_base": 30, "anchor": Vector2(48, 28)},
	"table": {"variants": ["table_low_wood", "table_low_blush"], "default": "table_low_wood", "stack_h": 22.0, "z_base": 32, "anchor": Vector2(40, 28)},
	"scratcher": {"variants": ["scratcher_wood", "scratcher_blush", "scratcher_mint"], "default": "scratcher_wood", "stack_h": 0.0, "z_base": 34, "anchor": Vector2(24, 64)},
	"bowl": {"variants": ["bowl_food_full", "bowl_food_half", "bowl_food_empty"], "default": "bowl_food_full", "stack_h": 0.0, "z_base": 36, "anchor": Vector2(20, 8)},
	"rug": {"variants": ["rug_small_blush", "rug_small_sage", "rug_small_sky"], "default": "rug_small_blush", "stack_h": 0.0, "z_base": 18, "anchor": Vector2(64, 4), "path": "res://assets/art/iso/rugs/%s.png"},
	"toy": {"variants": ["toy_ball_red", "toy_ball_sky", "toy_ball_sun"], "default": "toy_ball_red", "stack_h": 0.0, "z_base": 40, "anchor": Vector2(16, 8)},
}

var _items: Dictionary = {} # item_id -> {variant, pos: Vector2, height: float, sprite: Sprite2D}
var _ghost: Sprite2D
var _textures: Dictionary = {}


func _ready() -> void:
	_ghost = Sprite2D.new()
	_ghost.centered = false
	_ghost.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_ghost.modulate = Color(1, 1, 1, 0.65)
	_ghost.visible = false
	_ghost.z_index = 200
	add_child(_ghost)
	_load_textures()
	load_layout()


func _load_textures() -> void:
	for item_id in DEFS.keys():
		var d: Dictionary = DEFS[item_id]
		var path_tpl := str(d.get("path", "res://assets/art/iso/furniture/%s.png"))
		_textures[item_id] = {}
		for v in d["variants"]:
			var p := path_tpl % str(v)
			if ResourceLoader.exists(p):
				_textures[item_id][str(v)] = load(p)


func has_item(item_id: String) -> bool:
	return _items.has(item_id)


func get_variant(item_id: String) -> String:
	if not _items.has(item_id):
		return ""
	return str(_items[item_id].get("variant", ""))


func begin_ghost(item_id: String, variant_id: String) -> void:
	var tex: Texture2D = _tex(item_id, variant_id)
	_ghost.texture = tex
	_ghost.visible = tex != null


func update_ghost_at(local_pos: Vector2, item_id: String) -> void:
	var d: Dictionary = DEFS.get(item_id, {})
	var anchor: Vector2 = d.get("anchor", Vector2.ZERO)
	var height := _stack_height_at(local_pos, item_id)
	_ghost.position = local_pos - anchor + Vector2(0, -height)
	_ghost.z_index = 200
	_ghost.visible = true


func hide_ghost() -> void:
	_ghost.visible = false


func place_or_move(item_id: String, variant_id: String, local_pos: Vector2) -> void:
	if not DEFS.has(item_id):
		return
	var d: Dictionary = DEFS[item_id]
	if variant_id == "" or not _textures[item_id].has(variant_id):
		variant_id = str(d["default"])
	var height := _stack_height_at(local_pos, item_id)
	if _items.has(item_id):
		var entry: Dictionary = _items[item_id]
		entry["variant"] = variant_id
		entry["pos"] = local_pos
		entry["height"] = height
		_apply_sprite(item_id)
	else:
		var sprite := Sprite2D.new()
		sprite.name = item_id.capitalize()
		sprite.centered = false
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		add_child(sprite)
		_items[item_id] = {
			"variant": variant_id,
			"pos": local_pos,
			"height": height,
			"sprite": sprite,
		}
		_apply_sprite(item_id)
	hide_ghost()
	save_layout()
	item_placed.emit(item_id, variant_id)


func set_variant(item_id: String, variant_id: String) -> void:
	if not _items.has(item_id):
		return
	_items[item_id]["variant"] = variant_id
	_apply_sprite(item_id)
	save_layout()


func remove_item(item_id: String) -> void:
	if not _items.has(item_id):
		return
	var sprite: Sprite2D = _items[item_id].get("sprite")
	if sprite:
		sprite.queue_free()
	_items.erase(item_id)
	save_layout()


func _apply_sprite(item_id: String) -> void:
	var entry: Dictionary = _items[item_id]
	var d: Dictionary = DEFS[item_id]
	var sprite: Sprite2D = entry["sprite"]
	var variant := str(entry["variant"])
	sprite.texture = _tex(item_id, variant)
	var anchor: Vector2 = d["anchor"]
	var pos: Vector2 = entry["pos"]
	var height: float = float(entry.get("height", 0.0))
	sprite.position = pos - anchor + Vector2(0, -height)
	sprite.z_index = int(d["z_base"]) + int(pos.y) + int(height)
	sprite.visible = sprite.texture != null


func _tex(item_id: String, variant_id: String) -> Texture2D:
	if not _textures.has(item_id):
		return null
	return _textures[item_id].get(variant_id, null)


func _stack_height_at(local_pos: Vector2, moving_id: String) -> float:
	# Si cae cerca del centro de una mesa (u otro con stack_h), súbelo.
	var best_h := 0.0
	var best_dist := 36.0
	for item_id in _items.keys():
		if item_id == moving_id:
			continue
		var d: Dictionary = DEFS.get(item_id, {})
		var surface: float = float(d.get("stack_h", 0.0))
		if surface <= 0.0:
			continue
		var other_pos: Vector2 = _items[item_id]["pos"]
		var dist := local_pos.distance_to(other_pos)
		if dist < best_dist:
			best_dist = dist
			best_h = surface + float(_items[item_id].get("height", 0.0))
	return best_h


func save_layout() -> void:
	var data := {}
	for item_id in _items.keys():
		var e: Dictionary = _items[item_id]
		var pos: Vector2 = e["pos"]
		data[item_id] = {
			"variant": e["variant"],
			"pos": [pos.x, pos.y],
			"height": e.get("height", 0.0),
		}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()


func load_layout() -> void:
	# Por defecto el cuarto nace vacío: solo piso/paredes/gato.
	# Las decoraciones viven en el inventario hasta que el jugador las coloque.
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	for item_id in parsed.keys():
		if not DEFS.has(item_id):
			continue
		var e = parsed[item_id]
		if typeof(e) != TYPE_DICTIONARY:
			continue
		var arr = e.get("pos", [0, 0])
		var pos := Vector2(float(arr[0]), float(arr[1])) if typeof(arr) == TYPE_ARRAY and arr.size() >= 2 else Vector2.ZERO
		var variant := str(e.get("variant", DEFS[item_id]["default"]))
		var height := float(e.get("height", 0.0))
		var sprite := Sprite2D.new()
		sprite.name = str(item_id).capitalize()
		sprite.centered = false
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		add_child(sprite)
		_items[item_id] = {"variant": variant, "pos": pos, "height": height, "sprite": sprite}
		_apply_sprite(item_id)


func clear_all() -> void:
	for item_id in _items.keys():
		var sprite: Sprite2D = _items[item_id].get("sprite")
		if sprite:
			sprite.queue_free()
	_items.clear()
	save_layout()
