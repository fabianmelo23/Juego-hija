extends Node
## Cuidados, misiones y tienda mínima sobre el cuarto isométrico.

const CasaUiTheme := preload("res://scripts/ui/casa_ui_theme.gd")

signal mode_changed(mode: String)

const CAT_ORIGIN := Vector2i(4, 4)

var room: Node2D
var cat: Node2D
var missions: MissionSystem = MissionSystem.new()

var _mode: String = "care" # care | decorate
var _selected: bool = false
var huellitas: int = 0

# UI refs filled by setup()
var mode_bar: HBoxContainer
var decorate_tabs: Array = []
var care_panel: PanelContainer
var care_bar: HBoxContainer
var mission_panel: PanelContainer
var shop_panel: PanelContainer
var toast_label: Label
var huellitas_label: Label
var mission_hint: Label
var hunger_bar: ProgressBar
var energy_bar: ProgressBar
var happiness_bar: ProgressBar
var cat_title: Label
var mission_title: Label
var mission_progress: Label
var mission_detail: Label
var mission_reward: Label


func setup(host_room: Node2D) -> void:
	room = host_room
	_build_cat()
	_wire_cat()
	var saved := missions.load_progress()
	if saved.has("huellitas"):
		huellitas = int(saved["huellitas"])
	else:
		huellitas = 2
		_save()
	_refresh_huellitas()
	_refresh_mission_hint()
	set_mode("care")
	show_toast("Misión: %s" % str(missions.get_current().get("title", "")))


func _build_cat() -> void:
	var layer: Node2D = room.get_node("RoomRoot/CatLayer")
	for child in layer.get_children():
		child.queue_free()
	var packed: PackedScene = load("res://scenes/iso/iso_cat.tscn")
	cat = packed.instantiate()
	var anchor := IsoMath.grid_to_screen(CAT_ORIGIN)
	cat.position = anchor + Vector2(0, -8)
	cat.z_index = 40 + CAT_ORIGIN.x + CAT_ORIGIN.y
	layer.add_child(cat)


func _wire_cat() -> void:
	cat.needs_changed.connect(_on_needs_changed)
	cat.reacted.connect(func(message: String) -> void:
		show_toast(message)
	)


func set_mode(mode: String) -> void:
	_mode = mode
	var decorating := mode == "decorate"
	for c in decorate_tabs:
		if c:
			c.visible = decorating
	if care_panel:
		care_panel.visible = (mode == "care") and _selected
	if care_bar:
		care_bar.visible = (mode == "care") and _selected
	if mode != "care":
		_clear_selection()
	if mission_panel:
		mission_panel.visible = false
	if shop_panel:
		shop_panel.visible = false
	mode_changed.emit(mode)


func get_mode() -> String:
	return _mode


func handle_tap(screen_position: Vector2) -> bool:
	if _mode != "care":
		return false
	if mission_panel and mission_panel.visible:
		return false
	if shop_panel and shop_panel.visible:
		return false
	var world_pos: Vector2 = room.get_canvas_transform().affine_inverse() * screen_position
	if cat and cat.has_method("contains_point") and cat.contains_point(world_pos):
		select_cat()
		return true
	return false


func select_cat() -> void:
	_selected = true
	if cat.has_method("set_selected"):
		cat.set_selected(true)
	if care_panel:
		care_panel.visible = true
		cat_title.text = cat.cat_name
		hunger_bar.value = cat.hunger
		energy_bar.value = cat.energy
		happiness_bar.value = cat.happiness
	if care_bar:
		care_bar.visible = true
	show_toast("Cuidando a %s" % cat.cat_name)
	_handle_mission(missions.notify("greet"))


func _clear_selection() -> void:
	_selected = false
	if cat and cat.has_method("set_selected"):
		cat.set_selected(false)
	if care_panel:
		care_panel.visible = false
	if care_bar:
		care_bar.visible = false


func do_care(action_id: String) -> void:
	if not _selected or cat == null:
		show_toast("Primero toca a Miel")
		return
	var result: Dictionary
	match action_id:
		"feed":
			result = cat.feed()
			if bool(result.get("ok", false)) and room.has_method("on_cat_fed"):
				room.on_cat_fed()
		"pet":
			result = cat.pet()
		"play":
			result = cat.play_with()
		"sleep":
			result = cat.sleep_cat()
		_:
			show_toast("Acción no disponible")
			return
	show_toast(str(result.get("message", "")))
	if bool(result.get("ok", false)):
		huellitas += int(result.get("huellitas", 0))
		_refresh_huellitas()
		_update_bars()
		if action_id in ["feed", "pet", "sleep"]:
			_handle_mission(missions.notify(action_id))
		_save()


