extends CanvasLayer
## HUD táctil: barra inferior + panel de cuidados del gato.

signal action_pressed(action_id: String)
signal care_action_pressed(action_id: String)

@onready var toast_label: Label = $SafeArea/Root/Toast
@onready var huellitas_label: Label = $SafeArea/Root/TopBar/HuellitasLabel
@onready var bottom_bar: HBoxContainer = $SafeArea/Root/BottomBar
@onready var cat_panel: PanelContainer = $SafeArea/Root/CatPanel
@onready var cat_title: Label = $SafeArea/Root/CatPanel/VBox/CatTitle
@onready var hunger_bar: ProgressBar = $SafeArea/Root/CatPanel/VBox/HungerRow/HungerBar
@onready var energy_bar: ProgressBar = $SafeArea/Root/CatPanel/VBox/EnergyRow/EnergyBar
@onready var happiness_bar: ProgressBar = $SafeArea/Root/CatPanel/VBox/HappyRow/HappyBar
@onready var care_bar: HBoxContainer = $SafeArea/Root/CareBar

var _toast_tween: Tween
var huellitas: int = 0


func _ready() -> void:
	set_huellitas(0)
	toast_label.visible = false
	cat_panel.visible = false
	care_bar.visible = false
	for button in bottom_bar.get_children():
		if button is Button:
			button.pressed.connect(_on_button_pressed.bind(String(button.name)))
	for button in care_bar.get_children():
		if button is Button:
			button.pressed.connect(_on_care_button_pressed.bind(String(button.name)))


func _on_button_pressed(button_name: String) -> void:
	action_pressed.emit(button_name.to_lower())


func _on_care_button_pressed(button_name: String) -> void:
	care_action_pressed.emit(button_name.to_lower())


func set_huellitas(amount: int) -> void:
	huellitas = max(0, amount)
	huellitas_label.text = "Huellitas: %d" % huellitas


func add_huellitas(amount: int) -> void:
	set_huellitas(huellitas + amount)


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


func show_cat_status(cat_name: String, hunger: float, energy: float, happiness: float) -> void:
	cat_panel.visible = true
	care_bar.visible = true
	cat_title.text = cat_name
	hunger_bar.value = hunger
	energy_bar.value = energy
	happiness_bar.value = happiness


func hide_cat_status() -> void:
	cat_panel.visible = false
	care_bar.visible = false


func update_needs(hunger: float, energy: float, happiness: float) -> void:
	if not cat_panel.visible:
		return
	hunger_bar.value = hunger
	energy_bar.value = energy
	happiness_bar.value = happiness
