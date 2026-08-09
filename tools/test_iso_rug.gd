extends SceneTree
## Prueba headless del Ítem 15 (alfombra chica 2×2).


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene: PackedScene = load("res://scenes/iso/iso_room.tscn")
	var room: Node2D = scene.instantiate()
	root.add_child(room)

	room.set_rug_variant("rug_small_sage")
	if room.get_current_rug_variant() != "rug_small_sage":
		push_error("rug sage failed")
		quit(1)
		return

	var rug_layer: Node2D = room.get_node("RoomRoot/RugLayer")
	if rug_layer.get_child_count() != 1:
		push_error("expected 1 rug sprite")
		quit(1)
		return

	var sprite: Sprite2D = rug_layer.get_child(0)
	if sprite.texture == null or not sprite.visible:
		push_error("rug should be visible with texture")
		quit(1)
		return

	room.set_rug_variant("rug_small_none")
	if sprite.visible:
		push_error("none rug should hide sprite")
		quit(1)
		return

	print("ISO_RUG_TEST_OK variant=%s" % room.get_current_rug_variant())
	quit(0)
