extends SceneTree
## Prueba headless del Ítem 01 (piso isométrico).


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene: PackedScene = load("res://scenes/iso/iso_room.tscn")
	var room: Node2D = scene.instantiate()
	root.add_child(room)

	room.set_floor_variant("floor_pastel_blue")
	if room.get_current_floor_variant() != "floor_pastel_blue":
		push_error("variant switch failed")
		quit(1)
		return

	var screen: Vector2 = IsoMath.grid_to_screen(Vector2i(1, 0))
	if int(screen.x) != 32 or int(screen.y) != 16:
		push_error("iso math unexpected: %s" % str(screen))
		quit(1)
		return

	print("ISO_FLOOR_TEST_OK variant=%s" % room.get_current_floor_variant())
	quit(0)
