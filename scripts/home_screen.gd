extends Control

const UI = preload("res://scripts/ui_factory.gd")

const TEXT = {
	"en": {
		"hello": "Hello %s,",
		"player": "Player",
		"money": "Money",
		"starter": "Starter",
		"progress": "Progress",
		"badges": "%d badges",
		"explore_world": "Explore World",
		"my_pokemon": "My Pokemon",
		"bag": "Bag",
		"pokedex": "PokeDex",
		"options": "Options",
		"exit": "Exit",
		"my_pokemon_soon": "My Pokemon coming soon",
		"bag_soon": "Bag coming soon",
		"pokedex_soon": "PokeDex coming soon",
		"return_menu": "Return to Main Menu?",
		"yes": "Yes",
		"no": "No",
		"music": "Music",
		"sfx": "Sound Effects",
		"language": "Language",
		"apply": "Apply",
		"cancel": "Cancel",
		"world_map": "World Map",
		"available": "Available",
		"coming_soon": "Coming soon",
		"map_soon": "Coming soon",
		"type": "Type",
		"forest": "Forest Map",
		"fire": "Fire Map",
		"water": "Water Map",
		"cave": "Cave Map",
		"ice": "Ice Map",
		"mansion": "Mansion Map",
		"factory": "Factory Map",
		"electric": "Electric Map",
		"desert": "Desert Map",
		"ghost": "Ghost Tower",
		"dragon": "Dragon Valley",
		"safari": "Safari Zone",
	},
	"pt": {
		"hello": "Olá %s,",
		"player": "Jogador",
		"money": "Dinheiro",
		"starter": "Inicial",
		"progress": "Progresso",
		"badges": "%d insígnias",
		"explore_world": "Explorar Mundo",
		"my_pokemon": "Meus Pokémon",
		"bag": "Mochila",
		"pokedex": "PokéDex",
		"options": "Opções",
		"exit": "Sair",
		"my_pokemon_soon": "Meus Pokémon em breve",
		"bag_soon": "Mochila em breve",
		"pokedex_soon": "PokéDex em breve",
		"return_menu": "Voltar ao Menu Principal?",
		"yes": "Sim",
		"no": "Não",
		"music": "Música",
		"sfx": "Efeitos Sonoros",
		"language": "Idioma",
		"apply": "Aplicar",
		"cancel": "Cancelar",
		"world_map": "Mapa do Mundo",
		"available": "Disponível",
		"coming_soon": "Em breve",
		"map_soon": "Em breve",
		"type": "Tipo",
		"forest": "Floresta",
		"fire": "Mapa de Fogo",
		"water": "Mapa de Água",
		"cave": "Caverna",
		"ice": "Mapa de Gelo",
		"mansion": "Mansão",
		"factory": "Fábrica",
		"electric": "Mapa Elétrico",
		"desert": "Deserto",
		"ghost": "Torre Fantasma",
		"dragon": "Vale dos Dragões",
		"safari": "Zona Safari",
	},
}

const WORLD_MAPS = [
	{"key": "forest", "type": "Grass", "icon": "res://assets/maps/map_forest_64.png", "available": true},
	{"key": "fire", "type": "Fire", "icon": "res://assets/maps/map_fire_64.png", "available": false},
	{"key": "water", "type": "Water", "icon": "", "available": false},
	{"key": "cave", "type": "Rock", "icon": "res://assets/maps/map_cave_64.png", "available": false},
	{"key": "ice", "type": "Ice", "icon": "res://assets/maps/map_ice_64.png", "available": false},
	{"key": "mansion", "type": "Mystery", "icon": "res://assets/maps/map_mansion_64.png", "available": false},
	{"key": "factory", "type": "Steel", "icon": "res://assets/maps/map_factory_64.png", "available": false},
	{"key": "electric", "type": "Electric", "icon": "", "available": false},
	{"key": "desert", "type": "Ground", "icon": "", "available": false},
	{"key": "ghost", "type": "Ghost", "icon": "", "available": false},
	{"key": "dragon", "type": "Dragon", "icon": "", "available": false},
	{"key": "safari", "type": "Mixed", "icon": "", "available": false},
]

