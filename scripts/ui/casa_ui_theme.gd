extends RefCounted
## Paleta cálida de Casa de Gatos: crema, madera, rubor y salvia.

# Superficies
const CREAM := Color(0.99, 0.96, 0.91, 0.98) # #FDF5E8
const CREAM_SOFT := Color(1.0, 0.98, 0.95, 1.0) # #FFFAF2
const WOOD := Color(0.78, 0.62, 0.45, 1.0) # #C79E73
const WOOD_DEEP := Color(0.55, 0.38, 0.26, 1.0) # #8C6142
const SAGE := Color(0.47, 0.66, 0.55, 1.0) # #78A88C
const SAGE_DEEP := Color(0.34, 0.52, 0.42, 1.0) # #57856B
const BLUSH := Color(0.90, 0.58, 0.52, 1.0) # #E59485
const BLUSH_DEEP := Color(0.78, 0.42, 0.38, 1.0) # #C76B61
const INK := Color(0.27, 0.20, 0.16, 1.0) # #453329
const INK_SOFT := Color(0.42, 0.32, 0.26, 1.0) # #6B5242
const MUTED := Color(0.52, 0.44, 0.38, 1.0) # #857061
const BORDER := Color(0.72, 0.60, 0.48, 1.0) # #B8997A
const SHADOW := Color(0.28, 0.18, 0.12, 0.20)

# Barras de necesidades
const BAR_HUNGER := Color(0.92, 0.62, 0.42, 1.0)
const BAR_ENERGY := Color(0.55, 0.72, 0.88, 1.0)
const BAR_HAPPY := Color(0.90, 0.72, 0.42, 1.0)
const BAR_BG := Color(0.93, 0.88, 0.82, 1.0)


static func panel(kind: String = "panel") -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	match kind:
		"drawer":
			sb.bg_color = CREAM
			sb.border_color = WOOD
			sb.set_border_width_all(2)
			sb.set_corner_radius_all(20)
			sb.shadow_color = SHADOW
			sb.shadow_size = 10
			sb.shadow_offset = Vector2(2, 4)
			sb.content_margin_left = 12
			sb.content_margin_right = 12
			sb.content_margin_top = 12
			sb.content_margin_bottom = 12
		"card":
			sb.bg_color = CREAM_SOFT
			sb.border_color = Color(BORDER.r, BORDER.g, BORDER.b, 0.85)
			sb.set_border_width_all(1)
			sb.set_corner_radius_all(14)
			sb.content_margin_left = 10
			sb.content_margin_right = 10
			sb.content_margin_top = 8
			sb.content_margin_bottom = 8
		"toast":
			sb.bg_color = Color(CREAM.r, CREAM.g, CREAM.b, 0.94)
			sb.border_color = WOOD
			sb.set_border_width_all(2)
			sb.set_corner_radius_all(16)
			sb.shadow_color = SHADOW
			sb.shadow_size = 6
			sb.content_margin_left = 14
			sb.content_margin_right = 14
			sb.content_margin_top = 10
			sb.content_margin_bottom = 10
		_: # modal / care
			sb.bg_color = CREAM
			sb.border_color = WOOD
			sb.set_border_width_all(2)
			sb.set_corner_radius_all(18)
			sb.shadow_color = SHADOW
			sb.shadow_size = 8
			sb.shadow_offset = Vector2(0, 3)
			sb.content_margin_left = 14
			sb.content_margin_right = 14
			sb.content_margin_top = 14
			sb.content_margin_bottom = 14
	return sb


static func button_style(kind: String = "primary", pressed: bool = false) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.set_corner_radius_all(14)
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	sb.set_border_width_all(1)
	match kind:
		"primary":
			sb.bg_color = SAGE_DEEP if pressed else SAGE
			sb.border_color = SAGE_DEEP
		"secondary":
			sb.bg_color = Color(0.96, 0.90, 0.82, 1.0) if not pressed else Color(0.90, 0.82, 0.70, 1.0)
			sb.border_color = BORDER
		"accent":
			sb.bg_color = BLUSH_DEEP if pressed else BLUSH
			sb.border_color = BLUSH_DEEP
		"ghost":
			sb.bg_color = Color(1, 1, 1, 0.35) if not pressed else Color(1, 1, 1, 0.55)
			sb.border_color = Color(BORDER.r, BORDER.g, BORDER.b, 0.7)
		"danger":
			sb.bg_color = BLUSH_DEEP if pressed else Color(0.86, 0.45, 0.40, 1.0)
			sb.border_color = Color(0.70, 0.32, 0.28, 1.0)
		"tab_on":
			sb.bg_color = SAGE
			sb.border_color = SAGE_DEEP
			sb.set_corner_radius_all(12)
		"tab_off":
			sb.bg_color = Color(0.95, 0.91, 0.86, 1.0)
			sb.border_color = BORDER
			sb.set_corner_radius_all(12)
		_:
			sb.bg_color = SAGE
			sb.border_color = SAGE_DEEP
	return sb


