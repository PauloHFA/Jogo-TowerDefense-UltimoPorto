extends Node2D

const Campaign = preload("res://scripts/campaign_data.gd")
const MissionBoardScript = preload("res://scripts/mission_board.gd")
const Localization = preload("res://scripts/localization.gd")
const TowerPicker = preload("res://scripts/tower_picker.gd")
const SettingsPanelScript = preload("res://scripts/settings_panel.gd")
const CampaignSave = preload("res://scripts/campaign_save.gd")
const CampaignStory = preload("res://scripts/campaign_story.gd")
const PrismPuzzleScript = preload("res://scripts/prism_puzzle.gd")
const DiaryArchiveScript = preload("res://scripts/diary_archive.gd")
const ModalDialogScript = preload("res://scripts/modal_dialog.gd")
const NarrativeChoicesScript = preload("res://scripts/narrative_choices.gd")
const UiAccessibility = preload("res://scripts/ui_accessibility.gd")
const SAVE_PATH := "user://campaign_save.json"
const MISSION_COUNT := 25
const CITY_HEALTH_MAX := 10
const COLOR_PANEL := Color("#1b2b32")
const COLOR_PANEL_EDGE := Color("#40545b")
const COLOR_TEXT := Color("#f2e7ca")
const COLOR_MUTED := Color("#a8b6b5")
var board: MissionBoardScript
var phase := "campaign"
var current_mission := 1
var selected_mission := 1
var banked_wood := 100
var unlocked_mission := 1
var unlocked_chapter := 1
var completed_missions: Array[int] = []
var collected_diaries: Array[int] = []
var selected_tower_id := "balista"
var ending_choice := ""
var puzzle_solved := false
var message := ""
var message_time := 0.0
var ui_timer := 0.0
var save_error := ""
var english := false
var reduced_motion := false
var high_contrast := false
var large_text := false
var sound_enabled := true
var sound_volume := 0.65
var story_flags: Dictionary = {}
var settings_panel: Variant
var puzzle_panel: Variant
var diary_archive_panel: Variant
var narrative_choices: Variant

var ui_root: Control
var game_header: PanelContainer
var campaign_overlay: Control
var modal_overlay: Control
var mission_title_label: Label
var material_label: Label
var wood_label: Label
var health_label: Label
var wave_label: Label
var status_label: Label
var tower_picker: OptionButton
var build_button: Button
var upgrade_button: Button
var material_button: Button
var wave_button: Button
var pause_button: Button
var campaign_button: Button
var footer_panel: PanelContainer


func _ready() -> void:
	board = MissionBoardScript.new()
	add_child(board)
	board.message_requested.connect(_set_message)
	board.wave_cleared.connect(_on_wave_cleared)
	board.mission_won.connect(_on_board_mission_won)
	board.mission_lost.connect(_on_board_mission_lost)
	board.truce_requested.connect(_on_truce_requested)
	_load_save()
	_build_ui()
	_show_campaign_screen()


