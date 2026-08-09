class_name MissionSystem
extends RefCounted
## Cadena de misiones cortas para guiar el tutorial implícito.

signal mission_changed(mission: Dictionary)
signal mission_completed(mission: Dictionary)

const SAVE_PATH := "user://progress.json"

var current_index: int = 0
var completed_ids: Dictionary = {}
var flags: Dictionary = {
	"greeted": false,
	"fed": false,
	"placed_bed": false,
	"petted": false,
	"bought": false,
	"slept": false,
	"placed_count": 0,
}

var _missions: Array[Dictionary] = [
	{
		"id": "greet",
		"title": "Saluda a Miel",
		"detail": "Toca a Miel para conocerla.",
		"event": "greet",
		"reward": 3,
	},
	{
		"id": "feed",
		"title": "Dale de comer",
		"detail": "Usa Comer para alimentar a Miel.",
		"event": "feed",
		"reward": 4,
	},
	{
		"id": "place_bed",
		"title": "Pon una cama",
		"detail": "En Decorar → Cama, elige un color para colocarla.",
		"event": "place_bed",
		"reward": 5,
	},
	{
		"id": "pet",
		"title": "Dale mimos",
		"detail": "Acaricia a Miel con Mimos.",
		"event": "pet",
		"reward": 4,
	},
	{
		"id": "buy",
		"title": "Compra en la tienda",
		"detail": "Abre Tienda y compra una golosina con Huellitas.",
		"event": "buy",
		"reward": 5,
	},
	{
		"id": "sleep",
		"title": "Hora de dormir",
		"detail": "Haz que Miel tome una siesta.",
		"event": "sleep",
		"reward": 4,
	},
	{
		"id": "happy",
		"title": "Hazla muy feliz",
		"detail": "Sube la Felicidad de Miel hasta “muy feliz”.",
		"event": "happy",
		"reward": 6,
	},
	{
		"id": "decorate",
		"title": "Decora un poco más",
		"detail": "En Decorar, coloca al menos 3 cosas (cama, plato, rascador...).",
		"event": "decorate3",
		"reward": 8,
	},
]


func get_current() -> Dictionary:
	if current_index >= _missions.size():
		return {
			"id": "done",
			"title": "¡Todas las misiones!",
			"detail": "Ya completaste las misiones de la Versión 1. Sigue cuidando y decorando.",
			"reward": 0,
			"done": true,
		}
	var mission: Dictionary = _missions[current_index].duplicate()
	mission["done"] = false
	mission["index"] = current_index + 1
	mission["total"] = _missions.size()
	return mission


func notify(event_id: String, payload: Dictionary = {}) -> Dictionary:
	_apply_event(event_id, payload)
	if current_index >= _missions.size():
		return {"completed": false}
	var mission: Dictionary = _missions[current_index]
	if str(mission.get("event", "")) != event_id and not _matches_special(mission, event_id):
		return {"completed": false}
	if not _is_satisfied(mission):
		return {"completed": false}

	completed_ids[str(mission["id"])] = true
	var reward := int(mission.get("reward", 0))
	current_index += 1
	save_progress()
	var completed: Dictionary = mission.duplicate()
	mission_completed.emit(completed)
	mission_changed.emit(get_current())
	return {"completed": true, "mission": completed, "reward": reward}


func _matches_special(mission: Dictionary, event_id: String) -> bool:
	# place_bed escucha place con payload; decorate3 escucha place.
	var mid := str(mission.get("id", ""))
	if mid == "place_bed" and event_id == "place":
		return true
	if mid == "decorate" and event_id == "place":
		return true
	if mid == "happy" and event_id == "happy":
		return true
	return false


func _apply_event(event_id: String, payload: Dictionary) -> void:
	match event_id:
		"greet":
			flags["greeted"] = true
		"feed":
			flags["fed"] = true
		"pet":
			flags["petted"] = true
		"sleep":
			flags["slept"] = true
		"buy":
			flags["bought"] = true
		"place":
			flags["placed_count"] = int(flags.get("placed_count", 0)) + 1
			if str(payload.get("item_id", "")) == "bed":
				flags["placed_bed"] = true
		"happy":
			pass


func _is_satisfied(mission: Dictionary) -> bool:
	match str(mission.get("id", "")):
		"greet":
			return bool(flags.get("greeted", false))
		"feed":
			return bool(flags.get("fed", false))
		"place_bed":
			return bool(flags.get("placed_bed", false))
		"pet":
			return bool(flags.get("petted", false))
		"buy":
			return bool(flags.get("bought", false))
		"sleep":
			return bool(flags.get("slept", false))
		"happy":
			return true # el evento happy solo se envía si ya cumple
		"decorate":
			return int(flags.get("placed_count", 0)) >= 3
		_:
			return false


func save_progress(extra: Dictionary = {}) -> void:
	var payload := {
		"current_index": current_index,
		"completed_ids": completed_ids,
		"flags": flags,
	}
	for key in extra.keys():
		payload[key] = extra[key]
	# Conserva huellitas si ya había archivo.
	if FileAccess.file_exists(SAVE_PATH) and not extra.has("huellitas"):
		var existing: Variant = _read_json()
		if typeof(existing) == TYPE_DICTIONARY and existing.has("huellitas"):
			payload["huellitas"] = existing["huellitas"]
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(payload))
	file.close()


func load_progress() -> Dictionary:
	var data: Variant = _read_json()
	if typeof(data) != TYPE_DICTIONARY:
		return {}
	current_index = int(data.get("current_index", 0))
	completed_ids = data.get("completed_ids", {})
	if typeof(completed_ids) != TYPE_DICTIONARY:
		completed_ids = {}
	var loaded_flags = data.get("flags", {})
	if typeof(loaded_flags) == TYPE_DICTIONARY:
		for key in loaded_flags.keys():
			flags[key] = loaded_flags[key]
	return data


func _read_json() -> Variant:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var text := file.get_as_text()
	file.close()
	return JSON.parse_string(text)
