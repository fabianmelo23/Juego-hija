extends SceneTree
## Prueba headless del Ítem 22 (rascador).


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene: PackedScene = load("res://scenes/iso/iso_room.tscn")
	var room: Node2D = scene.instantiate()
	root.add_child(room)

	room.set_scratcher_variant("scratcher_mint")
	if room.get_current_scratcher_variant() != "scratcher_mint":
		push_error("scratcher mint failed")
		quit(1)
		return

	var sprite: Sprite2D = room.get_node("RoomRoot/FurnitureLayer/Scratcher")
	if sprite.texture == null or not sprite.visible:
		push_error("scratcher should be visible")
		quit(1)
		return

	room.set_scratcher_variant("scratcher_none")
	if sprite.visible:
		push_error("none scratcher should hide sprite")
		quit(1)
		return

	print("ISO_SCRATCHER_TEST_OK variant=%s" % room.get_current_scratcher_variant())
	quit(0)
