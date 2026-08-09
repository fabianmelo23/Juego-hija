extends Node2D
## Orquesta toques en el mundo: mover jugadora si el toque no fue a la UI.

@onready var player: CharacterBody2D = $Player
@onready var touch_hud: CanvasLayer = $TouchHUD

## Zona caminable en coordenadas del mundo (casa + jardín).
@export var walk_rect: Rect2 = Rect2(-300, -480, 600, 960)


func _ready() -> void:
	touch_hud.action_pressed.connect(_on_hud_action)
	touch_hud.show_toast("Toca el suelo para caminar")


func _unhandled_input(event: InputEvent) -> void:
	var tap_pos: Variant = null
	if event is InputEventScreenTouch and event.pressed:
		tap_pos = event.position
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Evita doble disparo cuando el editor emula toque desde el ratón.
		if not ProjectSettings.get_setting("input_devices/pointing/emulate_touch_from_mouse", false):
			tap_pos = event.position
	if tap_pos != null:
		_try_walk_to(tap_pos)


func _try_walk_to(screen_position: Vector2) -> void:
	var world_pos := get_canvas_transform().affine_inverse() * screen_position
	if not walk_rect.has_point(world_pos):
		touch_hud.show_toast("Ahí no se puede caminar")
		return
	player.go_to(world_pos)


func _on_hud_action(action_id: String) -> void:
	match action_id:
		"inventory":
			touch_hud.show_toast("Inventario (próximo hito)")
		"mission":
			touch_hud.show_toast("Misiones (próximo hito)")
		"care":
			touch_hud.show_toast("Cuidar gatos (Hito 1)")
		"pause":
			touch_hud.show_toast("Pausa / guardar (próximo)")
