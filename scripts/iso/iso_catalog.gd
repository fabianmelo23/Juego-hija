extends Control
## Inventario lateral compacto: cálido, con cierre y drag-and-drop.

const CasaUiTheme := preload("res://scripts/ui/casa_ui_theme.gd")

signal drag_started(item_id: String, variant_id: String, texture: Texture2D)
signal drag_updated(screen_pos: Vector2)
signal drag_dropped(item_id: String, variant_id: String, screen_pos: Vector2)
signal drag_cancelled
signal ambient_selected(category: String, variant_id: String)
signal close_requested

const PANEL_W := 200.0

const CATEGORIES := [
	{
		"id": "inventory",
		"name": "Mochila",
		"items": [
			{"id": "bed", "name": "Cama", "kind": "placeable", "default": "bed_cat_blush", "preview": "res://assets/art/iso/furniture/bed_cat_blush.png"},
			{"id": "table", "name": "Mesa", "kind": "placeable", "default": "table_low_wood", "preview": "res://assets/art/iso/furniture/table_low_wood.png"},
			{"id": "scratcher", "name": "Rascador", "kind": "placeable", "default": "scratcher_wood", "preview": "res://assets/art/iso/furniture/scratcher_wood.png"},
			{"id": "bowl", "name": "Plato", "kind": "placeable", "default": "bowl_food_full", "preview": "res://assets/art/iso/furniture/bowl_food_full.png"},
			{"id": "rug", "name": "Alfombra", "kind": "placeable", "default": "rug_small_blush", "preview": "res://assets/art/iso/rugs/rug_small_blush.png"},
			{"id": "toy", "name": "Pelota", "kind": "placeable", "default": "toy_ball_red", "preview": "res://assets/art/iso/furniture/toy_ball_red.png"},
		],
	},
	{
		"id": "ambient",
		"name": "Cuarto",
		"items": [
			{"id": "floor", "name": "Piso", "kind": "ambient"},
			{"id": "wall", "name": "Pared", "kind": "ambient"},
			{"id": "wallpaper", "name": "Papel", "kind": "ambient"},
			{"id": "window", "name": "Ventana", "kind": "ambient"},
			{"id": "light", "name": "Luz", "kind": "ambient"},
		],
	},
]

var inventory: GameInventory
var free_items: Node2D
var _dragging := false
var _drag_item: Dictionary = {}
var _category_box: HBoxContainer
var _items_box: VBoxContainer
var _title: Label
var _current_cat := "inventory"
var _panel: PanelContainer


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE # el fondo no bloquea el cuarto
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_chrome()
	show_category("inventory")


func bind_inventory(inv: GameInventory) -> void:
	inventory = inv
	refresh()


func bind_free_items(items: Node2D) -> void:
	free_items = items
	refresh()


func refresh() -> void:
	show_category(_current_cat)


func _is_placed(item_id: String) -> bool:
	return free_items != null and free_items.has_method("has_item") and free_items.has_item(item_id)


func _build_chrome() -> void:
	_panel = PanelContainer.new()
	_panel.name = "Drawer"
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	CasaUiTheme.apply_panel(_panel, "drawer")
	_panel.anchor_left = 0.0
	_panel.anchor_top = 0.10
	_panel.anchor_right = 0.0
	_panel.anchor_bottom = 0.78
	_panel.offset_left = 10.0
	_panel.offset_top = 0.0
	_panel.offset_right = 10.0 + PANEL_W
	_panel.offset_bottom = 0.0
	add_child(_panel)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	_panel.add_child(root)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 6)
	root.add_child(header)

	_title = Label.new()
	_title.text = "Mochila"
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	CasaUiTheme.apply_label(_title, "title", 20)
	header.add_child(_title)

	var close_btn := Button.new()
	close_btn.text = "✕"
	close_btn.custom_minimum_size = Vector2(44, 44)
	close_btn.tooltip_text = "Cerrar"
	CasaUiTheme.apply_button(close_btn, "danger", 18)
	close_btn.pressed.connect(func() -> void:
		close_requested.emit()
	)
	header.add_child(close_btn)

	_category_box = HBoxContainer.new()
	_category_box.add_theme_constant_override("separation", 6)
	root.add_child(_category_box)
	_rebuild_tabs()

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)

	_items_box = VBoxContainer.new()
	_items_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_items_box.add_theme_constant_override("separation", 8)
	scroll.add_child(_items_box)

	var hint := Label.new()
	hint.text = "Arrastra · ✕ para cerrar"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	CasaUiTheme.apply_label(hint, "muted", 12)
	root.add_child(hint)

	var done := Button.new()
	done.text = "Listo"
	done.custom_minimum_size = Vector2(0, 48)
	CasaUiTheme.apply_button(done, "primary", 18)
	done.pressed.connect(func() -> void:
		close_requested.emit()
	)
	root.add_child(done)