func _process(delta: float) -> void:
	message_time = maxf(0.0, message_time - delta)
	ui_timer += delta
	if ui_timer >= 0.14:
		ui_timer = 0.0
		_refresh_ui()


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	ui_root = Control.new()
	ui_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(ui_root)

	game_header = _make_panel(Rect2(24.0, 14.0, 952.0, 104.0))
	ui_root.add_child(game_header)
	var header_margin := MarginContainer.new()
	header_margin.add_theme_constant_override("margin_left", 14)
	header_margin.add_theme_constant_override("margin_top", 8)
	header_margin.add_theme_constant_override("margin_right", 14)
	header_margin.add_theme_constant_override("margin_bottom", 8)
	game_header.add_child(header_margin)
	var header_rows := VBoxContainer.new()
	header_rows.add_theme_constant_override("separation", 6)
	header_margin.add_child(header_rows)

	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 14)
	header_rows.add_child(title_row)
	mission_title_label = _make_label("", 19, COLOR_TEXT)
	mission_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(mission_title_label)
	material_label = _make_label("", 14, COLOR_MUTED)
	title_row.add_child(material_label)
	wood_label = _make_label("", 14, COLOR_TEXT)
	title_row.add_child(wood_label)
	health_label = _make_label("", 14, COLOR_TEXT)
	title_row.add_child(health_label)
	wave_label = _make_label("", 14, COLOR_TEXT)
	title_row.add_child(wave_label)

	var controls := HBoxContainer.new()
	controls.add_theme_constant_override("separation", 7)
	header_rows.add_child(controls)
	tower_picker = OptionButton.new()
	tower_picker.custom_minimum_size = Vector2(186.0, 30.0)
	tower_picker.item_selected.connect(
		func(index: int) -> void:
			if index >= 0 and index < tower_picker.item_count:
				selected_tower_id = String(tower_picker.get_item_metadata(index))
				board.select_tower(selected_tower_id)
	)
	controls.add_child(tower_picker)
	build_button = _make_button(_loc("Construir", "Build"))
	build_button.pressed.connect(
		func() -> void:
			board.toggle_build_mode()
			_refresh_ui()
	)
	controls.add_child(build_button)
	upgrade_button = _make_button(_loc("Melhorar", "Upgrade"))
	upgrade_button.pressed.connect(
		func() -> void:
			board.upgrade_selected_tower()
			_refresh_ui()
	)
	controls.add_child(upgrade_button)
	material_button = _make_button(_loc("Material", "Material"))
	material_button.pressed.connect(
		func() -> void:
			board.cycle_material()
			_refresh_ui()
	)
	controls.add_child(material_button)
	wave_button = _make_button(_loc("Iniciar onda", "Start wave"))
	wave_button.pressed.connect(
		func() -> void:
			board.start_next_wave()
			_refresh_ui()
	)
	controls.add_child(wave_button)
	pause_button = _make_button(_loc("Pausar", "Pause"))
	pause_button.custom_minimum_size = Vector2(76.0, 30.0)
	pause_button.pressed.connect(
		func() -> void:
			board.toggle_pause()
			_refresh_ui()
	)
	controls.add_child(pause_button)
	campaign_button = _make_button(_loc("Campanha", "Campaign"))
	campaign_button.pressed.connect(_show_campaign_screen)
	controls.add_child(campaign_button)

	footer_panel = _make_panel(Rect2(24.0, 654.0, 952.0, 48.0))
	ui_root.add_child(footer_panel)
	status_label = _make_label("", 14, COLOR_TEXT)
	status_label.position = Vector2(14.0, 10.0)
	status_label.size = Vector2(924.0, 28.0)
	footer_panel.add_child(status_label)


func _make_panel(rect: Rect2) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.position = rect.position
	panel.size = rect.size
	panel.custom_minimum_size = rect.size
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_PANEL
	style.border_color = COLOR_PANEL_EDGE
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", style)
	return panel


func _make_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.set_meta("base_font_size", font_size)
	label.set_meta("base_font_color", color)
	label.add_theme_font_size_override("font_size", font_size + (3 if large_text else 0))
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


func _make_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(122.0, 30.0)
	button.set_meta("base_font_size", 13)
	button.add_theme_font_size_override("font_size", 13 + (3 if large_text else 0))
	return button