func notify_furniture_placed(item_id: String) -> void:
	if item_id in ["bed", "toy", "scratcher"] and cat:
		cat.happiness = minf(100.0, cat.happiness + 8.0)
		_update_bars()
	_handle_mission(missions.notify("place", {"item_id": item_id}))
	_save()


func open_mission() -> void:
	_clear_selection()
	if shop_panel:
		shop_panel.visible = false
	if mission_panel:
		mission_panel.visible = true
		var mission := missions.get_current()
		mission_title.text = str(mission.get("title", "Misión"))
		if bool(mission.get("done", false)):
			mission_progress.text = "Completado"
			mission_reward.text = "Sigue cuidando a tu ritmo"
		else:
			mission_progress.text = "Misión %d / %d" % [int(mission.get("index", 1)), int(mission.get("total", 1))]
			mission_reward.text = "Recompensa: %d Huellitas" % int(mission.get("reward", 0))
		mission_detail.text = str(mission.get("detail", ""))


func close_mission() -> void:
	if mission_panel:
		mission_panel.visible = false
	if room and room.has_method("_refresh_mode_button_styles"):
		room._refresh_mode_button_styles("care")


func open_shop() -> void:
	_clear_selection()
	if mission_panel:
		mission_panel.visible = false
	if shop_panel:
		shop_panel.visible = true
		_rebuild_shop()


func close_shop() -> void:
	if shop_panel:
		shop_panel.visible = false
	if room and room.has_method("_refresh_mode_button_styles"):
		room._refresh_mode_button_styles("care")


func buy_treat() -> void:
	var price := 3
	if huellitas < price:
		show_toast("Te faltan Huellitas")
		return
	huellitas -= price
	_refresh_huellitas()
	if cat:
		cat.happiness = minf(100.0, cat.happiness + 15.0)
		_update_bars()
	show_toast("Compraste golosina para Miel")
	_handle_mission(missions.notify("buy"))
	_save()
	_rebuild_shop()


func _rebuild_shop() -> void:
	if shop_panel == null:
		return
	var list: VBoxContainer = shop_panel.get_node("VBox/ShopList")
	for child in list.get_children():
		child.queue_free()
	var card := PanelContainer.new()
	CasaUiTheme.apply_panel(card, "card")
	list.add_child(card)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 8)
	card.add_child(col)
	var desc := Label.new()
	desc.text = "Un gusto dulce para Miel"
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	CasaUiTheme.apply_label(desc, "muted", 14)
	col.add_child(desc)
	var button := Button.new()
	button.custom_minimum_size = Vector2(0, 56)
	button.text = "Golosina — 3 Huellitas"
	button.disabled = huellitas < 3
	CasaUiTheme.apply_button(button, "primary", 18)
	button.pressed.connect(buy_treat)
	col.add_child(button)


func _on_needs_changed(hunger: float, energy: float, happiness: float) -> void:
	if _selected:
		hunger_bar.value = hunger
		energy_bar.value = energy
		happiness_bar.value = happiness
	var current := missions.get_current()
	if str(current.get("id", "")) == "happy" and happiness >= 80.0:
		_handle_mission(missions.notify("happy"))


func _update_bars() -> void:
	if _selected and cat:
		hunger_bar.value = cat.hunger
		energy_bar.value = cat.energy
		happiness_bar.value = cat.happiness


func _handle_mission(result: Dictionary) -> void:
	if not bool(result.get("completed", false)):
		_refresh_mission_hint()
		return
	var reward := int(result.get("reward", 0))
	var mission: Dictionary = result.get("mission", {})
	huellitas += reward
	_refresh_huellitas()
	show_toast("¡Misión lista! +%d Huellitas — %s" % [reward, str(mission.get("title", ""))], 2.2)
	_refresh_mission_hint()
	_save()


func _refresh_mission_hint() -> void:
	if mission_hint == null:
		return
	var mission := missions.get_current()
	if bool(mission.get("done", false)):
		mission_hint.text = "Misiones completadas"
	else:
		mission_hint.text = "Misión: %s" % str(mission.get("title", ""))


func _refresh_huellitas() -> void:
	if huellitas_label:
		huellitas_label.text = "Huellitas: %d" % huellitas


func _save() -> void:
	missions.save_progress({"huellitas": huellitas})


func show_toast(text: String, duration: float = 1.6) -> void:
	if toast_label == null:
		return
	toast_label.text = text
	toast_label.visible = true
	toast_label.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_interval(duration)
	tw.tween_property(toast_label, "modulate:a", 0.0, 0.3)
	tw.tween_callback(func() -> void:
		toast_label.visible = false
		toast_label.modulate.a = 1.0
	)
