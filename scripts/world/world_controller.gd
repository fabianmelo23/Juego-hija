extends Node2D
## Orquesta toques: gatos, caminar y decorar la casa.

@onready var player: CharacterBody2D = $Player
@onready var touch_hud: CanvasLayer = $TouchHUD
@onready var cat: Node2D = $Cat
@onready var decorator: Node2D = $RoomDecorator

## Zona caminable en coordenadas del mundo (casa + jardín).
@export var walk_rect: Rect2 = Rect2(-300, -480, 600, 960)

var _selected_cat: Node2D = null


func _ready() -> void:
	touch_hud.action_pressed.connect(_on_hud_action)
	touch_hud.care_action_pressed.connect(_on_care_action)
	touch_hud.inventory_item_pressed.connect(_on_inventory_item)
	touch_hud.build_action_pressed.connect(_on_build_action)
	decorator.placed.connect(_on_furniture_placed)
	decorator.layout_saved.connect(func() -> void:
		touch_hud.show_toast("Casa guardada")
	)
	decorator.inventory_changed.connect(_refresh_inventory_if_open)
	cat.needs_changed.connect(_on_cat_needs_changed)
	cat.reacted.connect(func(message: String) -> void:
		touch_hud.show_toast(message)
	)
	touch_hud.show_toast("Toca a Miel o abre la Mochila")


func _unhandled_input(event: InputEvent) -> void:
	var tap_pos: Variant = null
	if event is InputEventScreenTouch and event.pressed:
		tap_pos = event.position
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not ProjectSettings.get_setting("input_devices/pointing/emulate_touch_from_mouse", false):
			tap_pos = event.position
	if tap_pos != null:
		_handle_world_tap(tap_pos)


func _handle_world_tap(screen_position: Vector2) -> void:
	var world_pos := get_canvas_transform().affine_inverse() * screen_position

	if decorator.is_decorating():
		touch_hud.hide_inventory()
		if decorator.handle_world_tap(world_pos):
			touch_hud.show_toast("¡Mueble colocado!")
		else:
			decorator.update_ghost_from_world(world_pos)
			touch_hud.show_toast("Elige otra casilla de la casa")
		return

	var tapped_cat := _find_cat_at(world_pos)
	if tapped_cat != null:
		_select_cat(tapped_cat)
		return
	if not walk_rect.has_point(world_pos):
		touch_hud.show_toast("Ahí no se puede caminar")
		return
	_clear_selection()
	if touch_hud.is_inventory_open():
		touch_hud.hide_inventory()
	player.go_to(world_pos)


func _find_cat_at(world_pos: Vector2) -> Node2D:
	for node in get_tree().get_nodes_in_group("cats"):
		if node.has_method("contains_point") and node.contains_point(world_pos):
			return node
	return null


func _select_cat(target: Node2D) -> void:
	if decorator.is_decorating():
		return
	if _selected_cat == target:
		touch_hud.show_toast("Elige: Comer, Mimos, Jugar o Dormir")
		return
	if _selected_cat != null and _selected_cat.has_method("set_selected"):
		_selected_cat.set_selected(false)
	_selected_cat = target
	if _selected_cat.has_method("set_selected"):
		_selected_cat.set_selected(true)
	touch_hud.show_cat_status(
		_selected_cat.cat_name,
		_selected_cat.hunger,
		_selected_cat.energy,
		_selected_cat.happiness
	)
	touch_hud.show_toast("Cuidando a %s" % _selected_cat.cat_name)
	var approach := _selected_cat.global_position + Vector2(48, 10)
	if walk_rect.has_point(approach):
		player.go_to(approach)


func _clear_selection() -> void:
	if _selected_cat != null and _selected_cat.has_method("set_selected"):
		_selected_cat.set_selected(false)
	_selected_cat = null
	touch_hud.hide_cat_status()


func _on_cat_needs_changed(hunger: float, energy: float, happiness: float) -> void:
	if _selected_cat == null:
		return
	touch_hud.update_needs(hunger, energy, happiness)


func _on_hud_action(action_id: String) -> void:
	match action_id:
		"inventory":
			_open_inventory()
		"mission":
			touch_hud.show_toast("Misiones (próximo hito)")
		"care":
			if decorator.is_decorating():
				touch_hud.show_toast("Termina de decorar con Listo")
				return
			if _selected_cat == null:
				_select_cat(cat)
			else:
				touch_hud.show_toast("Usa Comer / Mimos / Jugar / Dormir")
		"pause":
			touch_hud.show_toast("Pausa / menú (próximo)")


func _open_inventory() -> void:
	_clear_selection()
	touch_hud.show_inventory(decorator.get_inventory_snapshot())
	touch_hud.show_toast("Elige un mueble")


func _refresh_inventory_if_open() -> void:
	if touch_hud.is_inventory_open():
		touch_hud.show_inventory(decorator.get_inventory_snapshot())


func _on_inventory_item(item_id: String) -> void:
	if decorator.select_item(item_id):
		touch_hud.hide_inventory()
		touch_hud.set_decorate_chrome(true)
		var data := FurnitureCatalog.by_id(item_id)
		touch_hud.show_toast("Toca la casa para poner: %s" % str(data.get("name", item_id)))
	else:
		touch_hud.show_toast("Ya no te queda de eso")


func _on_build_action(action_id: String) -> void:
	match action_id:
		"rotate":
			decorator.rotate_selected()
			touch_hud.show_toast("Girado")
		"save":
			decorator.save_layout()
		"cancel":
			decorator.save_layout()
			decorator.exit_decorate_mode()
			touch_hud.set_decorate_chrome(false)
			touch_hud.show_toast("Listo — casa guardada")


func _on_furniture_placed(item_id: String) -> void:
	touch_hud.add_huellitas(2)
	# Un hogar bonito anima a Miel.
	if item_id in ["bed", "toy", "scratcher"]:
		cat.happiness = minf(100.0, cat.happiness + 8.0)
	_refresh_inventory_if_open()


func _on_care_action(action_id: String) -> void:
	if _selected_cat == null:
		touch_hud.show_toast("Primero toca un gato")
		return

	var result: Dictionary
	match action_id:
		"feed":
			result = _selected_cat.feed()
		"pet":
			result = _selected_cat.pet()
		"play":
			result = _selected_cat.play_with()
		"sleep":
			result = _selected_cat.sleep_cat()
		_:
			touch_hud.show_toast("Acción no disponible")
			return

	touch_hud.show_toast(str(result.get("message", "")))
	if bool(result.get("ok", false)):
		touch_hud.add_huellitas(int(result.get("huellitas", 0)))
		touch_hud.update_needs(
			_selected_cat.hunger,
			_selected_cat.energy,
			_selected_cat.happiness
		)