func _rebuild_tabs() -> void:
	for child in _category_box.get_children():
		child.queue_free()
	for cat in CATEGORIES:
		var b := Button.new()
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size = Vector2(0, 40)
		b.text = str(cat["name"])
		var cid := str(cat["id"])
		var active := cid == _current_cat
		CasaUiTheme.apply_button(b, "tab_on" if active else "tab_off", 13)
		b.pressed.connect(func() -> void:
			show_category(cid)
		)
		_category_box.add_child(b)


func show_category(cat_id: String) -> void:
	_current_cat = cat_id
	_rebuild_tabs()
	for child in _items_box.get_children():
		child.queue_free()
	var cat_data: Dictionary = {}
	for c in CATEGORIES:
		if str(c["id"]) == cat_id:
			cat_data = c
			break
	if cat_data.is_empty():
		return
	_title.text = str(cat_data["name"])
	for item in cat_data["items"]:
		_items_box.add_child(_make_item_card(item))


func _make_item_card(item: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 72)
	CasaUiTheme.apply_panel(card, "card")

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	card.add_child(row)

	var preview_wrap := PanelContainer.new()
	preview_wrap.custom_minimum_size = Vector2(56, 56)
	var preview_bg := StyleBoxFlat.new()
	preview_bg.bg_color = Color(0.96, 0.90, 0.82, 1.0)
	preview_bg.set_corner_radius_all(12)
	preview_bg.border_color = CasaUiTheme.BORDER
	preview_bg.set_border_width_all(1)
	preview_wrap.add_theme_stylebox_override("panel", preview_bg)
	row.add_child(preview_wrap)

	var preview := TextureRect.new()
	preview.custom_minimum_size = Vector2(52, 52)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var preview_path := str(item.get("preview", ""))
	if preview_path != "" and ResourceLoader.exists(preview_path):
		preview.texture = load(preview_path)
	preview_wrap.add_child(preview)

	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(text_col)

	var item_id := str(item.get("id", ""))
	var count := 0
	if inventory:
		count = inventory.get_count(item_id)

	var label := Label.new()
	CasaUiTheme.apply_label(label, "body", 15)
	var kind := str(item.get("kind", ""))
	if kind == "placeable":
		var placed := _is_placed(item_id)
		if placed and count <= 0:
			label.text = str(item.get("name", item_id))
		else:
			label.text = "%s  ×%d" % [str(item.get("name", item_id)), count]
	else:
		label.text = str(item.get("name", item_id))
	text_col.add_child(label)

	var sub := Label.new()
	CasaUiTheme.apply_label(sub, "muted", 11)
	text_col.add_child(sub)

	if kind == "placeable":
		var placed := _is_placed(item_id)
		var can_drag := count > 0 or placed
		if placed and count <= 0:
			sub.text = "En el cuarto · mover"
		elif can_drag:
			sub.text = "Mantén y arrastra"
		else:
			sub.text = "Sin unidades"
			card.modulate = Color(1, 1, 1, 0.55)
		if can_drag:
			card.gui_input.connect(func(event: InputEvent) -> void:
				_on_card_input(event, item, preview.texture)
			)
	else:
		sub.text = "Cambiar estilo"
		var btn := Button.new()
		btn.text = "Elegir"
		btn.custom_minimum_size = Vector2(0, 34)
		CasaUiTheme.apply_button(btn, "accent", 13)
		btn.pressed.connect(func() -> void:
			ambient_selected.emit(str(item["id"]), "")
		)
		text_col.add_child(btn)
	return card


func _on_card_input(event: InputEvent, item: Dictionary, tex: Texture2D) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_start_drag(item, tex)
		accept_event()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_start_drag(item, tex)
		accept_event()


func _start_drag(item: Dictionary, tex: Texture2D) -> void:
	var item_id := str(item.get("id", ""))
	var placed := _is_placed(item_id)
	if inventory and not inventory.can_use(item_id) and not placed:
		return
	_dragging = true
	_drag_item = item.duplicate(true)
	var variant := str(item.get("default", item_id))
	drag_started.emit(item_id, variant, tex)


func _input(event: InputEvent) -> void:
	if not _dragging:
		return
	if event is InputEventScreenDrag:
		drag_updated.emit(event.position)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
		drag_updated.emit(event.position)
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch and not event.pressed:
		_finish_drag(event.position)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_finish_drag(event.position)
		get_viewport().set_input_as_handled()


func _finish_drag(screen_pos: Vector2) -> void:
	if not _dragging:
		return
	_dragging = false
	var item := _drag_item
	_drag_item = {}
	if _panel and _panel.get_global_rect().has_point(screen_pos):
		drag_cancelled.emit()
		return
	drag_dropped.emit(str(item.get("id", "")), str(item.get("default", "")), screen_pos)


func is_dragging() -> bool:
	return _dragging