func _show_campaign_screen() -> void:
	phase = "campaign"
	board.visible = false
	game_header.visible = false
	footer_panel.visible = false
	_clear_modal()
	_clear_campaign_overlay()

	campaign_overlay = Control.new()
	campaign_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_root.add_child(campaign_overlay)
	var panel := _make_panel(Rect2(34.0, 24.0, 932.0, 646.0))
	campaign_overlay.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 15)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 14)
	panel.add_child(margin)
	var content := HBoxContainer.new()
	content.add_theme_constant_override("separation", 20)
	margin.add_child(content)

	var left := VBoxContainer.new()
	left.custom_minimum_size = Vector2(335.0, 0.0)
	left.add_theme_constant_override("separation", 8)
	content.add_child(left)
	left.add_child(
		_make_label(
			_loc("ÚLTIMO PORTO: MARÉS DE FERRO", "LAST PORT: TIDES OF IRON"), 21, COLOR_TEXT
		)
	)
	left.add_child(
		_make_label(
			(
				_loc(
					"Campanha · %d/25 missões · %d/12 diários",
					"Campaign · %d/25 missions · %d/12 journals"
				)
				% [completed_missions.size(), collected_diaries.size()]
			),
			14,
			COLOR_MUTED
		)
	)
	var settings_button := _make_button(_loc("Configurações", "Settings"))
	settings_button.pressed.connect(_show_settings)
	left.add_child(settings_button)

	var mission_scroll := ScrollContainer.new()
	mission_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_child(mission_scroll)
	var mission_list := VBoxContainer.new()
	mission_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mission_list.add_theme_constant_override("separation", 4)
	mission_scroll.add_child(mission_list)
	for mission in Campaign.MISSIONS:
		var mission_id := int(mission["id"])
		var unlocked := mission_id <= unlocked_mission
		var completed := completed_missions.has(mission_id)
		var prefix := "✓ " if completed else "◆ " if unlocked else "🔒 "
		var button := Button.new()
		button.text = (
			prefix
			+ (
				"%02d · %s"
				% [
					mission_id,
					Localization.mission_title(mission_id, english, String(mission["title"]))
				]
			)
		)
		button.set_meta("base_font_size", 16)
		button.custom_minimum_size = Vector2(320.0, 34.0)
		button.disabled = not unlocked
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.pressed.connect(_on_mission_selected.bind(mission_id))
		mission_list.add_child(button)

	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 12)
	content.add_child(right)
	var mission: Dictionary = Campaign.mission_at(selected_mission - 1)
	var chapter := int(mission["chapter"])
	var chapter_name: String = Localization.chapter_title(
		chapter, english, Campaign.CHAPTER_NAMES[chapter - 1]
	)
	right.add_child(
		_make_label(
			_loc("CAPÍTULO %d · %s", "CHAPTER %d · %s") % [chapter, chapter_name.to_upper()],
			15,
			COLOR_MUTED
		)
	)
	(
		right
		. add_child(
			_make_label(
				(
					"%02d · %s"
					% [
						selected_mission,
						Localization.mission_title(
							selected_mission, english, String(mission["title"])
						),
					]
				),
				28,
				COLOR_TEXT
			)
		)
	)
	var site_names := [
		"",
		"Old Docks",
		"Occupied Quarry",
		"Shadow Shipyard",
		"Ash High Seas",
		"Heart of the Tide",
	]
	right.add_child(
		_make_label(
			(
				_loc("Cenário: %s", "Location: %s")
				% [site_names[chapter] if english else String(mission["site"])]
			),
			17,
			COLOR_TEXT
		)
	)
	right.add_child(
		_make_label(
			(
				_loc("Novidade: %s", "Feature: %s")
				% [
					Localization.mission_feature(
						selected_mission, english, String(mission["feature"])
					)
				]
			),
			15,
			COLOR_MUTED
		)
	)
	var diary: Dictionary = Campaign.diary_for_mission(selected_mission)
	if not diary.is_empty():
		var diary_id := int(diary["id"])
		var diary_status := (
			_loc("encontrado", "found")
			if collected_diaries.has(diary_id)
			else _loc(
				"objetivo: terminar sem perder vida do cais",
				"objective: finish without losing dock health"
			)
		)
		(
			right
			. add_child(
				_make_label(
					(
						"%s: %s (%s)"
						% [
							_loc("Diário opcional", "Optional journal"),
							Localization.diary_title(diary_id, english, String(diary["title"])),
							diary_status,
						]
					),
					14,
					COLOR_MUTED
				)
			)
		)
	else:
		right.add_child(
			_make_label(
				_loc(
					"Objetivo opcional: concluir sem sofrer dano para obter madeira extra.",
					"Optional objective: finish without damage to earn bonus wood."
				),
				14,
				COLOR_MUTED
			)
		)
	right.add_child(_make_label(_loc("História", "Story"), 15, COLOR_MUTED))
	var beat := _make_label(
		Localization.mission_beat(selected_mission, english, String(mission["beat"])),
		17,
		COLOR_TEXT
	)
	beat.custom_minimum_size = Vector2(0.0, 62.0)
	right.add_child(beat)
	var chapter_story := CampaignStory.chapter_story(chapter, english)
	right.add_child(_make_label(chapter_story, 14, COLOR_MUTED))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(spacer)

	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 8)
	right.add_child(action_row)
	var start_button := _make_button(_loc("Preparar missão", "Prepare mission"))
	start_button.custom_minimum_size = Vector2(180.0, 42.0)
	start_button.disabled = selected_mission > unlocked_mission
	start_button.pressed.connect(_on_prepare_mission)
	action_row.add_child(start_button)
	var diaries_button := _make_button(_loc("Livro de Plantas", "Book of Plans"))
	diaries_button.custom_minimum_size = Vector2(150.0, 42.0)
	diaries_button.pressed.connect(_show_diary_archive)
	action_row.add_child(diaries_button)

	if completed_missions.size() == MISSION_COUNT:
		var endless_button := _make_button(_loc("Maré Infinita", "Endless Tide"))
		endless_button.custom_minimum_size = Vector2(140.0, 42.0)
		endless_button.pressed.connect(_start_endless_mode)
		action_row.add_child(endless_button)
	if not save_error.is_empty():
		right.add_child(_make_label(save_error, 13, Color("#f1a18c")))
	UiAccessibility.apply(ui_root, large_text, high_contrast)


