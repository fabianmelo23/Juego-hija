extends CharacterBody2D
## Cuidadora inventada — movimiento por toque (tap-to-move).

signal arrived_at_target

@export var move_speed: float = 180.0
@export var arrive_distance: float = 6.0

var _target: Vector2
var _has_target: bool = false


func _ready() -> void:
	_target = global_position
	add_to_group("player")


func go_to(world_position: Vector2) -> void:
	_target = world_position
	_has_target = true


func stop_moving() -> void:
	_has_target = false
	velocity = Vector2.ZERO


func _physics_process(_delta: float) -> void:
	if not _has_target:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var to_target := _target - global_position
	if to_target.length() <= arrive_distance:
		global_position = _target
		_has_target = false
		velocity = Vector2.ZERO
		move_and_slide()
		arrived_at_target.emit()
		return

	velocity = to_target.normalized() * move_speed
	move_and_slide()
