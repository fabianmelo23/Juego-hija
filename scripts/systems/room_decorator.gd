extends Node2D
## Modo decoración: cuadrícula en la casa, fantasma, colocar y guardar.

signal decorate_mode_changed(active: bool)
signal placed(item_id: String)
signal layout_saved
signal inventory_changed

const SAVE_PATH := "user://room_layout.json"
const CELL_SIZE := 48.0
const GRID_ORIGIN := Vector2(-240, -432)
const GRID_COLS := 10
const GRID_ROWS := 8

@onready var furniture_layer: Node2D = $FurnitureLayer
@onready var ghost: Polygon2D = $Ghost
@onready var grid_overlay: Node2D = $GridOverlay

var inventory: GameInventory = GameInventory.new()
var active: bool = false
var selected_item_id: String = ""
var ghost_facing: int = 0
var ghost_cell: Vector2i = Vector2i(-999, -999)

var _furniture_scene: PackedScene = preload("res://scenes/furniture/furniture_item.tscn")
var _occupied: Dictionary = {} # "x,y" -> furniture node


func _ready() -> void:
	ghost.visible = false
	grid_overlay.visible = false
	_build_grid_visual()
	inventory.changed.connect(func() -> void:
		inventory_changed.emit()
	)
	load_layout()


func is_decorating() -> bool:
	return active


func enter_decorate_mode() -> void:
	active = true
	grid_overlay.visible = true
	ghost.visible = selected_item_id != ""
	decorate_mode_changed.emit(true)


func exit_decorate_mode(clear_selection: bool = true) -> void:
	active = false
	grid_overlay.visible = false
	ghost.visible = false
	if clear_selection:
		selected_item_id = ""
		ghost_facing = 0
	decorate_mode_changed.emit(false)


func select_item(item_id: String) -> bool:
	if not inventory.can_use(item_id):
		return false
	selected_item_id = item_id
	ghost_facing = 0
	if not active:
		enter_decorate_mode()
	_update_ghost_visual()
	ghost.visible = true
	return true


func rotate_selected() -> void:
	if selected_item_id == "":
		return
	ghost_facing = (ghost_facing + 1) % 2
	_update_ghost_visual()


func handle_world_tap(world_pos: Vector2) -> bool:
	if not active or selected_item_id == "":
		return false
	var cell := world_to_cell(world_pos)
	if not _can_place(selected_item_id, cell, ghost_facing):
		return false
	if not inventory.consume(selected_item_id):
		return false
	_spawn_furniture(selected_item_id, cell, ghost_facing)
	placed.emit(selected_item_id)
	if not inventory.can_use(selected_item_id):
		selected_item_id = ""
		ghost.visible = false
	else:
		_update_ghost_at_cell(cell)
	return true


func update_ghost_from_world(world_pos: Vector2) -> void:
	if not active or selected_item_id == "":
		return
	var cell := world_to_cell(world_pos)
	_update_ghost_at_cell(cell)


func world_to_cell(world_pos: Vector2) -> Vector2i:
	var local := world_pos - GRID_ORIGIN
	return Vector2i(floori(local.x / CELL_SIZE), floori(local.y / CELL_SIZE))


func cell_to_world(cell: Vector2i) -> Vector2:
	return GRID_ORIGIN + Vector2(cell.x * CELL_SIZE, cell.y * CELL_SIZE)


func get_inventory_snapshot() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for item in FurnitureCatalog.all():
		var id := str(item["id"])
		rows.append({
			"id": id,
			"name": str(item["name"]),
			"count": inventory.get_count(id),
		})
	return rows


func save_layout() -> void:
	var items: Array = []
	for child in furniture_layer.get_children():
		items.append({
			"id": child.item_id,
			"x": child.grid_pos.x,
			"y": child.grid_pos.y,
			"facing": child.facing,
		})
	var payload := {
		"inventory": inventory.to_dict(),
		"items": items,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("No se pudo guardar layout")
		return
	file.store_string(JSON.stringify(payload))
	file.close()
	layout_saved.emit()


func load_layout() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	_clear_furniture()
	var data: Dictionary = parsed
	if data.has("inventory"):
		inventory.from_dict(data["inventory"])
	for entry in data.get("items", []):
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		_spawn_furniture(
			str(entry.get("id", "")),
			Vector2i(int(entry.get("x", 0)), int(entry.get("y", 0))),
			int(entry.get("facing", 0))
		)


func _spawn_furniture(item_id: String, cell: Vector2i, facing: int) -> void:
	var data := FurnitureCatalog.by_id(item_id)
	if data.is_empty():
		return
	var node: Node2D = _furniture_scene.instantiate()
	furniture_layer.add_child(node)
	node.position = cell_to_world(cell)
	node.setup(data, cell, CELL_SIZE, facing)
	for occupied in node.get_occupied_cells():
		_occupied[_cell_key(occupied)] = node


func _can_place(item_id: String, cell: Vector2i, facing: int) -> bool:
	var data := FurnitureCatalog.by_id(item_id)
	if data.is_empty():
		return false
	var size: Vector2i = data.get("size", Vector2i.ONE)
	if facing == 1:
		size = Vector2i(size.y, size.x)
	for y in size.y:
		for x in size.x:
			var c := cell + Vector2i(x, y)
			if c.x < 0 or c.y < 0 or c.x >= GRID_COLS or c.y >= GRID_ROWS:
				return false
			if _occupied.has(_cell_key(c)):
				return false
	return true


func _update_ghost_at_cell(cell: Vector2i) -> void:
	ghost_cell = cell
	ghost.position = cell_to_world(cell)
	var valid := _can_place(selected_item_id, cell, ghost_facing)
	ghost.color = Color(0.4, 0.9, 0.5, 0.45) if valid else Color(0.95, 0.35, 0.3, 0.45)
	_update_ghost_visual()


func _update_ghost_visual() -> void:
	var data := FurnitureCatalog.by_id(selected_item_id)
	if data.is_empty():
		ghost.visible = false
		return
	var size: Vector2i = data.get("size", Vector2i.ONE)
	if ghost_facing == 1:
		size = Vector2i(size.y, size.x)
	var w := size.x * CELL_SIZE
	var h := size.y * CELL_SIZE
	ghost.polygon = PackedVector2Array([
		Vector2(2, 2),
		Vector2(w - 2, 2),
		Vector2(w - 2, h - 2),
		Vector2(2, h - 2),
	])


func _clear_furniture() -> void:
	for child in furniture_layer.get_children():
		child.queue_free()
	_occupied.clear()


func _cell_key(cell: Vector2i) -> String:
	return "%d,%d" % [cell.x, cell.y]


func _build_grid_visual() -> void:
	for child in grid_overlay.get_children():
		child.queue_free()
	for y in GRID_ROWS:
		for x in GRID_COLS:
			var cell := Polygon2D.new()
			cell.color = Color(1, 1, 1, 0.07)
			cell.position = cell_to_world(Vector2i(x, y))
			var s := CELL_SIZE
			cell.polygon = PackedVector2Array([
				Vector2(1, 1),
				Vector2(s - 1, 1),
				Vector2(s - 1, s - 1),
				Vector2(1, s - 1),
			])
			grid_overlay.add_child(cell)
