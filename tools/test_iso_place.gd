extends SceneTree
## Prueba headless: colocación libre en grid iso.


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	if FileAccess.file_exists("user://iso_layout.json"):
		DirAccess.remove_absolute("user://iso_layout.json")
	if FileAccess.file_exists("user://progress.json"):
		DirAccess.remove_absolute("user://progress.json")

	var scene: PackedScene = load("res://scenes/iso/iso_room.tscn")
	var room: Node2D = scene.instantiate()
	root.add_child(room)

	room.set_bed_variant("bed_cat_mint")
	if not room.move_furniture_to("bed", Vector2i(0, 0)):
		push_error("should place bed at 0,0")
		quit(1)
		return
	if room.get_furniture_cell("bed") != Vector2i(0, 0):
		push_error("bed cell not updated")
		quit(1)
		return

	# 2×2 no cabe en el borde derecho.
	if room.move_furniture_to("bed", Vector2i(7, 7)):
		push_error("bed should not fit at 7,7")
		quit(1)
		return

	room.set_scratcher_variant("scratcher_wood")
	if not room.move_furniture_to("scratcher", Vector2i(6, 0)):
		push_error("scratcher place failed")
		quit(1)
		return

	# Choque hard: cama en (0,0)-(1,1), rascador no puede ir a (1,0)
	if room.move_furniture_to("scratcher", Vector2i(1, 0)):
		push_error("scratcher should collide with bed")
		quit(1)
		return

	# Persistencia
	if not FileAccess.file_exists("user://iso_layout.json"):
		push_error("layout file missing")
		quit(1)
		return

	room.queue_free()
	await process_frame

	var room2: Node2D = scene.instantiate()
	root.add_child(room2)
	if room2.get_furniture_cell("bed") != Vector2i(0, 0):
		push_error("bed cell not restored from save")
		quit(1)
		return
	if room2.get_current_bed_variant() != "bed_cat_mint":
		push_error("bed variant not restored")
		quit(1)
		return

	print("ISO_PLACE_TEST_OK bed=%s scratcher=%s" % [
		str(room2.get_furniture_cell("bed")),
		str(room2.get_furniture_cell("scratcher")),
	])
	quit(0)
