extends SceneTree
## Colocación libre + apilado desde inventario.


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	if FileAccess.file_exists("user://iso_free_layout_v2.json"):
		DirAccess.remove_absolute("user://iso_free_layout_v2.json")

	var scene: PackedScene = load("res://scenes/iso/iso_room.tscn")
	var room: Node2D = scene.instantiate()
	root.add_child(room)

	var free: Node2D = room.get_node("RoomRoot/FreeItems")
	room.inventory.consume("table")
	room.inventory.consume("toy")
	free.place_or_move("table", "table_low_wood", Vector2(0, 100))
	free.place_or_move("toy", "toy_ball_red", Vector2(2, 102))

	var toy_entry: Dictionary = free._items["toy"]
	if float(toy_entry.get("height", 0.0)) < 10.0:
		push_error("toy should stack on table height=%s" % str(toy_entry.get("height", 0)))
		quit(1)
		return

	var left_layer: Node2D = room.get_node("RoomRoot/WallLeftLayer")
	if left_layer.get_child_count() != 1:
		push_error("expected 1 left wall strip, got %d" % left_layer.get_child_count())
		quit(1)
		return

	print("ISO_FREE_PLACE_TEST_OK toy_height=%.1f" % float(toy_entry.get("height", 0.0)))
	quit(0)
