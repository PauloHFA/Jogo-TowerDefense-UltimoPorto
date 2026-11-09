extends RefCounted

signal solved
signal continue_requested

const COLOR_PANEL := Color("#1b2b32")
const COLOR_EDGE := Color("#40545b")
const COLOR_TEXT := Color("#f2e7ca")
const COLOR_MUTED := Color("#a8b6b5")


func show(parent: Control, english: bool, large_text: bool) -> Control:
	var overlay := Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.02, 0.05, 0.07, 0.86)
	overlay.add_child(shade)
	var panel := PanelContainer.new()
	panel.position = Vector2(185.0, 150.0)
	panel.size = Vector2(630.0, 420.0)
	panel.custom_minimum_size = panel.size
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_PANEL
	style.border_color = COLOR_EDGE
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", style)
	overlay.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)
	box.add_child(
		_label(
			_text(english, "Espelhos · alinhamento dos prismas", "Mirrors · align the prisms"),
			23,
			large_text
		)
	)
	box.add_child(
		_label(
			_text(
				english,
				"Ramiro deixou três espelhos fora de ordem. Alinhe as luzes: Âmbar → Azul → Verde.",
				"Ramiro left three mirrors out of order. Align the lights: Amber → Blue → Green."
			),
			16,
			large_text
		)
	)
	var selectors: Array[OptionButton] = []
	var colors := ["Amber", "Blue", "Green"] if english else ["Âmbar", "Azul", "Verde"]
	for index in range(3):
		var selector := OptionButton.new()
		for color in colors:
			selector.add_item(color)
		selector.select((index + 1) % 3)
		box.add_child(selector)
		selectors.append(selector)
	var result_label := _label("", 15, large_text)
	box.add_child(result_label)
	var check_button := Button.new()
	check_button.text = _text(english, "Alinhar espelhos", "Align mirrors")
	check_button.pressed.connect(
		func() -> void:
			if check_button.text == _text(english, "Continuar", "Continue"):
				continue_requested.emit()
				return
			var correct_order := (
				["Amber", "Blue", "Green"] if english else ["Âmbar", "Azul", "Verde"]
			)
			var is_solved := true
			for index in range(selectors.size()):
				is_solved = (
					is_solved
					and (
						selectors[index].get_item_text(selectors[index].selected)
						== correct_order[index]
					)
				)
			if is_solved:
				solved.emit()
				result_label.text = _text(
					english,
					"Prismas alinhados! Receberá 50 madeiras de bônus.",
					"Prisms aligned! You will receive 50 bonus wood."
				)
				check_button.text = _text(english, "Continuar", "Continue")
			else:
				result_label.text = _text(
					english,
					"Ainda não: observe a sequência de luzes.",
					"Not yet: watch the sequence of lights."
				)
	)
	box.add_child(check_button)
	var skip_button := Button.new()
	skip_button.text = _text(english, "Continuar sem resolver", "Continue without solving")
	skip_button.pressed.connect(func() -> void: continue_requested.emit())
	box.add_child(skip_button)
	parent.add_child(overlay)
	return overlay


func _label(text: String, font_size: int, large_text: bool) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size + (3 if large_text else 0))
	label.add_theme_color_override("font_color", COLOR_MUTED if text.is_empty() else COLOR_TEXT)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


func _text(english: bool, portuguese: String, translated: String) -> String:
	return translated if english else portuguese