func _on_mission_selected(mission_id: int) -> void:
	selected_mission = mission_id
	_show_campaign_screen()


func _on_prepare_mission() -> void:
	if selected_mission == 24:
		_show_ending_choice()
	elif selected_mission == 22 and not puzzle_solved:
		_show_prism_puzzle()
	elif selected_mission == 21 and not story_flags.has("ramiro_trusted"):
		_show_ramiro_choice()
	else:
		_show_mission_briefing()


func _show_settings() -> void:
	_clear_modal()
	settings_panel = SettingsPanelScript.new()
	settings_panel.preference_changed.connect(_on_setting_changed)
	settings_panel.dismissed.connect(_show_campaign_screen)
	modal_overlay = (
		settings_panel
		. show(
			ui_root,
			{
				"reduced_motion": reduced_motion,
				"high_contrast": high_contrast,
				"large_text": large_text,
				"sound_enabled": sound_enabled,
				"sound_volume": sound_volume,
			},
			english,
			large_text
		)
	)
	UiAccessibility.apply(ui_root, large_text, high_contrast)


func _on_setting_changed(setting: String, value: Variant) -> void:
	match setting:
		"english":
			english = bool(value)
			_save_game()
			_show_campaign_screen()
			return
		"reduced_motion":
			reduced_motion = bool(value)
			board.reduced_motion = reduced_motion
		"high_contrast":
			high_contrast = bool(value)
			board.high_contrast = high_contrast
			board.queue_redraw()
			UiAccessibility.apply(ui_root, large_text, high_contrast)
		"large_text":
			large_text = bool(value)
			_save_game()
			_show_campaign_screen()
			return
		"sound_enabled":
			sound_enabled = bool(value)
			board.sound_enabled = sound_enabled
		"sound_volume":
			sound_volume = clampf(float(value), 0.0, 1.0)
			board.sound_volume = sound_volume
	_save_game()


func _show_ramiro_choice() -> void:
	_clear_modal()
	narrative_choices = NarrativeChoicesScript.new()
	narrative_choices.trust_selected.connect(_choose_ramiro)
	modal_overlay = narrative_choices.show_ramiro(ui_root, english, large_text)


