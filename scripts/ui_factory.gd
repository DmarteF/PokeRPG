extends RefCounted

const SCREEN_SIZE = Vector2(360, 640)
const BACKGROUND = "res://assets/backgrounds/gray_texture_360x640.png"
const TOPBAR = "res://assets/ui/topbar_360x44.png"
const POPUP_PANEL = "res://assets/ui/popup_panel_blue_330x520.png"
const LIST_SLOT = "res://assets/ui/list_slot_gray_320x54.png"

static func setup_screen(root: Control) -> void:
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.custom_minimum_size = SCREEN_SIZE
	root.size = SCREEN_SIZE


static func add_background(parent: Node) -> TextureRect:
	var bg := add_texture(parent, BACKGROUND, Vector2.ZERO, SCREEN_SIZE, "GrayBackground", TextureRect.STRETCH_SCALE)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return bg


static func add_topbar(parent: Node) -> TextureRect:
	return add_texture(parent, TOPBAR, Vector2.ZERO, Vector2(360, 44), "Topbar", TextureRect.STRETCH_SCALE)


static func add_texture(parent: Node, path: String, pos: Vector2, node_size: Vector2, node_name: String, stretch_mode: int) -> TextureRect:
	var texture_rect := TextureRect.new()
	texture_rect.name = node_name
	texture_rect.texture = load(path)
	texture_rect.position = pos
	texture_rect.size = node_size
	texture_rect.stretch_mode = stretch_mode
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(texture_rect)
	return texture_rect


static func add_label(parent: Node, text: String, pos: Vector2, node_size: Vector2, font_size: int, color: Color, align: int, valign: int, node_name: String) -> Label:
	var label := Label.new()
	label.name = node_name
	label.text = text
	label.position = pos
	label.size = node_size
	label.horizontal_alignment = align
	label.vertical_alignment = valign
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
	label.add_theme_constant_override("outline_size", 2)
	parent.add_child(label)
	return label


static func add_icon_button(parent: Node, icon_path: String, pos: Vector2, callback: Callable, node_name: String) -> TextureButton:
	var button := TextureButton.new()
	button.name = node_name
	button.texture_normal = load(icon_path)
	button.texture_pressed = load(icon_path)
	button.position = pos
	button.size = Vector2(32, 32)
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_SCALE
	button.focus_mode = Control.FOCUS_NONE
	parent.add_child(button)
	if callback.is_valid():
		button.pressed.connect(callback)
	return button


static func add_orange_button(parent: Node, text: String, pos: Vector2, node_size: Vector2, callback: Callable, node_name: String) -> TextureButton:
	var button := TextureButton.new()
	button.name = node_name
	button.texture_normal = load(_orange_normal_for_size(node_size))
	button.texture_pressed = load(_orange_pressed_for_size(node_size))
	button.position = pos
	button.size = node_size
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_SCALE
	button.focus_mode = Control.FOCUS_NONE
	parent.add_child(button)
	if callback.is_valid():
		button.pressed.connect(callback)

	var label := add_label(button, text, Vector2.ZERO, node_size, 17, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Text")
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return button


static func add_list_button(parent: Node, text: String, icon_path: String, pos: Vector2, callback: Callable, node_name: String) -> TextureButton:
	var button := TextureButton.new()
	button.name = node_name
	button.texture_normal = load(LIST_SLOT)
	button.texture_pressed = load(LIST_SLOT)
	button.position = pos
	button.size = Vector2(320, 54)
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_SCALE
	button.focus_mode = Control.FOCUS_NONE
	parent.add_child(button)
	if callback.is_valid():
		button.pressed.connect(callback)

	var label_x := 0.0
	var label_width := 320.0
	if icon_path != "":
		var icon := add_texture(button, icon_path, Vector2(12, 7), Vector2(40, 40), "Icon", TextureRect.STRETCH_KEEP_ASPECT_CENTERED)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label_x = 62.0
		label_width = 238.0

	var label := add_label(button, text, Vector2(label_x, 0), Vector2(label_width, 54), 17, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Text")
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return button


static func show_message_popup(parent: Node, title: String, message: String) -> Control:
	var overlay := Control.new()
	overlay.name = "MessagePopup"
	overlay.position = Vector2.ZERO
	overlay.size = SCREEN_SIZE
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	parent.add_child(overlay)

	var shade := ColorRect.new()
	shade.name = "Shade"
	shade.position = Vector2.ZERO
	shade.size = SCREEN_SIZE
	shade.color = Color(0, 0, 0, 0.45)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(shade)

	add_texture(overlay, POPUP_PANEL, Vector2(15, 110), Vector2(330, 360), "PopupPanel", TextureRect.STRETCH_SCALE)
	add_label(overlay, title, Vector2(44, 140), Vector2(272, 36), 22, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Title")
	add_label(overlay, message, Vector2(42, 205), Vector2(276, 110), 18, Color.WHITE, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER, "Message")

	var close := add_icon_button(overlay, "res://assets/icons/icon_close_32.png", Vector2(298, 128), Callable(), "Close")
	close.pressed.connect(func():
		overlay.queue_free()
	)

	var ok_callback = func():
		overlay.queue_free()
	add_orange_button(overlay, "OK", Vector2(70, 370), Vector2(220, 48), ok_callback, "OkButton")
	return overlay


static func _orange_normal_for_size(node_size: Vector2) -> String:
	if node_size.x <= 190.0:
		return "res://assets/ui/button_orange_180x40.png"
	if node_size.x >= 240.0:
		return "res://assets/ui/button_orange_250x52.png"
	return "res://assets/ui/button_orange_220x48.png"


static func _orange_pressed_for_size(node_size: Vector2) -> String:
	if node_size.x <= 190.0:
		return "res://assets/ui/button_orange_180x40_pressed.png"
	if node_size.x >= 240.0:
		return "res://assets/ui/button_orange_250x52_pressed.png"
	return "res://assets/ui/button_orange_220x48_pressed.png"
