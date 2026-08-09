extends SceneTree
## Prueba headless del Ítem 24 (pelota).


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene: PackedScene = load("res://scenes/iso/iso_room.tscn")
	var room: Node2D = scene.instantiate()
	root.add_child(room)

	room.set_toy_variant("toy_ball_sky")
	if room.get_current_toy_variant() != "toy_ball_sky":
		push_error("toy sky failed")
		quit(1)
		return

	var sprite: Sprite2D = room.get_node("RoomRoot/FurnitureLayer/Toy")
	if sprite.texture == null or not sprite.visible:
		push_error("toy should be visible")
		quit(1)
		return

	room.set_toy_variant("toy_ball_none")
	if sprite.visible:
		push_error("none toy should hide sprite")
		quit(1)
		return

	print("ISO_TOY_TEST_OK variant=%s" % room.get_current_toy_variant())
	quit(0)
