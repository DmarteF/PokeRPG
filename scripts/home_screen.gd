extends Control

const UI = preload("res://scripts/ui_factory.gd")

var maps_popup: Control


func _ready() -> void:
	UI.setup_screen(self)
	UI.add_background(self)
	UI.add_topbar(self)
	_add_topbar_icons()

	UI.add_label(self, "Hello KaiPlayz,", Vector2(20, 64), Vector2(320, 28), 18, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Greeting")
	UI.add_label(self, "Welcome to", Vector2(20, 92), Vector2(320, 26), 17, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Welcome")
	UI.add_texture(self, "res://assets/ui/logo_pokerpg_512x200.png", Vector2(62, 120), Vector2(236, 92), "Logo", TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
	UI.add_label(self, "New here? See the tutorial:", Vector2(20, 238), Vector2(320, 26), 16, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "TutorialText")
	UI.add_orange_button(self, "Tutorial / Web Page", Vector2(55, 270), Vector2(250, 52), Callable(self, "_show_tutorial"), "TutorialButton")

	_add_region_cards()


func _add_topbar_icons() -> void:
	UI.add_icon_button(self, "res://assets/icons/icon_map_32.png", Vector2(20, 6), Callable(self, "_show_maps_popup"), "MapIcon")
	UI.add_icon_button(self, "res://assets/icons/icon_trophy_32.png", Vector2(88, 6), Callable(self, "_show_trophy"), "TrophyIcon")
	UI.add_icon_button(self, "res://assets/icons/icon_ball_32.png", Vector2(156, 6), Callable(self, "_show_pokemon"), "BallIcon")
	UI.add_icon_button(self, "res://assets/icons/icon_user_32.png", Vector2(224, 6), Callable(self, "_show_profile"), "UserIcon")
	UI.add_icon_button(self, "res://assets/icons/icon_gear_32.png", Vector2(292, 6), Callable(self, "_show_options"), "GearIcon")


func _add_region_cards() -> void:
	var regions := [
		["Gen. 1 / Kanto", Callable(self, "_show_maps_popup")],
		["Gen. 2 / Johto", Callable(self, "_show_region_soon")],
		["Gen. 3 / Hoenn", Callable(self, "_show_region_soon")],
		["Gen. 4 / Sinnoh", Callable(self, "_show_region_soon")],
		["Gen. 5 / Unova", Callable(self, "_show_region_soon")],
	]

	for i in range(regions.size()):
		var row = regions[i]
		UI.add_list_button(self, row[0], "", Vector2(20, 338 + (i * 56)), row[1], "Region%d" % i)


func _show_maps_popup() -> void:
	if maps_popup != null and is_instance_valid(maps_popup):
		maps_popup.queue_free()

	maps_popup = Control.new()
	maps_popup.name = "MapsPopup"
	maps_popup.position = Vector2.ZERO
	maps_popup.size = UI.SCREEN_SIZE
	maps_popup.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(maps_popup)

	var shade := ColorRect.new()
	shade.name = "Shade"
	shade.position = Vector2.ZERO
	shade.size = UI.SCREEN_SIZE
	shade.color = Color(0, 0, 0, 0.38)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	maps_popup.add_child(shade)

	UI.add_texture(maps_popup, "res://assets/ui/popup_panel_blue_330x520.png", Vector2(15, 60), Vector2(330, 520), "Panel", TextureRect.STRETCH_SCALE)
	UI.add_label(maps_popup, "Maps", Vector2(60, 86), Vector2(240, 34), 24, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Title")
	var close := UI.add_icon_button(maps_popup, "res://assets/icons/icon_close_32.png", Vector2(298, 80), Callable(), "Close")
	close.pressed.connect(func():
		maps_popup.queue_free()
	)

	var maps := [
		["Forest Map", "res://assets/maps/map_forest_64.png", Callable(self, "_open_forest_map")],
		["Fire Map", "res://assets/maps/map_fire_64.png", Callable(self, "_show_map_soon")],
		["Mansion Map", "res://assets/maps/map_mansion_64.png", Callable(self, "_show_map_soon")],
		["Factory Map", "res://assets/maps/map_factory_64.png", Callable(self, "_show_map_soon")],
		["Ice Map", "res://assets/maps/map_ice_64.png", Callable(self, "_show_map_soon")],
		["Cave Map", "res://assets/maps/map_cave_64.png", Callable(self, "_show_map_soon")],
	]

	for i in range(maps.size()):
		var row = maps[i]
		UI.add_list_button(maps_popup, row[0], row[1], Vector2(20, 138 + (i * 60)), row[2], "Map%d" % i)


func _open_forest_map() -> void:
	get_tree().change_scene_to_file("res://ForestMap.tscn")


func _show_map_soon() -> void:
	UI.show_message_popup(self, "Maps", "Coming soon")


func _show_region_soon() -> void:
	UI.show_message_popup(self, "Regions", "Coming soon")


func _show_tutorial() -> void:
	UI.show_message_popup(self, "Tutorial", "Tutorial / Web Page")


func _show_trophy() -> void:
	UI.show_message_popup(self, "Trophy", "Coming soon")


func _show_pokemon() -> void:
	UI.show_message_popup(self, "Pokemon", "Coming soon")


func _show_profile() -> void:
	UI.show_message_popup(self, "Profile", "Coming soon")


func _show_options() -> void:
	UI.show_message_popup(self, "Options", "Options coming soon")
