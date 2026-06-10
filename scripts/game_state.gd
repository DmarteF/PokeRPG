extends Node

var current_save_slot := 0
var player_name := ""
var avatar_id := 1
var money := 0
var level := 0


func apply_save(save_data: Dictionary) -> void:
	current_save_slot = int(save_data.get("slot", 0))
	player_name = str(save_data.get("player_name", ""))
	avatar_id = int(save_data.get("avatar_id", 1))
	money = int(save_data.get("money", 0))
	level = int(save_data.get("level", 0))


func clear() -> void:
	current_save_slot = 0
	player_name = ""
	avatar_id = 1
	money = 0
	level = 0
