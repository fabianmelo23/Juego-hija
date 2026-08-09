extends SceneTree
## Prueba headless del Ítem 20 (plato de comida).


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene: PackedScene = load("res://scenes/iso/iso_room.tscn")
	var room: Node2D = scene.instantiate()
	root.add_child(room)

	room.set_bowl_variant("bowl_food_half")
	if room.get_current_bowl_variant() != "bowl_food_half":
		push_error("bowl half failed")
		quit(1)
		return

	var sprite: Sprite2D = room.get_node("RoomRoot/FurnitureLayer/Bowl")
	if sprite.texture == null or not sprite.visible:
		push_error("bowl should be visible")
		quit(1)
		return

	room.set_bowl_variant("bowl_food_none")
	if sprite.visible:
		push_error("none bowl should hide sprite")
		quit(1)
		return

	print("ISO_BOWL_TEST_OK variant=%s" % room.get_current_bowl_variant())
	quit(0)
