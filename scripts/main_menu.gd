extends Control

const UI = preload("res://scripts/ui_factory.gd")


func _ready() -> void:
	UI.setup_screen(self)
	UI.add_background(self)
	UI.add_texture(self, "res://assets/ui/logo_pokerpg_512x200.png", Vector2(30, 70), Vector2(300, 118), "Logo", TextureRect.STRETCH_KEEP_ASPECT_CENTERED)

	UI.add_orange_button(self, "Load Game", Vector2(70, 260), Vector2(220, 48), Callable(self, "_show_load_game"), "LoadGame")
	UI.add_orange_button(self, "New Game", Vector2(70, 320), Vector2(220, 48), Callable(self, "_start_new_game"), "NewGame")
	UI.add_orange_button(self, "Options", Vector2(70, 380), Vector2(220, 48), Callable(self, "_show_options"), "Options")
	UI.add_orange_button(self, "About", Vector2(70, 440), Vector2(220, 48), Callable(self, "_show_about"), "About")


func _start_new_game() -> void:
	get_tree().change_scene_to_file("res://HomeScreen.tscn")


func _show_load_game() -> void:
	UI.show_message_popup(self, "Load Game", "Load Game placeholder")


func _show_options() -> void:
	UI.show_message_popup(self, "Options", "Options coming soon")


func _show_about() -> void:
	UI.show_message_popup(self, "About", "PokeRPG private remake")
