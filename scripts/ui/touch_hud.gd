extends CanvasLayer
## HUD táctil: cuidados, mochila, misiones y tienda.

signal action_pressed(action_id: String)
signal care_action_pressed(action_id: String)
signal inventory_item_pressed(item_id: String)
signal build_action_pressed(action_id: String)
signal shop_item_pressed(item_id: String)

@onready var toast_label: Label = $SafeArea/Root/Toast
@onready var huellitas_label: Label = $SafeArea/Root/TopBar/HuellitasLabel
@onready var mission_hint: Label = $SafeArea/Root/TopBar/TitleBox/MissionHint
@onready var bottom_bar: HBoxContainer = $SafeArea/Root/BottomBar
@onready var cat_panel: PanelContainer = $SafeArea/Root/CatPanel
@onready var cat_title: Label = $SafeArea/Root/CatPanel/VBox/CatTitle
@onready var hunger_bar: ProgressBar = $SafeArea/Root/CatPanel/VBox/HungerRow/HungerBar
@onready var energy_bar: ProgressBar = $SafeArea/Root/CatPanel/VBox/EnergyRow/EnergyBar
@onready var happiness_bar: ProgressBar = $SafeArea/Root/CatPanel/VBox/HappyRow/HappyBar
@onready var care_bar: HBoxContainer = $SafeArea/Root/CareBar
@onready var inventory_panel: PanelContainer = $SafeArea/Root/InventoryPanel
@onready var inventory_list: VBoxContainer = $SafeArea/Root/InventoryPanel/VBox/ItemList
@onready var build_bar: HBoxContainer = $SafeArea/Root/BuildBar
@onready var mission_panel: PanelContainer = $SafeArea/Root/MissionPanel
@onready var mission_title: Label = $SafeArea/Root/MissionPanel/VBox/MissionTitle
@onready var mission_progress: Label = $SafeArea/Root/MissionPanel/VBox/MissionProgress
@onready var mission_detail: Label = $SafeArea/Root/MissionPanel/VBox/MissionDetail
@onready var mission_reward: Label = $SafeArea/Root/MissionPanel/VBox/MissionReward
@onready var close_mission: Button = $SafeArea/Root/MissionPanel/VBox/CloseMission
@onready var shop_panel: PanelContainer = $SafeArea/Root/ShopPanel
@onready var shop_list: VBoxContainer = $SafeArea/Root/ShopPanel/VBox/ShopList
@onready var close_shop: Button = $SafeArea/Root/ShopPanel/VBox/CloseShop

var _toast_tween: Tween
var huellitas: int = 0


func _ready() -> void:
	set_huellitas(0)
	toast_label.visible = false
	cat_panel.visible = false
	care_bar.visible = false
	inventory_panel.visible = false
	build_bar.visible = false
	mission_panel.visible = false
	shop_panel.visible = false
	for button in bottom_bar.get_children():
		if button is Button:
			button.pressed.connect(_on_button_pressed.bind(String(button.name)))
	for button in care_bar.get_children():
		if button is Button:
			button.pressed.connect(_on_care_button_pressed.bind(String(button.name)))
	for button in build_bar.get_children():
		if button is Button:
			button.pressed.connect(_on_build_button_pressed.bind(String(button.name)))
	close_mission.pressed.connect(hide_mission)
	close_shop.pressed.connect(hide_shop)


func _on_button_pressed(button_name: String) -> void:
	action_pressed.emit(button_name.to_lower())


func _on_care_button_pressed(button_name: String) -> void:
	care_action_pressed.emit(button_name.to_lower())


func _on_build_button_pressed(button_name: String) -> void:
	build_action_pressed.emit(button_name.to_lower())


func set_huellitas(amount: int) -> void:
	huellitas = max(0, amount)
	huellitas_label.text = "Huellitas: %d" % huellitas


func add_huellitas(amount: int) -> void:
	set_huellitas(huellitas + amount)


func spend_huellitas(amount: int) -> bool:
	if huellitas < amount:
		return false
	set_huellitas(huellitas - amount)
	return true


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


func set_mission_hint(text: String) -> void:
	mission_hint.text = text


func show_cat_status(cat_name: String, hunger: float, energy: float, happiness: float) -> void:
	_hide_overlay_panels()
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


func show_inventory(rows: Array) -> void:
	hide_cat_status()
	hide_mission()
	hide_shop()
	inventory_panel.visible = true
	for child in inventory_list.get_children():
		child.queue_free()
	for row in rows:
		var id := str(row.get("id", ""))
		var item_name := str(row.get("name", id))
		var count := int(row.get("count", 0))
		var button := Button.new()
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(0, 64)
		button.add_theme_font_size_override("font_size", 22)
		button.text = "%s  (%d)" % [item_name, count]
		button.disabled = count <= 0
		button.pressed.connect(func() -> void:
			inventory_item_pressed.emit(id)
		)
		inventory_list.add_child(button)


func hide_inventory() -> void:
	inventory_panel.visible = false


func is_inventory_open() -> bool:
	return inventory_panel.visible


func show_mission(mission: Dictionary) -> void:
	hide_cat_status()
	hide_inventory()
	hide_shop()
	mission_panel.visible = true
	mission_title.text = str(mission.get("title", "Misión"))
	if bool(mission.get("done", false)):
		mission_progress.text = "Completado"
		mission_reward.text = "Sigue jugando a tu ritmo"
	else:
		mission_progress.text = "Misión %d / %d" % [int(mission.get("index", 1)), int(mission.get("total", 1))]
		mission_reward.text = "Recompensa: %d Huellitas" % int(mission.get("reward", 0))
	mission_detail.text = str(mission.get("detail", ""))


func hide_mission() -> void:
	mission_panel.visible = false


func show_shop(rows: Array) -> void:
	hide_cat_status()
	hide_inventory()
	hide_mission()
	shop_panel.visible = true
	for child in shop_list.get_children():
		child.queue_free()
	for row in rows:
		var id := str(row.get("id", ""))
		var item_name := str(row.get("name", id))
		var price := int(row.get("price", 0))
		var affordable := bool(row.get("affordable", true))
		var button := Button.new()
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(0, 64)
		button.add_theme_font_size_override("font_size", 22)
		button.text = "%s — %d Huellitas" % [item_name, price]
		button.disabled = not affordable
		button.pressed.connect(func() -> void:
			shop_item_pressed.emit(id)
		)
		shop_list.add_child(button)


func hide_shop() -> void:
	shop_panel.visible = false


func is_shop_open() -> bool:
	return shop_panel.visible


func show_build_bar(show: bool) -> void:
	build_bar.visible = show


func set_decorate_chrome(active: bool) -> void:
	show_build_bar(active)
	if active:
		hide_cat_status()
		_hide_overlay_panels()


func _hide_overlay_panels() -> void:
	hide_inventory()
	hide_mission()
	hide_shop()