func _choose_ramiro(trust: bool) -> void:
	story_flags["ramiro_trusted"] = trust
	_save_game()
	_show_mission_briefing()


func _show_mission_briefing() -> void:
	phase = "briefing"
	var mission: Dictionary = Campaign.mission_at(selected_mission - 1)
	var chapter := int(mission["chapter"])
	var text := (
		"%s\n\n%s\n\n%s"
		% [
			String(mission["beat"]),
			CampaignStory.chapter_story(chapter, english),
			_loc(
				"Sobreviva a cinco ondas. Construções e recursos ficam disponíveis até o fim desta missão.",
				"Survive five waves. Structures and resources remain available for this mission."
			),
		]
	)
	if english:
		text = (
			"%s\n\n%s\n\n%s"
			% [
				Localization.mission_beat(selected_mission, true, ""),
				CampaignStory.chapter_story(chapter, true),
				"Survive five waves. Your structures and resources are available throughout this mission.",
			]
		)
	elif selected_mission == 1:
		text = (
			"TEO: «Meu pai dizia que uma cidade não cai por causa do inimigo. "
			+ "Cai por causa do material barato.»\n\n"
			+ "NINA: «Teo! O mar tá fazendo barulho de gente!»\n\n"
			+ "BENTO: «Pega o martelo, menina. Duas tábuas e um punhado de pregos: é o que a gente tem.»\n\n"
			+ text
		)
	if not save_error.is_empty():
		text += "\n\nAviso: " + save_error
	_show_modal(
		(
			"%s %02d · %s"
			% [
				_loc("Missão", "Mission"),
				selected_mission,
				Localization.mission_title(selected_mission, english, String(mission["title"])),
			]
		),
		text,
		[
			{"text": _loc("Voltar", "Back"), "action": Callable(self, "_show_campaign_screen")},
			{
				"text": _loc("Começar missão", "Start mission"),
				"action": Callable(self, "_start_mission"),
			},
		]
	)


func _show_ending_choice() -> void:
	_clear_modal()
	narrative_choices = NarrativeChoicesScript.new()
	narrative_choices.choice_selected.connect(_choose_ending)
	narrative_choices.dismissed.connect(_show_campaign_screen)
	modal_overlay = narrative_choices.show_endings(
		ui_root,
		english,
		collected_diaries.size(),
		collected_diaries.size() == Campaign.DIARIES.size(),
		large_text
	)


func _choose_ending(choice: String) -> void:
	ending_choice = choice
	_save_game()
	_show_mission_briefing()


func _show_prism_puzzle() -> void:
	_clear_modal()
	puzzle_panel = PrismPuzzleScript.new()
	puzzle_panel.solved.connect(func() -> void: puzzle_solved = true)
	puzzle_panel.continue_requested.connect(_show_mission_briefing)
	modal_overlay = puzzle_panel.show(ui_root, english, large_text)


func _start_mission(is_endless: bool = false) -> void:
	current_mission = selected_mission
	var chapter := int(Campaign.mission_at(current_mission - 1)["chapter"])
	unlocked_chapter = maxi(unlocked_chapter, chapter)
	var start_wood := maxi(100 + (chapter - 1) * 25, banked_wood)
	if current_mission >= 22 and bool(story_flags.get("ramiro_trusted", false)):
		start_wood += 30
	var bonus := puzzle_solved and current_mission == 22
	puzzle_solved = false
	phase = "playing"
	_clear_modal()
	_clear_campaign_overlay()
	game_header.visible = true
	footer_panel.visible = true
	board.reduced_motion = reduced_motion
	board.high_contrast = high_contrast
	board.sound_enabled = sound_enabled
	board.sound_volume = sound_volume
	board.english = english
	board.start_mission(current_mission, start_wood, is_endless, ending_choice, bonus, story_flags)
	_refresh_tower_picker()
	_set_message(
		(
			"%s %02d · %s. %s"
			% [
				_loc("Missão", "Mission"),
				current_mission,
				Localization.mission_title(
					current_mission,
					english,
					String(Campaign.mission_at(current_mission - 1)["title"])
				),
				_loc(
					"Balista selecionada; proteja o cais durante cinco ondas.",
					"Ballista selected; defend the docks for five waves."
				),
			]
		)
	)
	_refresh_ui()


