extends SceneTree
## Verifica menú compacto con cierre y pellizco de zoom.


func _init() -> void:
	call_deferred("_run")


func _fail(msg: String) -> void:
	push_error("FAIL: " + msg)
	quit(1)


func _run() -> void:
	var packed: PackedScene = load("res://scenes/iso/iso_room.tscn")
	if packed == null:
		_fail("no se pudo cargar iso_room.tscn")
		return
	var room: Node = packed.instantiate()
	root.add_child(room)
	await process_frame
	await process_frame

	var catalog: Control = room.get_node_or_null("IsoHUD/Catalog") as Control
	if catalog == null:
		_fail("Catalog debe vivir bajo IsoHUD (no bajo Safe)")
		return
	if catalog.get_parent().name == "Safe":
		_fail("Catalog no debe ser hijo de Safe/MarginContainer")
		return

	# Abrir decorar
	room._set_catalog_visible(true)
	await process_frame
	if not catalog.visible:
		_fail("catálogo debería verse al decorar")
		return

	var drawer: Control = catalog.get_node_or_null("Drawer") as Control
	if drawer == null:
		_fail("falta Drawer flotante")
		return
	var drawer_w := drawer.get_global_rect().size.x
	var view_w := root.get_visible_rect().size.x
	if drawer_w <= 0.0:
		# Aún sin layout completo: usar offsets
		drawer_w = absf(drawer.offset_right - drawer.offset_left)
	if drawer_w > view_w * 0.55:
		_fail("drawer demasiado ancho (ocupa casi toda la pantalla): %s vs %s" % [drawer_w, view_w])
		return

	# Señal de cierre
	var closed := [false]
	catalog.close_requested.connect(func() -> void:
		closed[0] = true
	)
	# Simular botón Listo
	var done: Button = null
	for child in drawer.find_children("*", "Button", true, false):
		if child is Button and str(child.text) == "Listo":
			done = child
			break
	if done == null:
		_fail("falta botón Listo")
		return
	done.pressed.emit()
	await process_frame
	if not closed[0]:
		_fail("close_requested no se emitió")
		return

	room._on_catalog_close_requested()
	await process_frame
	if catalog.visible:
		_fail("catálogo debería ocultarse al cerrar")
		return

	# Pellizco
	var cam = room.camera_ctrl
	if cam == null:
		_fail("falta camera_ctrl")
		return
	var z0: float = cam.zoom
	var t1 := InputEventScreenTouch.new()
	t1.index = 0
	t1.pressed = true
	t1.position = Vector2(200, 400)
	cam._input(t1)
	var t2 := InputEventScreenTouch.new()
	t2.index = 1
	t2.pressed = true
	t2.position = Vector2(300, 400)
	cam._input(t2)
	var d1 := InputEventScreenDrag.new()
	d1.index = 0
	d1.position = Vector2(150, 400)
	d1.relative = Vector2(-50, 0)
	cam._input(d1)
	var d2 := InputEventScreenDrag.new()
	d2.index = 1
	d2.position = Vector2(350, 400)
	d2.relative = Vector2(50, 0)
	cam._input(d2)
	if is_equal_approx(cam.zoom, z0):
		_fail("pellizco no cambió el zoom (%s)" % cam.zoom)
		return
	if cam.zoom <= z0:
		_fail("alejar dedos debería aumentar zoom: %s -> %s" % [z0, cam.zoom])
		return

	print("OK test_iso_catalog_ui")
	quit(0)
