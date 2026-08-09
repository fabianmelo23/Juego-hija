extends Node
## Zoom y paneo sobre RoomRoot (sin Camera2D, el HUD queda fijo).

signal zoom_changed(zoom: float)

const MIN_ZOOM := 0.55
const MAX_ZOOM := 2.4
const ZOOM_STEP := 0.12

var target: Node2D
var zoom: float = 1.0
var pan: Vector2 = Vector2.ZERO
var base_position: Vector2 = Vector2.ZERO

var _dragging := false
var _last_pos := Vector2.ZERO
var _pinching := false
var _pinch_start_dist := 0.0
var _pinch_start_zoom := 1.0
var enabled := true
var pan_enabled := true


func setup(room_root: Node2D, initial_pos: Vector2) -> void:
	target = room_root
	base_position = initial_pos
	pan = Vector2.ZERO
	zoom = 1.0
	_apply()


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


func handle_input(event: InputEvent) -> bool:
	if not enabled or target == null:
		return false

	# Rueda / trackpad zoom (editor y algunos Android).
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_by(ZOOM_STEP)
			return true
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_by(-ZOOM_STEP)
			return true

	# Pinch zoom
	if event is InputEventMagnifyGesture:
		set_zoom(zoom * event.factor)
		return true
	if event is InputEventPanGesture:
		if pan_enabled:
			pan += event.delta
			_apply()
			return true

	# Two-finger pinch via touches approximated by magnify; also handle drag pan.
	if event is InputEventScreenTouch:
		if event.pressed:
			_dragging = true
			_last_pos = event.position
		else:
			_dragging = false
			_pinching = false
		return false

	if event is InputEventScreenDrag:
		if not pan_enabled:
			return false
		var rel: Vector2 = event.relative
		pan += rel
		_apply()
		return true

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		_dragging = event.pressed
		_last_pos = event.position
		return _dragging

	if event is InputEventMouseMotion and _dragging and pan_enabled:
		if event.button_mask & MOUSE_BUTTON_MASK_MIDDLE or event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
			pan += event.relative
			_apply()
			return true

	return false
