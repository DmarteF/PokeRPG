extends Control

const UI = preload("res://scripts/ui_factory.gd")

const TEXT = {
	"en": {
		"load_game": "Load Game",
		"new_game": "New Game",
		"options": "Options",
		"about": "About",
		"about_message": "PokeRPG private remake",
		"apply": "Apply",
		"cancel": "Cancel",
		"music": "Music",
		"sfx": "Sound Effects",
		"language": "Language",
		"player_name": "Player name",
		"choose_avatar": "Choose your avatar",
		"start_game": "Start Game",
		"empty_slot": "Empty Slot",
		"empty_save_slot": "Empty save slot.",
		"delete_save": "Delete Save",
		"delete": "Delete",
		"delete_confirm": "Delete this save?",
		"slot": "Slot",
		"level": "Level",
		"money": "Money",
		"avatar": "Avatar",
	},
	"pt": {
		"load_game": "Carregar Jogo",
		"new_game": "Novo Jogo",
		"options": "Opções",
		"about": "Sobre",
		"about_message": "PokeRPG private remake",
		"apply": "Aplicar",
		"cancel": "Cancelar",
		"music": "Música",
		"sfx": "Efeitos Sonoros",
		"language": "Idioma",
		"player_name": "Nome do jogador",
		"choose_avatar": "Escolha seu avatar",
		"start_game": "Iniciar Jogo",
		"empty_slot": "Slot Vazio",
		"empty_save_slot": "Slot de save vazio.",
		"delete_save": "Apagar Save",
		"delete": "Apagar",
		"delete_confirm": "Apagar este save?",
		"slot": "Slot",
		"level": "Level",
		"money": "Money",
		"avatar": "Avatar",
	},
}

const PANEL_TEXT = Color(0.05, 0.12, 0.20)

var settings: Dictionary = {}
var menu_labels := {}
var selected_avatar_id := 1
var avatar_buttons: Array = []
var load_popup: Control


func _ready() -> void:
	UI.setup_screen(self)
	settings = SaveManager.load_settings()
	_build_main_menu()
	_update_menu_texts()


