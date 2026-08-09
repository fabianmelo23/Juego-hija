extends SceneTree
## Cuarto vacío: solo piso/paredes/gato; decoraciones en inventario.


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	if FileAccess.file_exists("user://iso_free_layout_v2.json"):
		DirAccess.remove_absolute("user://iso_free_layout_v2.json")
	if FileAccess.file_exists("user://progress.json"):
		DirAccess.remove_absolute("user://progress.json")

	var scene: PackedScene = load("res://scenes/iso/iso_room.tscn")
	var room: Node2D = scene.instantiate()
	root.add_child(room)

	var free: Node2D = room.get_node("RoomRoot/FreeItems")
	if free._items.size() != 0:
		push_error("room should start with no furniture, got %d" % free._items.size())
		quit(1)
		return

	if room.get_current_window_variant() != "window_none":
		push_error("window should start none")
		quit(1)
		return
	if room.get_current_light_variant() != "light_none":
		push_error("light should start none")
		quit(1)
		return

	if room.inventory.get_count("bed") < 1:
		push_error("bed should be in inventory")
		quit(1)
		return
	if room.inventory.get_count("table") < 1:
		push_error("table should be in inventory")
		quit(1)
		return

	# Colocar consume inventario
	if not room.inventory.consume("bed"):
		push_error("consume bed failed")
		quit(1)
		return
	free.place_or_move("bed", "bed_cat_blush", Vector2(10, 10))
	if room.inventory.get_count("bed") != 0:
		push_error("bed count should be 0 after place")
		quit(1)
		return

	var gameplay: Node = room.get_node("Gameplay")
	if gameplay.cat == null:
		push_error("cat missing")
		quit(1)
		return

	print("ISO_EMPTY_ROOM_TEST_OK inv_bed=%d placed=%d" % [
		room.inventory.get_count("toy"),
		free._items.size(),
	])
	quit(0)
