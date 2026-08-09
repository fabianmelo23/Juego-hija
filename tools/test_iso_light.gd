extends SceneTree
## Prueba headless del Ítem 11 (lámpara de techo).


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene: PackedScene = load("res://scenes/iso/iso_room.tscn")
	var room: Node2D = scene.instantiate()
	root.add_child(room)

	var variants := ["light_ceiling_warm", "light_ceiling_rose", "light_ceiling_off"]
	for id in variants:
		room.set_light_variant(id)
		if room.get_current_light_variant() != id:
			push_error("light variant switch failed for %s" % id)
			quit(1)
			return

	var light_layer: Node2D = room.get_node("RoomRoot/LightLayer")
	if light_layer.get_child_count() != 1:
		push_error("expected 1 light sprite")
		quit(1)
		return

	var sprite: Sprite2D = light_layer.get_child(0)
	if sprite.texture == null:
		push_error("light sprite has no texture")
		quit(1)
		return

	room.set_window_variant("window_small_night")
	room.set_light_variant("light_ceiling_off")
	if room.modulate.r > 0.95 and room.get_node("RoomRoot").modulate.r > 0.9:
		# room_root should be dimmed when light is off
		if (room.get_node("RoomRoot") as Node2D).modulate.r > 0.9:
			push_error("off light should dim room_root")
			quit(1)
			return

	print("ISO_LIGHT_TEST_OK variant=%s" % room.get_current_light_variant())
	quit(0)
