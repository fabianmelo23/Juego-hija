extends SceneTree
## Prueba headless del Hito 2 (inventario + colocación + guardado).


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	# Evita que un layout guardado de otra prueba deje inventario vacío.
	if FileAccess.file_exists("user://room_layout.json"):
		DirAccess.remove_absolute(ProjectSettings.globalize_path("user://room_layout.json"))

	var deco_scene: PackedScene = load("res://scenes/furniture/room_decorator.tscn")
	var deco: Node2D = deco_scene.instantiate()
	root.add_child(deco)

	if deco.inventory.get_count("bed") < 1:
		push_error("should start with a bed")
		quit(1)
		return

	if not deco.select_item("bed"):
		push_error("select bed failed")
		quit(1)
		return

	var world_pos: Vector2 = deco.cell_to_world(Vector2i(1, 1)) + Vector2(10, 10)
	if not deco.handle_world_tap(world_pos):
		push_error("place bed failed")
		quit(1)
		return

	if deco.inventory.get_count("bed") != 0:
		push_error("bed should be consumed")
		quit(1)
		return

	deco.save_layout()
	if not FileAccess.file_exists(deco.SAVE_PATH):
		push_error("save file missing")
		quit(1)
		return

	print("HITO2_TEST_OK placed_bed inventory_toy=%d" % deco.inventory.get_count("toy"))
	quit(0)
