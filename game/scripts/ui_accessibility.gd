extends RefCounted

const COLOR_PANEL := Color("#1b2b32")
const COLOR_PANEL_EDGE := Color("#40545b")


static func apply(control: Control, large_text: bool, high_contrast: bool) -> void:
	if (control is Label or control is Button) and control.has_meta("base_font_size"):
		control.add_theme_font_size_override(
			"font_size", int(control.get_meta("base_font_size")) + (3 if large_text else 0)
		)
	if control is Label:
		if not control.has_meta("base_font_color"):
			control.set_meta("base_font_color", control.get_theme_color("font_color"))
		control.add_theme_color_override(
			"font_color",
			Color.WHITE if high_contrast else Color(control.get_meta("base_font_color"))
		)
	elif control is Button:
		if high_contrast:
			control.add_theme_color_override("font_color", Color.WHITE)
			control.add_theme_color_override("font_hover_color", Color("#fff176"))
			control.add_theme_color_override("font_pressed_color", Color.WHITE)
			control.add_theme_color_override("font_disabled_color", Color("#b0b0b0"))
			for state in ["normal", "hover", "pressed", "disabled"]:
				var style := StyleBoxFlat.new()
				style.bg_color = Color("#111111")
				style.border_color = Color("#ffffff")
				style.set_border_width_all(2)
				style.set_corner_radius_all(3)
				control.add_theme_stylebox_override(state, style)
		else:
			for color_name in [
				"font_color",
				"font_hover_color",
				"font_pressed_color",
				"font_disabled_color",
			]:
				control.remove_theme_color_override(color_name)
			for state in ["normal", "hover", "pressed", "disabled"]:
				control.remove_theme_stylebox_override(state)
	if control is PanelContainer:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("#000000") if high_contrast else COLOR_PANEL
		style.border_color = Color("#ffffff") if high_contrast else COLOR_PANEL_EDGE
		style.set_border_width_all(2 if high_contrast else 1)
		style.set_corner_radius_all(8)
		control.add_theme_stylebox_override("panel", style)
	for child in control.get_children():
		if child is Control:
			apply(child, large_text, high_contrast)
