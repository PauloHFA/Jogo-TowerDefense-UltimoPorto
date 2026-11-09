extends RefCounted

const COLOR_PANEL := Color("#1b2b32")
const COLOR_EDGE := Color("#40545b")
const COLOR_TEXT := Color("#f2e7ca")
const COLOR_MUTED := Color("#a8b6b5")


func show(
	parent: Control, title: String, body: String, actions: Array[Dictionary], large_text: bool
) -> Control:
	var overlay := Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.02, 0.05, 0.07, 0.86)
	overlay.add_child(shade)
	var panel := PanelContainer.new()
	panel.position = Vector2(128.0, 95.0)
	panel.size = Vector2(744.0, 530.0)
	panel.custom_minimum_size = panel.size
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_PANEL
	style.border_color = COLOR_EDGE
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", style)
	overlay.add_child(panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 13)
	margin.add_child(box)
	box.add_child(_label(title, 24, COLOR_TEXT, large_text))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)
	var label := _label(body, 16, COLOR_MUTED, large_text)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.custom_minimum_size = Vector2(660.0, 0.0)
	scroll.add_child(label)
	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 9)
	box.add_child(action_row)
	for action in actions:
		var button := Button.new()
		button.text = String(action["text"])
		button.custom_minimum_size = Vector2(168.0, 40.0)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 13 + (3 if large_text else 0))
		button.disabled = bool(action.get("disabled", false))
		button.pressed.connect(action["action"])
		action_row.add_child(button)
	parent.add_child(overlay)
	return overlay


func _label(text: String, font_size: int, color: Color, large_text: bool) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size + (3 if large_text else 0))
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label