func _start_endless_mode() -> void:
	selected_mission = MISSION_COUNT
	ending_choice = ""
	_start_mission(true)
	_set_message(
		_loc(
			"Maré Infinita: sobreviva a ondas crescentes.",
			"Endless Tide: survive ever-growing waves."
		)
	)


func _refresh_tower_picker() -> void:
	selected_tower_id = TowerPicker.refresh(
		tower_picker, current_mission, selected_tower_id, english, board
	)


func _on_board_mission_won() -> void:
	_finish_mission(true)


func _on_board_mission_lost() -> void:
	_finish_mission(false)


func _on_wave_cleared(wave_index: int) -> void:
	var wave_number := wave_index + 1
	if board.endless_mode:
		wave_number = board.endless_completed_waves
	_set_message(
		(
			_loc(
				"Onda %d repelida. Prepare-se para a próxima.",
				"Wave %d repelled. Prepare for the next."
			)
			% wave_number
		)
	)
	_refresh_ui()


func _on_truce_requested() -> void:
	_clear_modal()
	narrative_choices = NarrativeChoicesScript.new()
	narrative_choices.trust_selected.connect(_choose_vorraz)
	modal_overlay = narrative_choices.show_truce(ui_root, english, large_text)


func _choose_vorraz(trust: bool) -> void:
	story_flags["vorraz_trusted"] = trust
	if trust:
		board.wood += 25
	_save_game()
	_resume_truce()


func _resume_truce() -> void:
	_clear_modal()
	board.resume_truce()


func _finish_mission(won: bool) -> void:
	if phase in ["result", "ending"]:
		return
	phase = "result"
	board.build_mode = false
	if not won:
		_show_modal(
			_loc("Derrota · %02d", "Defeat · %02d") % current_mission,
			_loc(
				"O cais caiu. A campanha permanece salva; tente outra estratégia.",
				"The docks have fallen. Your campaign is saved; try another strategy."
			),
			[
				{
					"text": _loc("Tentar novamente", "Retry"),
					"action": Callable(self, "_start_mission").bind(board.endless_mode),
				},
				{
					"text": _loc("Voltar à campanha", "Return to campaign"),
					"action": Callable(self, "_show_campaign_screen"),
				},
			]
		)
		return

	if not completed_missions.has(current_mission):
		completed_missions.append(current_mission)
	unlocked_mission = maxi(unlocked_mission, mini(MISSION_COUNT, current_mission + 1))
	unlocked_chapter = maxi(
		unlocked_chapter, int(Campaign.mission_at(current_mission - 1)["chapter"])
	)
	var reward_bonus := 30 if board.city_health == CITY_HEALTH_MAX else 0
	banked_wood = board.wood + reward_bonus
	var diary: Dictionary = Campaign.diary_for_mission(current_mission)
	var diary_text := ""
	if not diary.is_empty() and board.city_health == CITY_HEALTH_MAX:
		var diary_id := int(diary["id"])
		if not collected_diaries.has(diary_id):
			collected_diaries.append(diary_id)
			diary_text = (
				"\n\n%s: %s."
				% [
					_loc("Diário encontrado", "Journal found"),
					Localization.diary_title(diary_id, english, String(diary["title"])),
				]
			)
	elif not diary.is_empty():
		diary_text = _loc(
			"\n\nO diário opcional exige terminar sem perder vida do cais.",
			"\n\nThe optional journal requires finishing without losing dock health."
		)
	_save_game()
	var save_warning := "" if save_error.is_empty() else "\n\nAviso: " + save_error

	var mission: Dictionary = Campaign.mission_at(current_mission - 1)
	var story := CampaignStory.post_mission(current_mission, english, banked_wood)
	if current_mission == MISSION_COUNT and not board.endless_mode:
		phase = "ending"
		var ending_text := CampaignStory.ending_story(ending_choice, english)
		_show_modal(
			(
				_loc("Fim · %s", "The End · %s")
				% [Localization.mission_title(current_mission, english, String(mission["title"]))]
			),
			(
				ending_text
				+ "\n\n"
				+ _loc(
					(
						"O Livro de Plantas ganha uma página escrita por Teo: "
						+ "«Uma cidade não cai por causa do inimigo. Cai quando esquece de onde veio o material.»"
					),
					(
						"The Book of Plans gains a page in Teo's hand: "
						+ "“A city does not fall to its enemy. It falls when it forgets what it is made of.”"
					)
				)
				+ diary_text
				+ save_warning
			),
			[
				{
					"text": _loc("Voltar à campanha", "Return to campaign"),
					"action": Callable(self, "_show_campaign_screen"),
				},
				{
					"text": _loc("Maré Infinita", "Endless Tide"),
					"action": Callable(self, "_start_endless_mode"),
				},
			]
		)
	else:
		_show_modal(
			(
				_loc("Vitória · %02d · %s", "Victory · %02d · %s")
				% [
					current_mission,
					Localization.mission_title(current_mission, english, String(mission["title"])),
				]
			),
			(
				_loc(
					"Porto Sentinela resistiu. Cais: %d/10. %s%s",
					"Porto Sentinela held. Docks: %d/10. %s%s"
				)
				% [board.city_health, story, diary_text + save_warning]
			),
			[
				{
					"text": _loc("Voltar à campanha", "Return to campaign"),
					"action": Callable(self, "_show_campaign_screen"),
				},
				{
					"text": _loc("Próxima missão", "Next mission"),
					"action": Callable(self, "_start_next_mission"),
				},
			]
		)
	_refresh_ui()