func _build_main_menu() -> void:
	UI.add_background(self)
	UI.add_texture(self, "res://assets/ui/logo_pokerpg_512x200.png", Vector2(36, 70), Vector2(288, 112), "Logo", TextureRect.STRETCH_KEEP_ASPECT_CENTERED)

	_add_menu_button("load_game", Vector2(70, 250), Callable(self, "_show_load_game"))
	_add_menu_button("new_game", Vector2(70, 310), Callable(self, "_show_new_game"))
	_add_menu_button("options", Vector2(70, 370), Callable(self, "_show_options"))
	_add_menu_button("about", Vector2(70, 430), Callable(self, "_show_about"))

	UI.add_label(self, "Private remake prototype", Vector2(20, 594), Vector2(320, 24), 13, Color(0.86, 0.9, 0.94), HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Footer")


func _add_menu_button(key: String, pos: Vector2, callback: Callable) -> void:
	var button := UI.add_orange_button(self, "", pos, Vector2(220, 48), callback, key.capitalize().replace(" ", ""))
	menu_labels[key] = button.get_node("Text")


func _update_menu_texts() -> void:
	for key in ["load_game", "new_game", "options", "about"]:
		if menu_labels.has(key):
			menu_labels[key].text = _text(key)


func _show_load_game() -> void:
	if load_popup != null and is_instance_valid(load_popup):
		load_popup.queue_free()

	load_popup = _create_popup(_text("load_game"), 60.0, 520.0)

	for slot in range(1, SaveManager.MAX_SAVE_SLOTS + 1):
		_add_save_slot(load_popup, slot, 134.0 + float(slot - 1) * 104.0)

	var cancel_load_callback = func():
		load_popup.queue_free()
	UI.add_orange_button(load_popup, _text("cancel"), Vector2(70, 522), Vector2(220, 48), cancel_load_callback, "CancelLoad")


func _add_save_slot(parent: Control, slot: int, y: float) -> void:
	var save_data := SaveManager.get_save(slot)
	var slot_button := Button.new()
	slot_button.name = "SaveSlot%d" % slot
	slot_button.position = Vector2(28, y)
	slot_button.size = Vector2(232, 82)
	slot_button.focus_mode = Control.FOCUS_NONE
	slot_button.add_theme_font_size_override("font_size", 13)
	slot_button.add_theme_color_override("font_color", PANEL_TEXT)
	slot_button.add_theme_color_override("font_hover_color", PANEL_TEXT)
	slot_button.add_theme_color_override("font_pressed_color", PANEL_TEXT)
	_style_button(slot_button, Color(0.86, 0.92, 0.96), Color(0.34, 0.50, 0.62), 2)
	parent.add_child(slot_button)

	if save_data.is_empty():
		slot_button.text = "%s %d\n%s" % [_text("slot"), slot, _text("empty_slot")]
		slot_button.pressed.connect(Callable(self, "_show_empty_save_slot_message"))
		return

	slot_button.text = "%s %d - %s %d\n%s\n%s %d | %s %d" % [
		_text("slot"),
		slot,
		_text("avatar"),
		int(save_data.get("avatar_id", 1)),
		str(save_data.get("player_name", "Player")),
		_text("level"),
		int(save_data.get("level", 0)),
		_text("money"),
		int(save_data.get("money", 0)),
	]
	slot_button.pressed.connect(Callable(self, "_load_save").bind(slot))

	var delete_button := Button.new()
	delete_button.name = "DeleteSave%d" % slot
	delete_button.text = _text("delete")
	delete_button.position = Vector2(268, y + 22)
	delete_button.size = Vector2(64, 38)
	delete_button.focus_mode = Control.FOCUS_NONE
	delete_button.add_theme_font_size_override("font_size", 12)
	delete_button.add_theme_color_override("font_color", Color.WHITE)
	_style_button(delete_button, Color(0.74, 0.18, 0.16), Color(0.44, 0.08, 0.08), 2)
	parent.add_child(delete_button)
	delete_button.pressed.connect(Callable(self, "_confirm_delete_save").bind(slot))


func _load_save(slot: int) -> void:
	var save_data := SaveManager.load_save(slot)
	if save_data.is_empty():
		UI.show_message_popup(self, _text("load_game"), _text("empty_save_slot"))
		return

	GameState.apply_save(save_data)
	get_tree().change_scene_to_file("res://HomeScreen.tscn")


func _confirm_delete_save(slot: int) -> void:
	var save_data := SaveManager.get_save(slot)
	if save_data.is_empty():
		UI.show_message_popup(self, _text("delete_save"), _text("empty_save_slot"))
		return

	var confirm := _create_popup(_text("delete_save"), 140.0, 300.0)
	UI.add_panel_label(confirm, "%s\n%s" % [_text("delete_confirm"), str(save_data.get("player_name", "Player"))], Vector2(42, 230), Vector2(276, 74), 17, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "ConfirmText")
	var confirm_delete_callback = func():
		SaveManager.delete_save(slot)
		confirm.queue_free()
		if load_popup != null and is_instance_valid(load_popup):
			load_popup.queue_free()
		call_deferred("_show_load_game")
	UI.add_orange_button(confirm, _text("delete"), Vector2(38, 350), Vector2(140, 44), confirm_delete_callback, "ConfirmDelete")

	var cancel_delete_callback = func():
		confirm.queue_free()
	UI.add_orange_button(confirm, _text("cancel"), Vector2(182, 350), Vector2(140, 44), cancel_delete_callback, "CancelDelete")


func _show_new_game() -> void:
	selected_avatar_id = 1
	avatar_buttons.clear()

	var popup := _create_popup(_text("new_game"), 60.0, 520.0)
	UI.add_panel_label(popup, _text("player_name"), Vector2(42, 136), Vector2(276, 24), 15, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "NameLabel")

	var name_edit := LineEdit.new()
	name_edit.name = "PlayerName"
	name_edit.position = Vector2(42, 164)
	name_edit.size = Vector2(276, 40)
	name_edit.text = "KaiPlayz"
	name_edit.placeholder_text = "KaiPlayz"
	name_edit.add_theme_font_size_override("font_size", 16)
	name_edit.add_theme_color_override("font_color", PANEL_TEXT)
	popup.add_child(name_edit)

	UI.add_panel_label(popup, _text("choose_avatar"), Vector2(42, 224), Vector2(276, 28), 17, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "AvatarLabel")

	for avatar_id in range(1, 4):
		var button := Button.new()
		button.name = "Avatar%d" % avatar_id
		button.text = "%s %d" % [_text("avatar"), avatar_id]
		button.position = Vector2(38 + float(avatar_id - 1) * 96.0, 266)
		button.size = Vector2(88, 74)
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_size_override("font_size", 14)
		button.add_theme_color_override("font_color", PANEL_TEXT)
		button.add_theme_color_override("font_hover_color", PANEL_TEXT)
		button.add_theme_color_override("font_pressed_color", PANEL_TEXT)
		popup.add_child(button)
		avatar_buttons.append(button)
		button.pressed.connect(Callable(self, "_select_avatar").bind(avatar_id))

	_update_avatar_buttons()

	var start_game_callback = func():
		var player_name := name_edit.text.strip_edges()
		if player_name == "":
			player_name = "Player"
		var slot := _find_new_save_slot()
		var save_data := SaveManager.create_save(slot, player_name, selected_avatar_id)
		GameState.apply_save(save_data)
		get_tree().change_scene_to_file("res://HomeScreen.tscn")
	UI.add_orange_button(popup, _text("start_game"), Vector2(55, 404), Vector2(250, 52), start_game_callback, "StartGame")

	var cancel_new_game_callback = func():
		popup.queue_free()
	UI.add_orange_button(popup, _text("cancel"), Vector2(70, 472), Vector2(220, 48), cancel_new_game_callback, "CancelNewGame")


func _select_avatar(avatar_id: int) -> void:
	selected_avatar_id = avatar_id
	_update_avatar_buttons()


func _update_avatar_buttons() -> void:
	for i in range(avatar_buttons.size()):
		var button: Button = avatar_buttons[i]
		var is_selected := i + 1 == selected_avatar_id
		var fill := Color(0.95, 0.78, 0.32) if is_selected else Color(0.82, 0.88, 0.94)
		var border := Color(0.92, 0.46, 0.08) if is_selected else Color(0.36, 0.50, 0.62)
		_style_button(button, fill, border, 3 if is_selected else 2)


func _find_new_save_slot() -> int:
	for slot in range(1, SaveManager.MAX_SAVE_SLOTS + 1):
		if not SaveManager.has_save(slot):
			return slot
	return 1


func _show_options() -> void:
	var popup := _create_popup(_text("options"), 92.0, 420.0)

	var music_check := CheckBox.new()
	music_check.name = "MusicCheck"
	music_check.text = _text("music")
	music_check.position = Vector2(46, 164)
	music_check.size = Vector2(268, 40)
	music_check.button_pressed = bool(settings.get("music_enabled", true))
	_style_check(music_check)
	popup.add_child(music_check)

	var sfx_check := CheckBox.new()
	sfx_check.name = "SfxCheck"
	sfx_check.text = _text("sfx")
	sfx_check.position = Vector2(46, 214)
	sfx_check.size = Vector2(268, 40)
	sfx_check.button_pressed = bool(settings.get("sfx_enabled", true))
	_style_check(sfx_check)
	popup.add_child(sfx_check)

	UI.add_panel_label(popup, _text("language"), Vector2(46, 276), Vector2(120, 30), 16, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_CENTER, "LanguageLabel")

	var language_option := OptionButton.new()
	language_option.name = "LanguageOption"
	language_option.position = Vector2(166, 274)
	language_option.size = Vector2(148, 36)
	language_option.add_item("English", 0)
	language_option.add_item("Português", 1)
	language_option.select(1 if str(settings.get("language", "en")) == "pt" else 0)
	language_option.add_theme_font_size_override("font_size", 15)
	language_option.add_theme_color_override("font_color", PANEL_TEXT)
	popup.add_child(language_option)

	var apply_options_callback = func():
		var language := "pt" if language_option.selected == 1 else "en"
		SaveManager.save_settings({
			"music_enabled": music_check.button_pressed,
			"sfx_enabled": sfx_check.button_pressed,
			"language": language,
		})
		settings = SaveManager.get_settings()
		_update_menu_texts()
		popup.queue_free()
	UI.add_orange_button(popup, _text("apply"), Vector2(38, 398), Vector2(140, 44), apply_options_callback, "ApplyOptions")

	var cancel_options_callback = func():
		popup.queue_free()
	UI.add_orange_button(popup, _text("cancel"), Vector2(182, 398), Vector2(140, 44), cancel_options_callback, "CancelOptions")


func _show_about() -> void:
	UI.show_message_popup(self, _text("about"), _text("about_message"))


func _create_popup(title: String, panel_y: float, panel_height: float) -> Control:
	var overlay := Control.new()
	overlay.name = "Popup"
	overlay.position = Vector2.ZERO
	overlay.size = UI.SCREEN_SIZE
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var shade := ColorRect.new()
	shade.name = "Shade"
	shade.position = Vector2.ZERO
	shade.size = UI.SCREEN_SIZE
	shade.color = Color(0, 0, 0, 0.44)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(shade)

	var panel := UI.add_texture(overlay, UI.POPUP_PANEL, Vector2(15, panel_y), Vector2(330, panel_height), "Panel", TextureRect.STRETCH_SCALE)
	UI.add_panel_label(overlay, title, Vector2(50, panel_y + 26.0), Vector2(260, 34), 23, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "PopupTitle")

	var close := UI.add_icon_button(overlay, "res://assets/icons/icon_close_32.png", Vector2(298, panel_y + 20.0), Callable(), "Close")
	close.pressed.connect(func():
		overlay.queue_free()
	)

	_animate_popup(overlay, panel)
	return overlay


func _animate_popup(overlay: Control, panel: Control) -> void:
	overlay.modulate.a = 0.0
	panel.pivot_offset = panel.size * 0.5
	panel.scale = Vector2(0.96, 0.96)
	var tween := create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, 0.12)
	tween.parallel().tween_property(panel, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _style_check(check_box: CheckBox) -> void:
	check_box.focus_mode = Control.FOCUS_NONE
	check_box.add_theme_font_size_override("font_size", 16)
	check_box.add_theme_color_override("font_color", PANEL_TEXT)
	check_box.add_theme_color_override("font_hover_color", PANEL_TEXT)
	check_box.add_theme_color_override("font_pressed_color", PANEL_TEXT)


func _style_button(button: Button, fill: Color, border: Color, border_width: int) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = fill
	normal.border_color = border
	normal.set_border_width_all(border_width)
	normal.set_corner_radius_all(6)

	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = fill.lightened(0.05)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = fill.darkened(0.07)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", normal)


func _text(key: String) -> String:
	var language := str(settings.get("language", "en"))
	if not TEXT.has(language):
		language = "en"
	var language_text: Dictionary = TEXT[language]
	var english_text: Dictionary = TEXT["en"]
	return str(language_text.get(key, english_text.get(key, key)))


func _show_empty_save_slot_message() -> void:
	UI.show_message_popup(self, _text("load_game"), _text("empty_save_slot"))
