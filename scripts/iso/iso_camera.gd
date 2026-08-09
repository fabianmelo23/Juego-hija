extends Node
## Zoom (botones + pellizco) y paneo sobre RoomRoot.

signal zoom_changed(zoom: float)

const MIN_ZOOM := 0.55
const MAX_ZOOM := 2.4
const ZOOM_STEP := 0.12

var target: Node2D
var zoom: float = 1.0
var pan: Vector2 = Vector2.ZERO
var base_position: Vector2 = Vector2.ZERO

var enabled := true
var pan_enabled := true

var _touches: Dictionary = {} # index -> Vector2
var _pinching := false
var _pinch_start_dist := 0.0
var _pinch_start_zoom := 1.0
var _panning := false


func setup(room_root: Node2D, initial_pos: Vector2) -> void:
	target = room_root
	base_position = initial_pos
	pan = Vector2.ZERO
	zoom = 1.0
	_apply()


func _input(event: InputEvent) -> void:
	# Pellizco en _input (antes que el HUD) para que 2 dedos funcionen aunque toquen labels.
	if not enabled or target == null:
		return
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		if _handle_pinch_touch(event):
			get_viewport().set_input_as_handled()


func _handle_pinch_touch(event: InputEvent) -> bool:
	# Durante drag de muebles pan_enabled=false: limpiamos touches pero no hacemos zoom.
	var allow_pinch := pan_enabled
	if event is InputEventScreenTouch:
		if event.pressed:
			if not allow_pinch:
				return false
			_touches[event.index] = event.position
			if _touches.size() >= 2:
				_begin_pinch()
				_panning = false
				return true
		else:
			_touches.erase(event.index)
			var was_pinching := _pinching
			if _touches.size() < 2:
				_pinching = false
			if _touches.is_empty():
				_panning = false
			return was_pinching and allow_pinch
	if event is InputEventScreenDrag:
		if not allow_pinch:
			return false
		_touches[event.index] = event.position
		if _touches.size() >= 2:
			_update_pinch()
			return true
	return false


func _apply() -> void:
	if target == null:
		return
	target.scale = Vector2(zoom, zoom)
	target.position = base_position + pan


func set_zoom(value: float) -> void:
	zoom = clampf(value, MIN_ZOOM, MAX_ZOOM)
	_apply()
	zoom_changed.emit(zoom)


func zoom_by(delta: float) -> void:
	set_zoom(zoom + delta)


func reset_view() -> void:
	zoom = 1.0
	pan = Vector2.ZERO
	_apply()
	zoom_changed.emit(zoom)


func clear_gestures() -> void:
	_touches.clear()
	_pinching = false
	_panning = false


func handle_input(event: InputEvent) -> bool:
	if not enabled or target == null:
		return false

	# Rueda (editor / algunos dispositivos).
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_by(ZOOM_STEP)
			return true
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_by(-ZOOM_STEP)
			return true

	# Gestos nativos si existen.
	if event is InputEventMagnifyGesture:
		set_zoom(zoom * event.factor)
		return true
	if event is InputEventPanGesture and pan_enabled:
		pan += event.delta
		_apply()
		return true

	# Un dedo: pan (el pellizco de 2 dedos vive en _input).
	if event is InputEventScreenTouch:
		if event.pressed:
			if _touches.size() >= 2 or _pinching:
				return false
			if pan_enabled:
				_panning = true
				return false
		else:
			_panning = false
		return false

	if event is InputEventScreenDrag:
		if _pinching or _touches.size() >= 2:
			return false
		if pan_enabled and _panning:
			pan += event.relative
			_apply()
			return true
		return false

	return false


func _begin_pinch() -> void:
	var pts := _touch_points()
	if pts.size() < 2:
		return
	_pinching = true
	_pinch_start_dist = pts[0].distance_to(pts[1])
	_pinch_start_zoom = zoom
	if _pinch_start_dist < 1.0:
		_pinch_start_dist = 1.0


func _update_pinch() -> void:
	var pts := _touch_points()
	if pts.size() < 2:
		return
	if not _pinching:
		_begin_pinch()
		return
	var dist := pts[0].distance_to(pts[1])
	if _pinch_start_dist <= 0.0:
		return
	set_zoom(_pinch_start_zoom * (dist / _pinch_start_dist))


func _touch_points() -> Array[Vector2]:
	var pts: Array[Vector2] = []
	for key in _touches.keys():
		pts.append(_touches[key])
	return pts
