extends SceneTree
## Prueba headless del Hito 3 (misiones + tienda).


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	# Limpia progreso previo de pruebas.
	if FileAccess.file_exists(MissionSystem.SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(MissionSystem.SAVE_PATH))

	var missions := MissionSystem.new()
	var current: Dictionary = missions.get_current()
	if str(current.get("id", "")) != "greet":
		push_error("first mission should be greet")
		quit(1)
		return

	var r1: Dictionary = missions.notify("greet")
	if not bool(r1.get("completed", false)):
		push_error("greet should complete")
		quit(1)
		return

	var r2: Dictionary = missions.notify("feed")
	if not bool(r2.get("completed", false)):
		push_error("feed should complete")
		quit(1)
		return

	var r3: Dictionary = missions.notify("place", {"item_id": "bed"})
	if not bool(r3.get("completed", false)):
		push_error("place bed should complete place_bed mission")
		quit(1)
		return

	var shop_toy: Dictionary = ShopCatalog.by_id("toy")
	if int(shop_toy.get("price", 0)) <= 0:
		push_error("toy should have price")
		quit(1)
		return

	print(
		"HITO3_TEST_OK next=%s toy_price=%d reward_feed=%d"
		% [str(missions.get_current().get("id", "")), int(shop_toy["price"]), int(r2.get("reward", 0))]
	)
	quit(0)
