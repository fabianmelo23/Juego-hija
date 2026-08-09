extends Node2D
## Mueble colocado en la habitación (placeholder visual).

var item_id: String = ""
var display_name: String = ""
var footprint: Vector2i = Vector2i.ONE
var blocks_path: bool = false
var facing: int = 0 # 0 o 1 (rotado)
var grid_pos: Vector2i = Vector2i.ZERO

@onready var body: Polygon2D = $Body
@onready var label: Label = $Label


func setup(data: Dictionary, cell: Vector2i, cell_size: float, rot: int = 0) -> void:
	item_id = str(data.get("id", ""))
	display_name = str(data.get("name", item_id))
	footprint = data.get("size", Vector2i.ONE)
	blocks_path = bool(data.get("blocks", false))
	facing = rot % 2
	grid_pos = cell
	_rebuild_visual(data.get("color", Color.WHITE), cell_size)
	if label:
		label.text = display_name


func get_occupied_cells() -> Array[Vector2i]:
	var size := footprint
	if facing == 1:
		size = Vector2i(footprint.y, footprint.x)
	var cells: Array[Vector2i] = []
	for y in size.y:
		for x in size.x:
			cells.append(grid_pos + Vector2i(x, y))
	return cells


func rotate_item(cell_size: float, data: Dictionary) -> void:
	facing = (facing + 1) % 2
	_rebuild_visual(data.get("color", Color.WHITE), cell_size)


func _rebuild_visual(color: Color, cell_size: float) -> void:
	var size := footprint
	if facing == 1:
		size = Vector2i(footprint.y, footprint.x)
	var w := size.x * cell_size
	var h := size.y * cell_size
	var pad := 4.0
	body.color = color
	body.polygon = PackedVector2Array([
		Vector2(pad, pad),
		Vector2(w - pad, pad),
		Vector2(w - pad, h - pad),
		Vector2(pad, h - pad),
	])
	label.position = Vector2(0, h * 0.5 - 12)
	label.size = Vector2(w, 24)
