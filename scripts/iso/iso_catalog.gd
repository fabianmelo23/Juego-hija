extends Control
## Menú izquierdo por categorías con preview y drag-and-drop al cuarto.

signal drag_started(item_id: String, variant_id: String, texture: Texture2D)
signal drag_updated(screen_pos: Vector2)
signal drag_dropped(item_id: String, variant_id: String, screen_pos: Vector2)
signal drag_cancelled
signal ambient_selected(category: String, variant_id: String)

const CATEGORIES := [
	{
		"id": "ambient",
		"name": "Ambiente",
		"items": [
			{"id": "floor", "name": "Piso", "kind": "ambient"},
			{"id": "wall", "name": "Pared", "kind": "ambient"},
			{"id": "wallpaper", "name": "Papel", "kind": "ambient"},
			{"id": "window", "name": "Ventana", "kind": "ambient"},
			{"id": "light", "name": "Luz", "kind": "ambient"},
		],
	},
	{
		"id": "furniture",
		"name": "Muebles",
		"items": [
			{"id": "bed", "name": "Cama", "kind": "placeable", "default": "bed_cat_blush", "preview": "res://assets/art/iso/furniture/bed_cat_blush.png", "stack_h": 0.0},
			{"id": "table", "name": "Mesa", "kind": "placeable", "default": "table_low_wood", "preview": "res://assets/art/iso/furniture/table_low_wood.png", "stack_h": 22.0},
			{"id": "scratcher", "name": "Rascador", "kind": "placeable", "default": "scratcher_wood", "preview": "res://assets/art/iso/furniture/scratcher_wood.png", "stack_h": 0.0},
			{"id": "bowl", "name": "Plato", "kind": "placeable", "default": "bowl_food_full", "preview": "res://assets/art/iso/furniture/bowl_food_full.png", "stack_h": 0.0},
		],
	},
	{
		"id": "decor",
		"name": "Decoración",
		"items": [
			{"id": "rug", "name": "Alfombra", "kind": "placeable", "default": "rug_small_blush", "preview": "res://assets/art/iso/rugs/rug_small_blush.png", "stack_h": 0.0},
			{"id": "toy", "name": "Pelota", "kind": "placeable", "default": "toy_ball_red", "preview": "res://assets/art/iso/furniture/toy_ball_red.png", "stack_h": 0.0},
		],
	},
]

var _dragging := false
var _drag_item: Dictionary = {}
var _category_box: HBoxContainer
var _items_box: VBoxContainer
var _title: Label
var _current_cat := "furniture"


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	custom_minimum_size = Vector2(168, 0)
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	_build_chrome()
	show_category("furniture")


func _build_chrome() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.93, 0.90, 0.86, 0.96)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	margin.add_child(root)

	_title = Label.new()
	_title.text = "Catálogo"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 18)
	_title.add_theme_color_override("font_color", Color(0.2, 0.15, 0.12, 1))
	root.add_child(_title)

	_category_box = HBoxContainer.new()
	_category_box.add_theme_constant_override("separation", 4)
	root.add_child(_category_box)
	for cat in CATEGORIES:
		var b := Button.new()
		b.focus_mode = Control.FOCUS_NONE
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size = Vector2(0, 40)
		b.add_theme_font_size_override("font_size", 12)
		b.text = str(cat["name"])
		var cid := str(cat["id"])
		b.pressed.connect(func() -> void:
			show_category(cid)
		)
		_category_box.add_child(b)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root.add_child(scroll)

	_items_box = VBoxContainer.new()
	_items_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_items_box.add_theme_constant_override("separation", 8)
	scroll.add_child(_items_box)

	var hint := Label.new()
	hint.text = "Arrastra al cuarto"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color(0.35, 0.28, 0.22, 1))
	root.add_child(hint)


func show_category(cat_id: String) -> void:
	_current_cat = cat_id
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
	card.custom_minimum_size = Vector2(0, 88)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 4)
	card.add_child(v)

	var label := Label.new()
	label.text = str(item.get("name", item.get("id", "")))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 14)
	v.add_child(label)

	var preview := TextureRect.new()
	preview.custom_minimum_size = Vector2(0, 48)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var preview_path := str(item.get("preview", ""))
	if preview_path != "" and ResourceLoader.exists(preview_path):
		preview.texture = load(preview_path)
	v.add_child(preview)

	var kind := str(item.get("kind", ""))
	if kind == "placeable":
		card.gui_input.connect(func(event: InputEvent) -> void:
			_on_card_input(event, item, preview.texture)
		)
	else:
		var btn := Button.new()
		btn.focus_mode = Control.FOCUS_NONE
		btn.text = "Elegir…"
		btn.custom_minimum_size = Vector2(0, 36)
		btn.pressed.connect(func() -> void:
			ambient_selected.emit(str(item["id"]), "")
		)
		v.add_child(btn)
	return card


func _on_card_input(event: InputEvent, item: Dictionary, tex: Texture2D) -> void:
	if event is InputEventScreenTouch and event.pressed:
		_start_drag(item, tex, event.position)
		accept_event()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_start_drag(item, tex, event.position)
		accept_event()


func _start_drag(item: Dictionary, tex: Texture2D, _local_pos: Vector2) -> void:
	_dragging = true
	_drag_item = item.duplicate(true)
	var variant := str(item.get("default", item.get("id", "")))
	drag_started.emit(str(item["id"]), variant, tex)


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
	# Si suelta sobre el catálogo, cancela.
	if get_global_rect().has_point(screen_pos):
		drag_cancelled.emit()
		return
	drag_dropped.emit(str(item.get("id", "")), str(item.get("default", "")), screen_pos)


func is_dragging() -> bool:
	return _dragging
