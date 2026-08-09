extends SceneTree
## Prueba headless del Ítem 03 (pared derecha) + shell completo.


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene: PackedScene = load("res://scenes/iso/iso_room.tscn")
	var room: Node2D = scene.instantiate()
	root.add_child(room)

	room.set_wall_right_variant("wall_right_blush")
	if room.get_current_wall_right_variant() != "wall_right_blush":
		push_error("wall right variant switch failed")
		quit(1)
		return

	var left_n: int = room.get_node("RoomRoot/WallLeftLayer").get_child_count()
	var right_n: int = room.get_node("RoomRoot/WallRightLayer").get_child_count()
	if left_n != 8 or right_n != 8:
		push_error("expected 8+8 wall segments, got %d+%d" % [left_n, right_n])
		quit(1)
		return

	print("ISO_WALL_RIGHT_TEST_OK variant=%s shell=ok" % room.get_current_wall_right_variant())
	quit(0)