var settings: Dictionary = {}
var save_data: Dictionary = {}
var world_popup: Control


func _ready() -> void:
	UI.setup_screen(self)
	settings = SaveManager.load_settings()
	save_data = SaveManager.get_current_save()
	if save_data.is_empty() and SaveManager.has_save(1):
		save_data = SaveManager.load_save(1)
	if not save_data.is_empty():
		GameState.apply_save(save_data)
	_build_screen()


func _build_screen() -> void:
	UI.add_background(self)
	UI.add_topbar(self)
	UI.add_label(self, "Home", Vector2(60, 6), Vector2(240, 32), 20, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "TopTitle")
	UI.add_texture(self, "res://assets/ui/logo_pokerpg_512x200.png", Vector2(92, 58), Vector2(176, 68), "Logo", TextureRect.STRETCH_KEEP_ASPECT_CENTERED)

	var player_name := str(save_data.get("player_name", "Player"))
	UI.add_label(self, _text("hello") % player_name, Vector2(20, 128), Vector2(320, 28), 18, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Greeting")
	_add_summary_panel(player_name)
	_add_main_buttons()


func _add_summary_panel(player_name: String) -> void:
	var panel := Panel.new()
	panel.name = "PlayerSummary"
	panel.position = Vector2(24, 164)
	panel.size = Vector2(312, 132)
	add_child(panel)
	UI.style_panel_button(panel, Color(0.88, 0.94, 0.98), Color(0.40, 0.58, 0.72), 2)

	var money := int(save_data.get("money", 3000))
	var starter := str(save_data.get("starter_name", "Charmander"))
	var badges := int(save_data.get("badges", 0))
	var summary := "%s: %s\n%s: $%d\n%s: %s\n%s: %s" % [
		_text("player"),
		player_name,
		_text("money"),
		money,
		_text("starter"),
		starter,
		_text("progress"),
		_text("badges") % badges,
	]
	UI.add_panel_label(panel, summary, Vector2(18, 14), Vector2(276, 104), 16, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "SummaryText")


func _add_main_buttons() -> void:
	UI.add_orange_button(self, _text("explore_world"), Vector2(55, 318), Vector2(250, 52), Callable(self, "_show_world_map"), "ExploreWorld")
	UI.add_orange_button(self, _text("my_pokemon"), Vector2(55, 376), Vector2(250, 52), Callable(self, "_show_my_pokemon"), "MyPokemon")
	UI.add_orange_button(self, _text("bag"), Vector2(55, 434), Vector2(250, 52), Callable(self, "_show_bag"), "Bag")
	UI.add_orange_button(self, _text("pokedex"), Vector2(55, 492), Vector2(250, 52), Callable(self, "_show_pokedex"), "PokeDex")
	UI.add_orange_button(self, _text("options"), Vector2(28, 558), Vector2(140, 44), Callable(self, "_show_options"), "Options")
	UI.add_orange_button(self, _text("exit"), Vector2(192, 558), Vector2(140, 44), Callable(self, "_confirm_exit"), "Exit")


func _show_world_map() -> void:
	if world_popup != null and is_instance_valid(world_popup):
		world_popup.queue_free()

	world_popup = Control.new()
	world_popup.name = "WorldMapPopup"
	world_popup.position = Vector2.ZERO
	world_popup.size = UI.SCREEN_SIZE
	world_popup.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(world_popup)

	var shade := ColorRect.new()
	shade.name = "Shade"
	shade.position = Vector2.ZERO
	shade.size = UI.SCREEN_SIZE
	shade.color = Color(0, 0, 0, 0.42)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	world_popup.add_child(shade)

	UI.add_texture(world_popup, UI.POPUP_PANEL, Vector2(15, 34), Vector2(330, 580), "Panel", TextureRect.STRETCH_SCALE)
	UI.add_panel_label(world_popup, _text("world_map"), Vector2(60, 60), Vector2(240, 34), 23, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Title")
	var close := UI.add_icon_button(world_popup, "res://assets/icons/icon_close_32.png", Vector2(298, 56), Callable(), "Close")
	close.pressed.connect(func():
		world_popup.queue_free()
	)

	var scroll := ScrollContainer.new()
	scroll.name = "WorldMapScroll"
	scroll.position = Vector2(28, 104)
	scroll.size = Vector2(304, 468)
	world_popup.add_child(scroll)

	var content := Control.new()
	content.name = "WorldMapContent"
	content.custom_minimum_size = Vector2(304, 12 * 76)
	scroll.add_child(content)

	for i in range(WORLD_MAPS.size()):
		_add_world_map_row(content, WORLD_MAPS[i], i)


func _add_world_map_row(parent: Control, map_data: Dictionary, index: int) -> void:
	var button := Button.new()
	button.name = "Map%s" % str(map_data["key"]).capitalize()
	button.position = Vector2(0, float(index) * 76.0)
	button.size = Vector2(296, 66)
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_color_override("font_color", UI.PANEL_TEXT)
	button.add_theme_color_override("font_hover_color", UI.PANEL_TEXT)
	button.add_theme_color_override("font_pressed_color", UI.PANEL_TEXT)
	UI.style_panel_button(button, Color(0.86, 0.92, 0.96), Color(0.34, 0.50, 0.62), 2)
	parent.add_child(button)

	var icon_path := str(map_data.get("icon", ""))
	if icon_path != "" and FileAccess.file_exists(icon_path):
		UI.add_texture(button, icon_path, Vector2(10, 7), Vector2(52, 52), "Icon", TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	else:
		var placeholder := ColorRect.new()
		placeholder.name = "MapPlaceholder"
		placeholder.position = Vector2(12, 9)
		placeholder.size = Vector2(48, 48)
		placeholder.color = Color(0.36, 0.50, 0.62)
		placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(placeholder)
		UI.add_panel_label(button, "?", Vector2(12, 12), Vector2(48, 42), 22, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Question")

	var status := _text("available") if bool(map_data.get("available", false)) else _text("coming_soon")
	var description := "%s\n%s: %s\n%s" % [
		_text(str(map_data["key"])),
		_text("type"),
		str(map_data["type"]),
		status,
	]
	UI.add_panel_label(button, description, Vector2(72, 7), Vector2(210, 52), 14, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "MapText")

	if bool(map_data.get("available", false)):
		button.pressed.connect(Callable(self, "_open_forest_map"))
	else:
		button.pressed.connect(Callable(self, "_show_map_soon"))


func _open_forest_map() -> void:
	get_tree().change_scene_to_file("res://scenes/ForestMap.tscn")


func _show_map_soon() -> void:
	UI.show_message_popup(self, _text("world_map"), _text("map_soon"))


func _show_my_pokemon() -> void:
	UI.show_message_popup(self, _text("my_pokemon"), _text("my_pokemon_soon"))


func _show_bag() -> void:
	UI.show_message_popup(self, _text("bag"), _text("bag_soon"))


func _show_pokedex() -> void:
	UI.show_message_popup(self, _text("pokedex"), _text("pokedex_soon"))


func _show_options() -> void:
	UI.show_options_popup(self, _text("options"), _options_labels(), Callable(self, "_on_options_applied"))


func _on_options_applied(new_settings: Dictionary) -> void:
	settings = new_settings
	call_deferred("_rebuild_screen")


func _rebuild_screen() -> void:
	for child in get_children():
		child.queue_free()
	_build_screen()


func _confirm_exit() -> void:
	var on_yes = func():
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	UI.show_confirm_popup(self, _text("exit"), _text("return_menu"), _text("yes"), _text("no"), on_yes)


func _options_labels() -> Dictionary:
	return {
		"music": _text("music"),
		"sfx": _text("sfx"),
		"language": _text("language"),
		"apply": _text("apply"),
		"cancel": _text("cancel"),
	}


func _text(key: String) -> String:
	var language := str(settings.get("language", "en"))
	if not TEXT.has(language):
		language = "en"
	var language_text: Dictionary = TEXT[language]
	var english_text: Dictionary = TEXT["en"]
	return str(language_text.get(key, english_text.get(key, key)))
