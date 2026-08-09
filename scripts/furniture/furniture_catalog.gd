class_name FurnitureCatalog
extends RefCounted
## Catálogo de decoraciones para inventario iso.


static func all() -> Array[Dictionary]:
	return [
		{
			"id": "bed",
			"name": "Cama",
			"color": Color(0.86, 0.55, 0.48, 1),
			"size": Vector2i(2, 2),
			"blocks": true,
			"start_count": 1,
		},
		{
			"id": "table",
			"name": "Mesa",
			"color": Color(0.72, 0.55, 0.35, 1),
			"size": Vector2i(2, 2),
			"blocks": true,
			"start_count": 1,
		},
		{
			"id": "bowl",
			"name": "Plato",
			"color": Color(0.95, 0.9, 0.55, 1),
			"size": Vector2i(1, 1),
			"blocks": false,
			"start_count": 1,
		},
		{
			"id": "scratcher",
			"name": "Rascador",
			"color": Color(0.72, 0.58, 0.38, 1),
			"size": Vector2i(1, 2),
			"blocks": true,
			"start_count": 1,
		},
		{
			"id": "rug",
			"name": "Alfombra",
			"color": Color(0.9, 0.55, 0.6, 1),
			"size": Vector2i(2, 2),
			"blocks": false,
			"start_count": 1,
		},
		{
			"id": "toy",
			"name": "Pelota",
			"color": Color(0.55, 0.75, 0.95, 1),
			"size": Vector2i(1, 1),
			"blocks": false,
			"start_count": 1,
		},
		{
			"id": "plant",
			"name": "Maceta",
			"color": Color(0.45, 0.72, 0.42, 1),
			"size": Vector2i(1, 1),
			"blocks": false,
			"start_count": 1,
		},
	]


static func by_id(item_id: String) -> Dictionary:
	for item in all():
		if str(item["id"]) == item_id:
			return item
	return {}
