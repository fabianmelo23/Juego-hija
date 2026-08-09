class_name GameInventory
extends RefCounted
## Inventario simple de muebles (conteos por id).

signal changed

var _counts: Dictionary = {}


func _init() -> void:
	for item in FurnitureCatalog.all():
		_counts[str(item["id"])] = int(item.get("start_count", 0))


func get_count(item_id: String) -> int:
	return int(_counts.get(item_id, 0))


func can_use(item_id: String) -> bool:
	return get_count(item_id) > 0


func consume(item_id: String) -> bool:
	if not can_use(item_id):
		return false
	_counts[item_id] = get_count(item_id) - 1
	changed.emit()
	return true


func add(item_id: String, amount: int = 1) -> void:
	_counts[item_id] = get_count(item_id) + amount
	changed.emit()


func to_dict() -> Dictionary:
	return _counts.duplicate()


func from_dict(data: Dictionary) -> void:
	for item in FurnitureCatalog.all():
		var id := str(item["id"])
		if data.has(id):
			_counts[id] = int(data[id])
	changed.emit()
