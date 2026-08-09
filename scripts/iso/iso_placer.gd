class_name IsoPlacer
extends RefCounted
## Colocación libre en grid isométrico 8×8 + guardado de layout.

const SAVE_PATH := "user://iso_layout.json"

## id -> { size: Vector2i, soft: bool, default_cell: Vector2i, anchor: Vector2, z_base: int }
const ITEM_DEFS := {
	"rug": {"size": Vector2i(2, 2), "soft": true, "default_cell": Vector2i(3, 3), "anchor": Vector2(64, 4), "z_base": 20},
	"bed": {"size": Vector2i(2, 2), "soft": false, "default_cell": Vector2i(5, 2), "anchor": Vector2(48, 28), "z_base": 30},
	"bowl": {"size": Vector2i(1, 1), "soft": true, "default_cell": Vector2i(2, 5), "anchor": Vector2(20, 8), "z_base": 30},
	"scratcher": {"size": Vector2i(1, 2), "soft": false, "default_cell": Vector2i(1, 2), "anchor": Vector2(24, 64), "z_base": 30},
	"toy": {"size": Vector2i(1, 1), "soft": true, "default_cell": Vector2i(4, 5), "anchor": Vector2(16, 8), "z_base": 30},
}


static func def_for(item_id: String) -> Dictionary:
	return ITEM_DEFS.get(item_id, {})


static func footprint_cells(origin: Vector2i, size: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for y in size.y:
		for x in size.x:
			cells.append(origin + Vector2i(x, y))
	return cells


static func in_room(cell: Vector2i, room_size: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < room_size.x and cell.y < room_size.y


static func footprint_in_room(origin: Vector2i, size: Vector2i, room_size: Vector2i) -> bool:
	for cell in footprint_cells(origin, size):
		if not in_room(cell, room_size):
			return false
	return true


static func sprite_pos(origin: Vector2i, anchor: Vector2) -> Vector2:
	return IsoMath.grid_to_screen(origin) - anchor


static func sprite_z(origin: Vector2i, z_base: int) -> int:
	return z_base + origin.x + origin.y


static func diamond_polygon(cell: Vector2i) -> PackedVector2Array:
	var top := IsoMath.grid_to_screen(cell)
	var half_w := IsoMath.TILE_W / 2.0
	var half_h := IsoMath.TILE_H / 2.0
	return PackedVector2Array([
		top,
		top + Vector2(half_w, half_h),
		top + Vector2(0, IsoMath.TILE_H),
		top + Vector2(-half_w, half_h),
	])


static func save_layout(data: Dictionary) -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(data))
	file.close()


static func load_layout() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed
