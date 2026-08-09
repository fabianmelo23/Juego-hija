extends SceneTree
## Prueba rápida headless del Hito 1 (necesidades y cuidados).


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var cat_scene: PackedScene = load("res://scenes/cats/cat.tscn")
	var cat: Node2D = cat_scene.instantiate()
	root.add_child(cat)

	var before_hunger: float = cat.hunger
	var feed_result: Dictionary = cat.feed()
	if feed_result.get("ok", false) != true:
		push_error("feed should succeed")
		quit(1)
		return
	if cat.hunger <= before_hunger:
		push_error("hunger should rise")
		quit(1)
		return

	var pet_result: Dictionary = cat.pet()
	if pet_result.get("ok", false) != true:
		push_error("pet should succeed")
		quit(1)
		return

	var play_result: Dictionary = cat.play_with()
	if not play_result.has("ok"):
		push_error("play should return result")
		quit(1)
		return

	print("HITO1_TEST_OK hunger=%.1f energy=%.1f happiness=%.1f" % [cat.hunger, cat.energy, cat.happiness])
	quit(0)