func _start_next_mission() -> void:
	selected_mission = mini(MISSION_COUNT, current_mission + 1)
	_show_campaign_screen()
	_on_prepare_mission()


func _show_diary_archive() -> void:
	_clear_modal()
	diary_archive_panel = DiaryArchiveScript.new()
	diary_archive_panel.dismissed.connect(
		func() -> void:
			_clear_modal()
			_show_campaign_screen()
	)
	modal_overlay = diary_archive_panel.show(ui_root, collected_diaries, english, large_text)


func _load_save() -> void:
	var result: Dictionary = CampaignSave.read(SAVE_PATH)
	if not bool(result["exists"]):
		return
	save_error = String(result["error"])
	if not save_error.is_empty():
		return
	var data: Dictionary = result["data"]
	unlocked_mission = clampi(int(data.get("unlocked_mission", 1)), 1, MISSION_COUNT)
	unlocked_chapter = clampi(int(data.get("unlocked_chapter", 1)), 1, 5)
	banked_wood = maxi(100, int(data.get("banked_wood", 100)))
	ending_choice = String(data.get("ending_choice", ""))
	english = bool(data.get("english", false))
	reduced_motion = bool(data.get("reduced_motion", false))
	high_contrast = bool(data.get("high_contrast", false))
	large_text = bool(data.get("large_text", false))
	sound_enabled = bool(data.get("sound_enabled", true))
	sound_volume = clampf(float(data.get("sound_volume", 0.65)), 0.0, 1.0)
	if data.get("story_flags", {}) is Dictionary:
		story_flags = data["story_flags"].duplicate(true)
	completed_missions = CampaignSave.valid_integer_list(
		data.get("completed_missions", []), 1, MISSION_COUNT
	)
	collected_diaries = CampaignSave.valid_integer_list(
		data.get("collected_diaries", []), 1, Campaign.DIARIES.size()
	)
	if ending_choice not in ["", "selar", "domar", "dialogar"]:
		ending_choice = ""
	if ending_choice == "dialogar" and collected_diaries.size() < Campaign.DIARIES.size():
		ending_choice = ""


