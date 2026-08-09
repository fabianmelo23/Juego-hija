extends SceneTree
## Mover, girar 360° y quitar muebles colocados.


func _init() -> void:
	call_deferred("_run")


func _fail(msg: String) -> void:
	push_error("FAIL: " + msg)
	quit(1)


func _run() -> void:
	if FileAccess.file_exists("user://iso_free_layout_v2.json"):
		DirAccess.remove_absolute("user://iso_free_layout_v2.json")

	var scene: PackedScene = load("res://scenes/iso/iso_room.tscn")
	var room: Node2D = scene.instantiate()
	root.add_child(room)
	await process_frame
	await process_frame

	var free: Node2D = room.get_node("RoomRoot/FreeItems")
	room.inventory.consume("table")
	free.place_or_move("table", "table_low_wood", Vector2(40, 120), 0.0)

	if not free.has_item("table"):
		_fail("mesa no colocada")
		return

	free.set_rotation_deg("table", 90.0)
	if not is_equal_approx(free.get_rotation_deg("table"), 90.0):
		_fail("rotación 90 falló")
		return

	free.rotate_by("table", 270.0)
	var rot: float = free.get_rotation_deg("table")
	if not is_equal_approx(rot, 0.0):
		_fail("360 wrap falló: %s" % rot)
		return

	free.rotate_by("table", 45.0)
	free.place_or_move("table", "table_low_wood", Vector2(80, 160))
	if free.get_rotation_deg("table") != 45.0:
		_fail("mover debe conservar rotación")
		return
	var pos: Vector2 = free._items["table"]["pos"]
	if pos.distance_to(Vector2(80, 160)) > 0.1:
		_fail("mover no actualizó posición")
		return

	var sprite: Sprite2D = free._items["table"]["sprite"]
	if not is_equal_approx(sprite.rotation_degrees, 45.0):
		_fail("sprite sin rotación visual")
		return

	var hit: String = free.pick_at(Vector2(80, 160))
	if hit != "table":
		_fail("pick_at no encontró mesa en su pivote (got %s)" % hit)
		return

	var before: int = room.inventory.get_count("table")
	free.remove_item("table")
	if free.has_item("table"):
		_fail("mesa no se quitó")
		return
	# La señal item_removed suma al inventario (conectada en room setup).
	await process_frame
	if room.inventory.get_count("table") != before + 1:
		_fail("quitar no devolvió a inventario")
		return

	# Persistencia de rotación
	room.inventory.consume("bed")
	free.place_or_move("bed", "bed_cat_blush", Vector2(10, 20), 135.0)
	free.save_layout()
	free.clear_all(false)
	if free.has_item("bed"):
		_fail("clear_all falló")
		return
	free.load_layout()
	if not free.has_item("bed"):
		_fail("load no restauró cama")
		return
	if not is_equal_approx(free.get_rotation_deg("bed"), 135.0):
		_fail("load perdió rotación")
		return

	print("OK test_iso_item_edit")
	quit(0)
