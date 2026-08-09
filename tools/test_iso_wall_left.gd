extends SceneTree
## Prueba headless del Ítem 02 (pared izquierda).


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene: PackedScene = load("res://scenes/iso/iso_room.tscn")
	var room: Node2D = scene.instantiate()
	root.add_child(room)

	if room.get_current_wall_left_variant() == "":
		push_error("wall left empty")
		quit(1)
		return

	room.set_wall_left_variant("wall_left_sage")
	if room.get_current_wall_left_variant() != "wall_left_sage":
		push_error("wall variant switch failed")
		quit(1)
		return

	var wall_layer: Node2D = room.get_node("RoomRoot/WallLeftLayer")
	if wall_layer.get_child_count() != 8:
		push_error("expected 8 wall segments, got %d" % wall_layer.get_child_count())
		quit(1)
		return

	print("ISO_WALL_LEFT_TEST_OK variant=%s" % room.get_current_wall_left_variant())
	quit(0)
