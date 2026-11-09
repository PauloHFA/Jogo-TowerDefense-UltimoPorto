extends RefCounted

signal dismissed

const Campaign = preload("res://scripts/campaign_data.gd")
const Localization = preload("res://scripts/localization.gd")
const COLOR_PANEL := Color("#1b2b32")
const COLOR_EDGE := Color("#40545b")
const COLOR_TEXT := Color("#f2e7ca")
const COLOR_MUTED := Color("#a8b6b5")


func show(parent: Control, collected: Array[int], english: bool, large_text: bool) -> Control:
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
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 13)
	panel.add_child(box)
	var title := (
		("Ship's Journals · %d/12" if english else "Diários de Bordo · %d/12") % collected.size()
	)
	box.add_child(_label(title, 24, large_text))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(scroll)
	var journal_list := VBoxContainer.new()
	journal_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(journal_list)
	for diary in Campaign.DIARIES:
		var diary_id := int(diary["id"])
		var found := collected.has(diary_id)
		var diary_title := Localization.diary_title(diary_id, english, String(diary["title"]))
		var status := (
			("found" if found else "mission %02d · finish without damage" % int(diary["mission"]))
			if english
			else (
				"encontrado" if found else "missão %02d · conclua sem dano" % int(diary["mission"])
			)
		)
		if not found:
			diary_title = "Page not yet found" if english else "Página ainda não encontrada"
		journal_list.add_child(
			_label("%02d · %s — %s" % [diary_id, diary_title, status], 15, large_text)
		)
	var close_button := Button.new()
	close_button.text = "Back" if english else "Voltar"
	close_button.pressed.connect(func() -> void: dismissed.emit())
	box.add_child(close_button)
	parent.add_child(overlay)
	return overlay


func _label(text: String, font_size: int, large_text: bool) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size + (3 if large_text else 0))
	label.add_theme_color_override("font_color", COLOR_MUTED if text.is_empty() else COLOR_TEXT)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label