static func apply_button(button: Button, kind: String = "primary", font_size: int = 16) -> void:
	if button == null:
		return
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", font_size)
	var normal := button_style(kind, false)
	var hover := button_style(kind, false)
	hover.bg_color = hover.bg_color.lightened(0.08)
	var press := button_style(kind, true)
	var disabled := button_style("secondary", false)
	disabled.bg_color = Color(0.90, 0.86, 0.82, 1.0)
	disabled.border_color = Color(0.78, 0.72, 0.66, 1.0)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", press)
	button.add_theme_stylebox_override("disabled", disabled)
	var light_text := kind in ["primary", "accent", "danger", "tab_on"]
	var font_c := Color(1, 0.98, 0.96, 1) if light_text else INK
	button.add_theme_color_override("font_color", font_c)
	button.add_theme_color_override("font_hover_color", font_c)
	button.add_theme_color_override("font_pressed_color", font_c)
	button.add_theme_color_override("font_disabled_color", MUTED)


static func apply_panel(panel: PanelContainer, kind: String = "panel") -> void:
	if panel == null:
		return
	panel.add_theme_stylebox_override("panel", panel(kind))


static func apply_label(label: Label, role: String = "body", font_size: int = -1) -> void:
	if label == null:
		return
	var color := INK
	var size := 16
	match role:
		"title":
			color = INK
			size = 24
		"subtitle":
			color = INK_SOFT
			size = 18
		"muted":
			color = MUTED
			size = 13
		"accent":
			color = WOOD_DEEP
			size = 18
		_:
			color = INK
			size = 16
	if font_size > 0:
		size = font_size
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", size)


static func apply_progress(bar: ProgressBar, fill: Color) -> void:
	if bar == null:
		return
	var bg := StyleBoxFlat.new()
	bg.bg_color = BAR_BG
	bg.set_corner_radius_all(10)
	bg.content_margin_top = 2
	bg.content_margin_bottom = 2
	var fg := StyleBoxFlat.new()
	fg.bg_color = fill
	fg.set_corner_radius_all(10)
	bar.add_theme_stylebox_override("background", bg)
	bar.add_theme_stylebox_override("fill", fg)
	bar.show_percentage = false


static func style_hud(safe: Control) -> void:
	if safe == null:
		return
	for path_kind in [
		["VBox/CarePanel", "panel"],
		["MissionPanel", "panel"],
		["ShopPanel", "panel"],
	]:
		var node := safe.get_node_or_null(str(path_kind[0]))
		if node is PanelContainer:
			apply_panel(node, str(path_kind[1]))

	apply_label(safe.get_node_or_null("VBox/TopRow/Title") as Label, "title", 24)
	apply_label(safe.get_node_or_null("VBox/TopRow/HuellitasLabel") as Label, "accent", 18)
	apply_label(safe.get_node_or_null("VBox/MissionHint") as Label, "subtitle", 15)
	apply_label(safe.get_node_or_null("VBox/Hint") as Label, "muted", 14)
	apply_label(safe.get_node_or_null("VBox/Toast") as Label, "body", 17)
	apply_label(safe.get_node_or_null("VBox/CarePanel/VBox/CatTitle") as Label, "title", 22)
	apply_label(safe.get_node_or_null("MissionPanel/VBox/MissionTitle") as Label, "title", 26)
	apply_label(safe.get_node_or_null("MissionPanel/VBox/MissionProgress") as Label, "accent", 18)
	apply_label(safe.get_node_or_null("MissionPanel/VBox/MissionDetail") as Label, "body", 17)
	apply_label(safe.get_node_or_null("MissionPanel/VBox/MissionReward") as Label, "subtitle", 17)
	apply_label(safe.get_node_or_null("ShopPanel/VBox/ShopTitle") as Label, "title", 26)

	for row_label in [
		"VBox/CarePanel/VBox/HungerRow/L",
		"VBox/CarePanel/VBox/EnergyRow/L",
		"VBox/CarePanel/VBox/HappyRow/L",
	]:
		apply_label(safe.get_node_or_null(row_label) as Label, "body", 15)

	apply_progress(safe.get_node_or_null("VBox/CarePanel/VBox/HungerRow/HungerBar") as ProgressBar, BAR_HUNGER)
	apply_progress(safe.get_node_or_null("VBox/CarePanel/VBox/EnergyRow/EnergyBar") as ProgressBar, BAR_ENERGY)
	apply_progress(safe.get_node_or_null("VBox/CarePanel/VBox/HappyRow/HappyBar") as ProgressBar, BAR_HAPPY)

	apply_button(safe.get_node_or_null("MissionPanel/VBox/CloseMission") as Button, "secondary", 18)
	apply_button(safe.get_node_or_null("ShopPanel/VBox/CloseShop") as Button, "secondary", 18)

	_ensure_toast_shell(safe)


static func _ensure_toast_shell(safe: Control) -> void:
	var toast := safe.get_node_or_null("VBox/Toast") as Label
	if toast == null:
		return
	if toast.get_parent() is PanelContainer and toast.get_parent().name == "ToastShell":
		return
	var vbox := toast.get_parent()
	if vbox == null:
		return
	var idx := toast.get_index()
	var shell := PanelContainer.new()
	shell.name = "ToastShell"
	shell.visible = false
	shell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	apply_panel(shell, "toast")
	vbox.remove_child(toast)
	shell.add_child(toast)
	vbox.add_child(shell)
	vbox.move_child(shell, idx)
	# El gameplay sigue apuntando al Label; sincronizamos visibilidad.
	toast.visibility_changed.connect(func() -> void:
		shell.visible = toast.visible
	)
