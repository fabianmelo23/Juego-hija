extends SceneTree
## Prueba headless del Ítem 07 (ventana pequeña).


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene: PackedScene = load("res://scenes/iso/iso_room.tscn")
	var room: Node2D = scene.instantiate()
	root.add_child(room)

	var variants := ["window_small_day", "window_small_evening", "window_small_night"]
	for id in variants:
		room.set_window_variant(id)
		if room.get_current_window_variant() != id:
			push_error("window variant switch failed for %s" % id)
			quit(1)
			return

	var win_layer: Node2D = room.get_node("RoomRoot/WindowLayer")
	if win_layer.get_child_count() != 1:
		push_error("expected 1 window sprite")
		quit(1)
		return

	var sprite: Sprite2D = win_layer.get_child(0)
	if sprite.texture == null:
		push_error("window sprite has no texture")
		quit(1)
		return

	var bg: Polygon2D = room.get_node("Background")
	room.set_window_variant("window_small_night")
	if bg.color.b < 0.5:
		push_error("night mood background not applied")
		quit(1)
		return

	print("ISO_WINDOW_TEST_OK variant=%s" % room.get_current_window_variant())
	quit(0)
