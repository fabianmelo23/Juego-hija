extends SceneTree
## Prueba headless: Miel + cuidados en cuarto vacío.


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	if FileAccess.file_exists("user://progress.json"):
		DirAccess.remove_absolute("user://progress.json")
	if FileAccess.file_exists("user://iso_free_layout_v2.json"):
		DirAccess.remove_absolute("user://iso_free_layout_v2.json")

	var scene: PackedScene = load("res://scenes/iso/iso_room.tscn")
	var room: Node2D = scene.instantiate()
	root.add_child(room)

	var gameplay: Node = room.get_node("Gameplay")
	if gameplay.cat == null:
		push_error("cat missing")
		quit(1)
		return

	gameplay.select_cat()
	var before: float = float(gameplay.cat.hunger)
	gameplay.do_care("feed")
	if float(gameplay.cat.hunger) <= before:
		push_error("feed should raise hunger")
		quit(1)
		return

	var free: Node2D = room.get_node("RoomRoot/FreeItems")
	if not room.inventory.consume("bed"):
		push_error("bed not in inventory")
		quit(1)
		return
	free.place_or_move("bed", "bed_cat_cream", Vector2(40, 80))

	gameplay.buy_treat()
	if not bool(gameplay.missions.flags.get("bought", false)):
		push_error("buy flag not set")
		quit(1)
		return

	print(
		"ISO_CARE_TEST_OK hunger=%.1f huellitas=%d mission=%s"
		% [gameplay.cat.hunger, gameplay.huellitas, str(gameplay.missions.get_current().get("id", ""))]
	)
	quit(0)
