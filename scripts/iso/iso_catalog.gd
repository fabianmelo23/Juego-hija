extends Control
## Inventario lateral compacto: bonito, con cierre y drag-and-drop.

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


func _style_panel() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.98, 0.96, 0.93, 0.97)
	sb.border_color = Color(0.45, 0.55, 0.48, 1)
	sb.set_border_width_all(2)
	sb.corner_radius_top_left = 18
	sb.corner_radius_top_right = 18
	sb.corner_radius_bottom_left = 18
	sb.corner_radius_bottom_right = 18
	sb.shadow_color = Color(0.15, 0.18, 0.16, 0.22)
	sb.shadow_size = 8
	sb.shadow_offset = Vector2(2, 3)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	return sb


func _style_card() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(1.0, 0.99, 0.97, 1)
	sb.border_color = Color(0.72, 0.78, 0.72, 1)
	sb.set_border_width_all(1)
	sb.corner_radius_top_left = 14
	sb.corner_radius_top_right = 14
	sb.corner_radius_bottom_left = 14
	sb.corner_radius_bottom_right = 14
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	return sb


func _style_tab(active: bool) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	if active:
		sb.bg_color = Color(0.42, 0.62, 0.52, 1)
		sb.border_color = Color(0.30, 0.48, 0.40, 1)
	else:
		sb.bg_color = Color(0.90, 0.93, 0.90, 1)
		sb.border_color = Color(0.70, 0.78, 0.72, 1)
	sb.set_border_width_all(1)
	sb.corner_radius_top_left = 12
	sb.corner_radius_top_right = 12
	sb.corner_radius_bottom_left = 12
	sb.corner_radius_bottom_right = 12
	sb.content_margin_left = 6
	sb.content_margin_right = 6
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	return sb


func _build_chrome() -> void:
	# Panel flotante a la izquierda (no pantalla completa).
	_panel = PanelContainer.new()
	_panel.name = "Drawer"
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_panel.add_theme_stylebox_override("panel", _style_panel())
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
	_title.add_theme_font_size_override("font_size", 20)
	_title.add_theme_color_override("font_color", Color(0.22, 0.28, 0.24, 1))
	header.add_child(_title)

	var close_btn := Button.new()
	close_btn.focus_mode = Control.FOCUS_NONE
	close_btn.text = "✕"
	close_btn.custom_minimum_size = Vector2(44, 44)
	close_btn.add_theme_font_size_override("font_size", 20)
	close_btn.tooltip_text = "Cerrar"
	var close_style := StyleBoxFlat.new()
	close_style.bg_color = Color(0.86, 0.40, 0.38, 1)
	close_style.corner_radius_top_left = 12
	close_style.corner_radius_top_right = 12
	close_style.corner_radius_bottom_left = 12
	close_style.corner_radius_bottom_right = 12
	close_btn.add_theme_stylebox_override("normal", close_style)
	var close_hover := close_style.duplicate()
	close_hover.bg_color = Color(0.92, 0.48, 0.45, 1)
	close_btn.add_theme_stylebox_override("hover", close_hover)
	close_btn.add_theme_stylebox_override("pressed", close_hover)
	close_btn.add_theme_color_override("font_color", Color(1, 1, 1, 1))
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
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color(0.38, 0.42, 0.38, 1))
	root.add_child(hint)

	var done := Button.new()
	done.focus_mode = Control.FOCUS_NONE
	done.text = "Listo"
	done.custom_minimum_size = Vector2(0, 48)
	done.add_theme_font_size_override("font_size", 18)
	var done_style := StyleBoxFlat.new()
	done_style.bg_color = Color(0.42, 0.62, 0.52, 1)
	done_style.corner_radius_top_left = 14
	done_style.corner_radius_top_right = 14
	done_style.corner_radius_bottom_left = 14
	done_style.corner_radius_bottom_right = 14
	done.add_theme_stylebox_override("normal", done_style)
	done.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	done.pressed.connect(func() -> void:
		close_requested.emit()
	)
	root.add_child(done)


func _rebuild_tabs() -> void:
	for child in _category_box.get_children():
		child.queue_free()
	for cat in CATEGORIES:
		var b := Button.new()
		b.focus_mode = Control.FOCUS_NONE
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size = Vector2(0, 40)
		b.add_theme_font_size_override("font_size", 13)
		b.text = str(cat["name"])
		var cid := str(cat["id"])
		var active := cid == _current_cat
		b.add_theme_stylebox_override("normal", _style_tab(active))
		b.add_theme_stylebox_override("hover", _style_tab(active))
		b.add_theme_stylebox_override("pressed", _style_tab(true))
		if active:
			b.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		else:
			b.add_theme_color_override("font_color", Color(0.25, 0.32, 0.28, 1))
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
	card.add_theme_stylebox_override("panel", _style_card())

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	card.add_child(row)

	var preview := TextureRect.new()
	preview.custom_minimum_size = Vector2(56, 56)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var preview_path := str(item.get("preview", ""))
	if preview_path != "" and ResourceLoader.exists(preview_path):
		preview.texture = load(preview_path)
	row.add_child(preview)

	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(text_col)

	var item_id := str(item.get("id", ""))
	var count := 0
	if inventory:
		count = inventory.get_count(item_id)

	var label := Label.new()
	label.add_theme_font_size_override("font_size", 15)
	label.add_theme_color_override("font_color", Color(0.20, 0.24, 0.22, 1))
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
	sub.add_theme_font_size_override("font_size", 11)
	sub.add_theme_color_override("font_color", Color(0.42, 0.48, 0.44, 1))
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
			card.modulate = Color(1, 1, 1, 0.5)
		if can_drag:
			card.gui_input.connect(func(event: InputEvent) -> void:
				_on_card_input(event, item, preview.texture)
			)
	else:
		sub.text = "Cambiar estilo"
		var btn := Button.new()
		btn.focus_mode = Control.FOCUS_NONE
		btn.text = "Elegir"
		btn.custom_minimum_size = Vector2(0, 34)
		btn.add_theme_font_size_override("font_size", 13)
		var bs := StyleBoxFlat.new()
		bs.bg_color = Color(0.55, 0.70, 0.62, 1)
		bs.corner_radius_top_left = 10
		bs.corner_radius_top_right = 10
		bs.corner_radius_bottom_left = 10
		bs.corner_radius_bottom_right = 10
		btn.add_theme_stylebox_override("normal", bs)
		btn.add_theme_color_override("font_color", Color(1, 1, 1, 1))
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
	# Cancelar solo si suelta encima del cajón, no de toda la pantalla.
	if _panel and _panel.get_global_rect().has_point(screen_pos):
		drag_cancelled.emit()
		return
	drag_dropped.emit(str(item.get("id", "")), str(item.get("default", "")), screen_pos)


func is_dragging() -> bool:
	return _dragging
