class_name ShopCatalog
extends RefCounted
## Tienda simple: gasta Huellitas, recibe muebles en la mochila.


static func all() -> Array[Dictionary]:
	return [
		{"id": "bowl", "name": "Plato", "price": 3, "kind": "furniture"},
		{"id": "plant", "name": "Maceta", "price": 4, "kind": "furniture"},
		{"id": "toy", "name": "Juguete", "price": 5, "kind": "furniture"},
		{"id": "scratcher", "name": "Rascador", "price": 6, "kind": "furniture"},
		{"id": "bed", "name": "Cama", "price": 8, "kind": "furniture"},
	]


static func by_id(item_id: String) -> Dictionary:
	for item in all():
		if str(item["id"]) == item_id:
			return item
	return {}
