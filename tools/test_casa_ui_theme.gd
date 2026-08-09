extends SceneTree
## Smoke test del tema cálido compartido.


func _init() -> void:
	call_deferred("_run")


func _fail(msg: String) -> void:
	push_error("FAIL: " + msg)
	quit(1)


func _run() -> void:
	var ThemeScript = load("res://scripts/ui/casa_ui_theme.gd")
	if ThemeScript == null:
		_fail("no carga casa_ui_theme.gd")
		return
	var panel: StyleBoxFlat = ThemeScript.panel("drawer")
	if panel.bg_color.a < 0.9:
		_fail("panel drawer sin opacidad")
		return
	var btn := Button.new()
	root.add_child(btn)
	ThemeScript.apply_button(btn, "primary", 16)
	if btn.get_theme_stylebox("normal") == null:
		_fail("botón sin stylebox")
		return

	var packed: PackedScene = load("res://scenes/iso/iso_room.tscn")
	var room: Node = packed.instantiate()
	root.add_child(room)
	await process_frame
	await process_frame

	var care: PanelContainer = room.get_node_or_null("IsoHUD/Safe/VBox/CarePanel") as PanelContainer
	if care == null:
		_fail("falta CarePanel")
		return
	var sb := care.get_theme_stylebox("panel")
	if sb == null:
		_fail("CarePanel sin estilo cálido")
		return

	var mode_bar: HBoxContainer = room.get_node("IsoHUD/Safe/VBox/ModeBar")
	if mode_bar.get_child_count() < 4:
		_fail("ModeBar incompleta")
		return
	var first: Button = mode_bar.get_child(0) as Button
	if first.get_theme_stylebox("normal") == null:
		_fail("botón de modo sin estilo")
		return

	print("OK test_casa_ui_theme")
	quit(0)