func _save_game() -> void:
	save_error = (
		CampaignSave
		. write(
			SAVE_PATH,
			{
				"unlocked_mission": unlocked_mission,
				"unlocked_chapter": unlocked_chapter,
				"banked_wood": banked_wood,
				"ending_choice": ending_choice,
				"completed_missions": completed_missions,
				"collected_diaries": collected_diaries,
				"english": english,
				"reduced_motion": reduced_motion,
				"high_contrast": high_contrast,
				"large_text": large_text,
				"sound_enabled": sound_enabled,
				"sound_volume": sound_volume,
				"story_flags": story_flags,
			}
		)
	)
	if not save_error.is_empty():
		_set_message(save_error)


func _show_modal(title: String, body: String, actions: Array[Dictionary]) -> void:
	_clear_modal()
	var dialog: Variant = ModalDialogScript.new()
	modal_overlay = dialog.show(ui_root, title, body, actions, large_text)


func _clear_modal() -> void:
	if is_instance_valid(modal_overlay):
		modal_overlay.queue_free()
	modal_overlay = null


func _clear_campaign_overlay() -> void:
	if is_instance_valid(campaign_overlay):
		campaign_overlay.queue_free()
	campaign_overlay = null


func _set_message(text: String) -> void:
	message = text
	message_time = 3.0
	if is_instance_valid(status_label):
		status_label.text = message


func _refresh_ui() -> void:
	if not is_instance_valid(mission_title_label) or not board.visible:
		return
	var mission: Dictionary = Campaign.mission_at(current_mission - 1)
	mission_title_label.text = (
		"%02d · %s"
		% [
			current_mission,
			Localization.mission_title(current_mission, english, String(mission["title"])),
		]
	)
	material_label.text = Localization.material_name(
		board.selected_material_id,
		english,
		String(Campaign.material_by_id(board.selected_material_id)["name"])
	)
	wood_label.text = _loc("Madeira %d", "Wood %d") % board.wood
	health_label.text = _loc("Cais %d/%d", "Docks %d/%d") % [board.city_health, CITY_HEALTH_MAX]
	if board.endless_mode:
		wave_label.text = _loc("∞ Onda %d", "∞ Wave %d") % (board.endless_completed_waves + 1)
	else:
		wave_label.text = _loc("Onda %d/5", "Wave %d/5") % maxi(0, board.current_wave + 1)
	if current_mission == 17 and board.phase == "combat":
		wave_label.text += (
			" · "
			+ (_loc("Tempestade", "Storm") if board.storm_active else _loc("Calmaria", "Calm"))
		)

	var building_allowed := board.phase in ["build", "intermission"]
	build_button.disabled = not building_allowed
	build_button.text = (
		_loc("Cancelar", "Cancel") if board.build_mode else _loc("Construir", "Build")
	)
	material_button.text = _loc("Material", "Material")
	material_button.disabled = not building_allowed
	wave_button.disabled = not building_allowed
	wave_button.text = (
		_loc("Próxima onda", "Next wave")
		if board.phase == "intermission"
		else _loc("Iniciar onda", "Start wave")
	)
	pause_button.disabled = board.phase not in ["combat", "paused"]
	pause_button.text = (
		_loc("Retomar", "Resume") if board.phase == "paused" else _loc("Pausar", "Pause")
	)
	campaign_button.disabled = board.phase in ["combat", "story_pause"]
	campaign_button.text = _loc("Campanha", "Campaign")
	if board.selected_tower_index >= 0 and board.selected_tower_index < board.towers.size():
		var tower: Dictionary = board.towers[board.selected_tower_index]
		upgrade_button.disabled = not building_allowed or int(tower["level"]) >= 3
		upgrade_button.text = _loc("Melhorar · Nv.%d", "Upgrade · Lv.%d") % int(tower["level"])
	else:
		upgrade_button.disabled = true
		upgrade_button.text = _loc("Melhorar", "Upgrade")
	status_label.text = message


func _loc(portuguese: String, english_text: String) -> String:
	return english_text if english else portuguese
