extends RefCounted

signal preference_changed(name: String, value: Variant)
signal dismissed

const COLOR_PANEL := Color("#1b2b32")
const COLOR_EDGE := Color("#40545b")
const COLOR_TEXT := Color("#f2e7ca")


func show(parent: Control, settings: Dictionary, english: bool, large_text: bool) -> Control:
	var overlay := Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.02, 0.05, 0.07, 0.86)
	overlay.add_child(shade)
	var panel := PanelContainer.new()
	panel.position = Vector2(210.0, 115.0)
	panel.size = Vector2(580.0, 490.0)
	panel.custom_minimum_size = panel.size
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_PANEL
	style.border_color = COLOR_EDGE
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", style)
	overlay.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	panel.add_child(box)
	box.add_child(
		_label(_text(english, "Acessibilidade e áudio", "Accessibility and audio"), 24, large_text)
	)

	var language_row := HBoxContainer.new()
	language_row.add_child(_label(_text(english, "Idioma", "Language"), 16, large_text))
	var language_picker := OptionButton.new()
	language_picker.add_item("Português (Brasil)")
	language_picker.add_item("English")
	language_picker.select(1 if english else 0)
	language_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	language_picker.item_selected.connect(
		func(index: int) -> void: preference_changed.emit("english", index == 1)
	)
	language_row.add_child(language_picker)
	box.add_child(language_row)

	_add_toggle(
		box,
		_text(english, "Reduzir movimento e tremor de tela", "Reduce motion and screen shake"),
		"reduced_motion",
		settings,
		large_text
	)
	_add_toggle(
		box,
		_text(english, "Alto contraste", "High contrast"),
		"high_contrast",
		settings,
		large_text
	)
	_add_toggle(
		box, _text(english, "Texto ampliado", "Larger text"), "large_text", settings, large_text
	)
	_add_toggle(
		box,
		_text(english, "Efeitos sonoros", "Sound effects"),
		"sound_enabled",
		settings,
		large_text
	)

	var volume_row := HBoxContainer.new()
	volume_row.add_child(
		_label(_text(english, "Volume dos efeitos", "Effects volume"), 15, large_text)
	)
	var volume_slider := HSlider.new()
	volume_slider.min_value = 0.0
	volume_slider.max_value = 1.0
	volume_slider.step = 0.05
	volume_slider.value = float(settings.get("sound_volume", 0.65))
	volume_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	volume_slider.value_changed.connect(
		func(value: float) -> void: preference_changed.emit("sound_volume", value)
	)
	volume_row.add_child(volume_slider)
	box.add_child(volume_row)

	var close_button := Button.new()
	close_button.text = _text(english, "Voltar", "Back")
	close_button.pressed.connect(func() -> void: dismissed.emit())
	box.add_child(close_button)
	parent.add_child(overlay)
	return overlay


func _add_toggle(
	parent: VBoxContainer, title: String, key: String, settings: Dictionary, large_text: bool
) -> void:
	var toggle := CheckButton.new()
	toggle.text = title
	toggle.button_pressed = bool(settings.get(key, false))
	toggle.add_theme_font_size_override("font_size", 13 + (3 if large_text else 0))
	toggle.toggled.connect(func(value: bool) -> void: preference_changed.emit(key, value))
	parent.add_child(toggle)


func _label(text: String, font_size: int, large_text: bool) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size + (3 if large_text else 0))
	label.add_theme_color_override("font_color", COLOR_TEXT)
	return label


func _text(english: bool, portuguese: String, translated: String) -> String:
	return translated if english else portuguese
