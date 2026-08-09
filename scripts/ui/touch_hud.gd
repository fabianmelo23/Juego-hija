extends CanvasLayer
## HUD táctil inferior — botones grandes para pulgar.

signal action_pressed(action_id: String)

@onready var toast_label: Label = $SafeArea/Root/Toast
@onready var huellitas_label: Label = $SafeArea/Root/TopBar/HuellitasLabel
@onready var bottom_bar: HBoxContainer = $SafeArea/Root/BottomBar

var _toast_tween: Tween
var huellitas: int = 0


func _ready() -> void:
	_set_huellitas(0)
	toast_label.visible = false
	for button in bottom_bar.get_children():
		if button is Button:
			button.pressed.connect(_on_button_pressed.bind(String(button.name)))


func _on_button_pressed(button_name: String) -> void:
	action_pressed.emit(button_name.to_lower())


func _set_huellitas(amount: int) -> void:
	huellitas = amount
	huellitas_label.text = "Huellitas: %d" % huellitas


func show_toast(text: String, duration: float = 1.6) -> void:
	toast_label.text = text
	toast_label.visible = true
	toast_label.modulate.a = 1.0
	if _toast_tween:
		_toast_tween.kill()
	_toast_tween = create_tween()
	_toast_tween.tween_interval(duration)
	_toast_tween.tween_property(toast_label, "modulate:a", 0.0, 0.35)
	_toast_tween.tween_callback(func() -> void:
		toast_label.visible = false
		toast_label.modulate.a = 1.0
	)
