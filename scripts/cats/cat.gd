extends Node2D
## Primer gato jugable — necesidades simples y reacciones placeholder.

signal needs_changed(hunger: float, energy: float, happiness: float)
signal selected_changed(is_selected: bool)
signal reacted(message: String)

@export var cat_name: String = "Miel"
@export var hunger: float = 55.0
@export var energy: float = 70.0
@export var happiness: float = 60.0

## Decaimiento suave para que se note en una sesión corta de prueba.
@export var hunger_decay_per_sec: float = 0.7
@export var energy_decay_per_sec: float = 0.35
@export var happiness_decay_per_sec: float = 0.45

@onready var name_label: Label = get_node_or_null("NameLabel")
@onready var selection_ring: Node2D = get_node_or_null("SelectionRing")
@onready var mood_label: Label = get_node_or_null("MoodLabel")
@onready var body_sprite: Sprite2D = get_node_or_null("BodySprite")

var _selected: bool = false
var _body_parts: Array[Polygon2D] = []
var _base_colors: Dictionary = {}
var _react_tween: Tween
var _base_modulate: Color = Color.WHITE


func _ready() -> void:
	add_to_group("cats")
	if name_label:
		name_label.text = cat_name
	if selection_ring:
		selection_ring.visible = false
	if body_sprite:
		_base_modulate = body_sprite.modulate
	for child in get_children():
		if child is Polygon2D and child != selection_ring:
			_body_parts.append(child)
			_base_colors[child] = child.color
	_emit_needs()
	_update_mood_label()


func _process(delta: float) -> void:
	hunger = clampf(hunger - hunger_decay_per_sec * delta, 0.0, 100.0)
	energy = clampf(energy - energy_decay_per_sec * delta, 0.0, 100.0)
	happiness = clampf(happiness - happiness_decay_per_sec * delta, 0.0, 100.0)
	if hunger < 30.0:
		happiness = clampf(happiness - 0.25 * delta, 0.0, 100.0)
	_emit_needs()
	_update_mood_label()


func set_selected(value: bool) -> void:
	_selected = value
	if selection_ring:
		selection_ring.visible = value
	selected_changed.emit(value)


func is_selected() -> bool:
	return _selected


func contains_point(world_point: Vector2) -> bool:
	var center := global_position + Vector2(0, -18)
	return center.distance_to(world_point) <= 52.0


func feed() -> Dictionary:
	return _do_care("feed")


func pet() -> Dictionary:
	return _do_care("pet")


func play_with() -> Dictionary:
	return _do_care("play")


func sleep_cat() -> Dictionary:
	return _do_care("sleep")


func _do_care(action: String) -> Dictionary:
	var result: Dictionary
	match action:
		"feed":
			if hunger >= 92.0:
				return {"ok": false, "message": "%s ya está llena" % cat_name, "huellitas": 0}
			hunger = minf(100.0, hunger + 34.0)
			happiness = minf(100.0, happiness + 6.0)
			result = {"ok": true, "message": "%s comió rico" % cat_name, "huellitas": 1, "flash": Color(1.0, 0.85, 0.45, 1.0), "react": "%s: ¡Ñam ñam!" % cat_name}
		"pet":
			if hunger < 18.0:
				return {"ok": false, "message": "%s tiene mucha hambre para mimos" % cat_name, "huellitas": 0}
			happiness = minf(100.0, happiness + 22.0)
			result = {"ok": true, "message": "%s está feliz con tus mimos" % cat_name, "huellitas": 1, "flash": Color(1.0, 0.75, 0.85, 1.0), "react": "%s: mrrrp" % cat_name}
		"play":
			if energy < 20.0:
				return {"ok": false, "message": "%s está muy cansada para jugar" % cat_name, "huellitas": 0}
			if hunger < 15.0:
				return {"ok": false, "message": "%s necesita comer antes de jugar" % cat_name, "huellitas": 0}
			energy = maxf(0.0, energy - 18.0)
			happiness = minf(100.0, happiness + 28.0)
			hunger = maxf(0.0, hunger - 6.0)
			result = {"ok": true, "message": "%s jugó un rato" % cat_name, "huellitas": 1, "flash": Color(0.7, 0.95, 0.75, 1.0), "react": "%s: ¡a jugar!" % cat_name}
		"sleep":
			if energy >= 92.0:
				return {"ok": false, "message": "%s no tiene sueño ahora" % cat_name, "huellitas": 0}
			energy = minf(100.0, energy + 40.0)
			hunger = maxf(0.0, hunger - 4.0)
			result = {"ok": true, "message": "%s durmió una siesta" % cat_name, "huellitas": 1, "flash": Color(0.7, 0.8, 1.0, 1.0), "react": "%s: zzz..." % cat_name}
		_:
			return {"ok": false, "message": "Acción desconocida", "huellitas": 0}

	_emit_needs()
	_update_mood_label()
	_play_react(result["flash"])
	reacted.emit(result["react"])
	return result


func _emit_needs() -> void:
	needs_changed.emit(hunger, energy, happiness)


func _update_mood_label() -> void:
	if mood_label == null:
		return
	var lowest := minf(hunger, minf(energy, happiness))
	if lowest < 25.0:
		if hunger <= energy and hunger <= happiness:
			mood_label.text = "tiene hambre"
		elif energy <= happiness:
			mood_label.text = "está cansada"
		else:
			mood_label.text = "está triste"
	elif lowest < 50.0:
		mood_label.text = "regular"
	elif happiness >= 80.0:
		mood_label.text = "muy feliz"
	else:
		mood_label.text = "contenta"


func _play_react(flash_color: Color) -> void:
	if _react_tween:
		_react_tween.kill()
	scale = Vector2.ONE
	for part in _body_parts:
		part.color = _base_colors[part]
	if body_sprite:
		body_sprite.modulate = _base_modulate
	_react_tween = create_tween()
	_react_tween.set_parallel(true)
	_react_tween.tween_property(self, "scale", Vector2(1.12, 1.12), 0.12)
	for part in _body_parts:
		_react_tween.tween_property(part, "color", flash_color, 0.12)
	if body_sprite:
		_react_tween.tween_property(body_sprite, "modulate", flash_color, 0.12)
	_react_tween.set_parallel(false)
	_react_tween.tween_property(self, "scale", Vector2.ONE, 0.18)
	_react_tween.set_parallel(true)
	for part in _body_parts:
		_react_tween.tween_property(part, "color", _base_colors[part], 0.18)
	if body_sprite:
		_react_tween.tween_property(body_sprite, "modulate", _base_modulate, 0.18)
