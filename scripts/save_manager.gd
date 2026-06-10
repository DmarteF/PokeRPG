extends Node

const SETTINGS_PATH = "user://settings.json"
const SAVES_DIR = "user://saves"
const MAX_SAVE_SLOTS = 3
const DEFAULT_SETTINGS = {
	"music_enabled": true,
	"sfx_enabled": true,
	"language": "en",
}

var _settings: Dictionary = DEFAULT_SETTINGS.duplicate(true)


func _ready() -> void:
	load_settings()


func load_settings() -> Dictionary:
	_settings = DEFAULT_SETTINGS.duplicate(true)

	if not FileAccess.file_exists(SETTINGS_PATH):
		return _settings.duplicate(true)

	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file == null:
		return _settings.duplicate(true)

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		var parsed_settings: Dictionary = parsed
		for key in DEFAULT_SETTINGS.keys():
			if parsed_settings.has(key):
				_settings[key] = parsed_settings[key]

	return _settings.duplicate(true)


func save_settings(settings: Dictionary) -> void:
	for key in DEFAULT_SETTINGS.keys():
		if settings.has(key):
			_settings[key] = settings[key]

	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(_settings, "\t"))


func get_settings() -> Dictionary:
	return _settings.duplicate(true)


func create_save(slot: int, player_name: String, avatar_id: int) -> Dictionary:
	_ensure_saves_dir()

	var clean_name := player_name.strip_edges()
	if clean_name == "":
		clean_name = "Player"

	var now := Time.get_datetime_string_from_system()
	var save_slot := clampi(slot, 1, MAX_SAVE_SLOTS)
	var save_data := {
		"slot": save_slot,
		"player_name": clean_name,
		"avatar_id": clampi(avatar_id, 1, 3),
		"money": 3000,
		"level": 0,
		"created_at": now,
		"updated_at": now,
		"current_scene": "HomeScreen",
		"current_map": "",
		"settings_language": str(_settings.get("language", "en")),
	}

	var file := FileAccess.open(_save_path(save_slot), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(save_data, "\t"))

	return save_data


func get_save(slot: int) -> Dictionary:
	var path := _save_path(slot)
	if not FileAccess.file_exists(path):
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}

	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}

	var save_data: Dictionary = parsed
	return save_data


func get_all_saves() -> Array:
	var saves := []
	for slot in range(1, MAX_SAVE_SLOTS + 1):
		saves.append(get_save(slot))
	return saves


func load_save(slot: int) -> Dictionary:
	var save_data := get_save(slot)
	if save_data.is_empty():
		return {}

	save_data["updated_at"] = Time.get_datetime_string_from_system()
	var file := FileAccess.open(_save_path(slot), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(save_data, "\t"))

	return save_data


func delete_save(slot: int) -> void:
	if not has_save(slot):
		return

	var dir := DirAccess.open(SAVES_DIR)
	if dir != null:
		dir.remove(_save_file_name(slot))


func has_save(slot: int) -> bool:
	return FileAccess.file_exists(_save_path(slot))


func _ensure_saves_dir() -> void:
	var dir := DirAccess.open("user://")
	if dir != null and not dir.dir_exists("saves"):
		dir.make_dir_recursive("saves")


func _save_path(slot: int) -> String:
	return "%s/%s" % [SAVES_DIR, _save_file_name(slot)]


func _save_file_name(slot: int) -> String:
	return "save_%d.json" % clampi(slot, 1, MAX_SAVE_SLOTS)
