extends SceneTree
## Prueba headless del Ítem 04 (papel tapiz).


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene: PackedScene = load("res://scenes/iso/iso_room.tscn")
	var room: Node2D = scene.instantiate()
	root.add_child(room)

	room.set_wallpaper_variant("wallpaper_dots")
	if room.get_current_wallpaper_variant() != "wallpaper_dots":
		push_error("wallpaper dots failed")
		quit(1)
		return

	var left_layer: Node2D = room.get_node("RoomRoot/WallpaperLeftLayer")
	var right_layer: Node2D = room.get_node("RoomRoot/WallpaperRightLayer")
	if left_layer.get_child_count() != 8 or right_layer.get_child_count() != 8:
		push_error("expected 8 wallpaper sprites per side")
		quit(1)
		return

	var left_sprite: Sprite2D = left_layer.get_child(0)
	if left_sprite.texture == null or not left_sprite.visible:
		push_error("dots wallpaper should be visible with texture")
		quit(1)
		return

	room.set_wallpaper_variant("wallpaper_none")
	if left_sprite.visible:
		push_error("none wallpaper should hide overlays")
		quit(1)
		return

	room.set_wallpaper_variant("wallpaper_stripe")
	if room.get_current_wallpaper_variant() != "wallpaper_stripe":
		push_error("stripe wallpaper failed")
		quit(1)
		return

	print("ISO_WALLPAPER_TEST_OK variant=%s" % room.get_current_wallpaper_variant())
	quit(0)
