extends SceneTree
## Prueba headless del Ítem 19 (cama de gato).


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene: PackedScene = load("res://scenes/iso/iso_room.tscn")
	var room: Node2D = scene.instantiate()
	root.add_child(room)

	room.set_bed_variant("bed_cat_mint")
	if room.get_current_bed_variant() != "bed_cat_mint":
		push_error("bed mint failed")
		quit(1)
		return

	var layer: Node2D = room.get_node("RoomRoot/FurnitureLayer")
	if layer.get_child_count() != 1:
		push_error("expected 1 bed sprite")
		quit(1)
		return

	var sprite: Sprite2D = layer.get_child(0)
	if sprite.texture == null or not sprite.visible:
		push_error("bed should be visible")
		quit(1)
		return

	room.set_bed_variant("bed_cat_none")
	if sprite.visible:
		push_error("none bed should hide sprite")
		quit(1)
		return

	var item_tabs: HBoxContainer = room.get_node("IsoHUD/Safe/VBox/ItemTabBar")
	if item_tabs.get_child_count() < 2:
		push_error("expected furniture tabs")
		quit(1)
		return

	print("ISO_BED_TEST_OK variant=%s" % room.get_current_bed_variant())
	quit(0)
