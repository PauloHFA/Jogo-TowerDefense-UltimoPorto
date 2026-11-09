extends SceneTree

const Campaign = preload("res://scripts/campaign_data.gd")
const MissionBoardScript = preload("res://scripts/mission_board.gd")
const CampaignSave = preload("res://scripts/campaign_save.gd")
const Localization = preload("res://scripts/localization.gd")
const TowerPicker = preload("res://scripts/tower_picker.gd")
const UiAccessibility = preload("res://scripts/ui_accessibility.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	assert(Campaign.MISSIONS.size() == 25, "Campaign must define all 25 missions.")
	assert(Campaign.DIARIES.size() == 12, "Campaign must define all 12 diaries.")
	assert(Campaign.TOWERS.size() == 9, "Campaign must define all nine defense types.")
	assert(Campaign.MISSION_ENCOUNTERS.size() == 25, "Every mission needs its own encounter.")

	var seen_mission_ids: Array[int] = []
	for mission in Campaign.MISSIONS:
		var mission_id := int(mission["id"])
		assert(not seen_mission_ids.has(mission_id), "Mission IDs must be unique.")
		seen_mission_ids.append(mission_id)
		assert(not String(mission["title"]).is_empty(), "Every mission needs a title.")
		for wave_index in range(5):
			var wave := Campaign.wave_composition(mission_id, wave_index)
			assert(not wave.is_empty(), "Every mission wave must contain enemies.")
			assert(
				not String(Campaign.encounter_for_mission(mission_id)["objective"]).is_empty(),
				"Every mission needs a tactical objective."
			)
			for enemy in wave:
				assert(
					Campaign.ENEMIES.has(String(enemy["id"])), "Wave references an undefined enemy."
				)
				if wave_index < 4:
					assert(
						not Campaign.BOSS_IDS.has(String(enemy["id"])),
						"Bosses should only appear in their authored final encounter."
					)
			if wave_index == 4 and not String(mission["boss"]).is_empty():
				assert(
					String(wave.back()["id"]) == String(mission["boss"]),
					"Mission boss must be in the final wave."
				)

	var diary_ids: Array[int] = []
	for diary in Campaign.DIARIES:
		var diary_id := int(diary["id"])
		assert(not diary_ids.has(diary_id), "Diary IDs must be unique.")
		diary_ids.append(diary_id)
		assert(not Campaign.diary_for_mission(int(diary["mission"])).is_empty())

	assert(
		Campaign.available_towers(1).size() == 1, "Mission 1 should start with the Ballista only."
	)
	assert(Campaign.available_towers(21).size() == Campaign.TOWERS.size())
	assert(
		Campaign.available_towers(4).size() == 4,
		"The anti-air beacon must unlock with the first flying enemies."
	)
	assert(Localization.objective(1, true, "fallback") == "Learn to prioritize the nearest enemy.")
	assert(Localization.tower_name("farol_aa", true, "fallback") == "Anti-Air Beacon")
	assert(Localization.enemy_name("polvo_sapador", true, "fallback") == "Demolition Octopus")
	var preferences_root := Control.new()
	root.add_child(preferences_root)
	var preferences_label := Label.new()
	preferences_label.set_meta("base_font_size", 14)
	preferences_label.set_meta("base_font_color", Color("#777777"))
	preferences_root.add_child(preferences_label)
	UiAccessibility.apply(preferences_root, true, true)
	assert(preferences_label.get_theme_font_size("font_size") == 17)
	assert(preferences_label.get_theme_color("font_color") == Color.WHITE)
	UiAccessibility.apply(preferences_root, false, false)
	assert(preferences_label.get_theme_font_size("font_size") == 14)
	assert(preferences_label.get_theme_color("font_color") == Color("#777777"))
	preferences_root.free()
	assert(Campaign.available_enemies(1).size() >= 3)
	assert(Campaign.available_enemies(5).size() > Campaign.available_enemies(1).size())
	for enemy_id in Campaign.available_enemies(5):
		assert(
			not Campaign.BOSS_IDS.has(enemy_id),
			"Endless mode must not treat bosses as regular units."
		)

	var board = MissionBoardScript.new()
	root.add_child(board)
	board.sound_enabled = false
	board.effects.sound_enabled = false
	var picker := OptionButton.new()
	root.add_child(picker)
	assert(
		(
			TowerPicker.refresh(picker, 4, "balista", true, board) == "balista"
			and picker.item_count == Campaign.available_towers(4).size()
		),
		"Tower selection should use localized names and preserve an unlocked selection."
	)
	picker.free()
	var previous_route: Array[Vector2] = []
	for mission_id in range(1, 26):
		board.start_mission(mission_id, 100, false, "", false)
		assert(
			board.path_routes.size() == (2 if mission_id == 8 else 1),
			"Only mission 8 should have two enemy routes."
		)
		assert(board.route_lengths[0] > 0.0, "Chapter routes must have nonzero length.")
		if mission_id > 1:
			assert(
				board.path_routes[0] != previous_route,
				"Every mission must use a distinct authored route."
			)
		previous_route = board.path_routes[0].duplicate()
		for cell in board.path_cells:
			assert(cell.x >= 0 and cell.x < 10 and cell.y >= 0 and cell.y < 7)

	board.start_mission(1, 100, false, "", false)
	assert(board.phase == "build")
	assert(board.path_routes.size() == 1)
	board.select_tower("balista")
	board.toggle_build_mode()
	board._try_place_tower(Vector2i(1, 0))
	assert(board.towers.size() == 1, "A Balista should be buildable on empty ground.")
	assert(board.wood == 60, "Building the Balista should deduct its cost.")
	assert(
		not board.effects.particles.is_empty(),
		"Building should play an animated construction burst."
	)
	board.selected_tower_index = 0
	board.upgrade_selected_tower()
	assert(int(board.towers[0]["level"]) == 2, "Selected defenses should upgrade.")
	board._sell_tower(Vector2i(1, 0))
	assert(board.towers.is_empty(), "Right-click selling should remove a defense.")

	board.start_mission(8, 100, false, "", false)
	assert(board.path_routes.size() == 2, "Mission 8 should have two enemy routes.")
	board.start_mission(1, 10000, false, "", false)
	for cell in [
		Vector2i(1, 0),
		Vector2i(3, 0),
		Vector2i(3, 2),
		Vector2i(6, 2),
		Vector2i(6, 6),
		Vector2i(1, 4),
		Vector2i(7, 4),
		Vector2i(9, 4),
	]:
		board.select_tower("balista")
		board.toggle_build_mode()
		board._try_place_tower(cell)
	assert(board.towers.size() == 8, "Defense placement should support multiple structures.")
	board.start_next_wave()
	for _step in range(800):
		if board.phase != "combat":
			break
		board._process(0.05)
	assert(board.phase == "intermission", "Automatic attacks should clear the first wave.")
	assert(board.enemies.is_empty(), "A cleared wave should leave no live enemies.")
	assert(not board.effects.particles.is_empty(), "Defeated enemies should emit impact particles.")
	board.phase = "combat"
	var paused_enemies: Array[Dictionary] = [{"distance": 12.0}]
	board.enemies = paused_enemies
	board.toggle_pause()
	assert(board.phase == "paused", "The pause control should stop combat.")
	board._process(0.5)
	assert(
		is_equal_approx(float(board.enemies[0]["distance"]), 12.0),
		"Enemy movement must stop while the battle is paused."
	)
	board.toggle_pause()
	assert(board.phase == "combat", "The pause control should resume combat.")

	board.start_mission(1, 10000, false, "", false)
	board.current_wave = 0
	board.start_next_wave()
	var expected_wave: Array[Dictionary] = board.wave_composition.duplicate()
	board._spawn_enemy()
	assert(String(board.enemies[0]["id"]) == String(expected_wave[0]["id"]))
	board.spawn_remaining -= 1
	board._spawn_enemy()
	assert(String(board.enemies[1]["id"]) == String(expected_wave[1]["id"]))

	board.start_mission(5, 100, false, "", false)
	board.current_wave = 3
	board.start_next_wave()
	assert(String(board.wave_composition.back()["id"]) == "caranguejo_sineiro")
	board.spawn_remaining = 1
	board._spawn_enemy()
	assert(String(board.enemies[0]["id"]) == "caranguejo_sineiro")
	assert(bool(board.enemies[0]["boss"]), "The chapter boss must spawn as a boss.")

	board.start_mission(4, 500, false, "", false)
	var anti_air_towers: Array[Dictionary] = [
		{"id": "farol_aa", "cell": Vector2i(1, 0), "material": "madeira", "level": 1}
	]
	board.towers = anti_air_towers
	var test_enemies: Array[Dictionary] = [
		{"id": "caranguejinho", "distance": 80.0, "route": 0},
		{"id": "arraia_vela", "distance": 70.0, "route": 0},
	]
	board.enemies = test_enemies
	var anti_air: Dictionary = Campaign.tower_by_id("farol_aa")
	assert(
		board._find_target(board.towers[0], anti_air) == 1,
		"The anti-air beacon must prioritize and exclusively target flying enemies."
	)

	var test_enemy := {"id": "caranguejinho", "health": 100.0, "hit_flash": 0.0}
	var physical_damage := board._apply_damage(test_enemy, 20.0, "physical", 0.0)
	assert(is_equal_approx(physical_damage, 18.0), "Physical resistance should reduce damage.")
	test_enemy["health"] = 100.0
	var fire_damage := board._apply_damage(test_enemy, 20.0, "fire", 0.0)
	assert(is_equal_approx(fire_damage, 25.0), "Fire weakness should increase damage.")

	var synergy_towers: Array[Dictionary] = [
		{"id": "piche", "cell": Vector2i(1, 1)},
		{"id": "bobina", "cell": Vector2i(2, 1)},
	]
	board.towers = synergy_towers
	var synergy := board._synergy_multiplier(
		board.towers[0], Campaign.tower_by_id("piche"), test_enemy
	)
	assert(is_equal_approx(synergy, 1.2), "Tar and Coil should activate their tactical synergy.")

	board.start_mission(25, 100, false, "domar", false)
	board.current_wave = 3
	board.start_next_wave()
	board.spawn_remaining = 1
	board._spawn_enemy()
	var final_boss: Dictionary = board.enemies[0]
	assert(String(final_boss["id"]) == "coracao_mare")
	var expected_health := float(Campaign.ENEMIES["coracao_mare"]["health"]) * 1.48 * 1.25
	assert(is_equal_approx(float(final_boss["health"]), expected_health))
	board.start_mission(
		25, 100, false, "domar", false, {"vorraz_trusted": true, "ramiro_trusted": true}
	)
	board.current_wave = 3
	board.start_next_wave()
	board.spawn_remaining = 1
	board._spawn_enemy()
	assert(
		is_equal_approx(float(board.enemies[0]["health"]), expected_health * 0.81),
		"Earlier narrative choices should affect the final boss."
	)
	for mission_id in range(1, Campaign.MISSIONS.size() + 1):
		_simulate_full_mission(board, mission_id)

	var temporary_save := "user://campaign-test-%d.json" % Time.get_ticks_usec()
	var test_progress := {
		"unlocked_mission": 21,
		"english": true,
		"story_flags": {"vorraz_trusted": true},
	}
	assert(CampaignSave.write(temporary_save, test_progress).is_empty())
	var loaded_save: Dictionary = CampaignSave.read(temporary_save)
	var loaded_data: Dictionary = loaded_save["data"]
	var save_matches := (
		bool(loaded_save["exists"])
		and String(loaded_save["error"]).is_empty()
		and int(loaded_data.get("unlocked_mission", -1)) == 21
		and bool(loaded_data.get("english", false))
		and bool(loaded_data.get("story_flags", {}).get("vorraz_trusted", false))
	)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(temporary_save))
	board.free()
	assert(save_matches, "Settings and story choices must persist.")
	assert(
		CampaignSave.valid_integer_list([1, 2, 2, 26, -1, "3"], 1, 25) == [1, 2],
		"Save validation should discard duplicates, out-of-range values and non-integers."
	)

	print("Campaign data and mission board tests passed.")
	quit()


func _simulate_full_mission(board: Variant, mission_id: int) -> void:
	board.start_mission(mission_id, 100000, false, "selar", false)
	board.sound_enabled = false
	board.effects.sound_enabled = false
	board.select_tower("balista")
	for y in range(board.BOARD_ROWS):
		for x in range(board.BOARD_COLUMNS):
			var cell := Vector2i(x, y)
			if board.path_cells.has(cell):
				continue
			board.build_mode = true
			board._try_place_tower(cell)

	for wave_index in range(5):
		board.start_next_wave()
		var steps := 0
		while board.phase in ["combat", "story_pause"] and steps < 12000:
			if board.phase == "story_pause":
				board.resume_truce()
			board._process(0.05)
			if board.phase == "story_pause":
				board.resume_truce()
			steps += 1
		assert(
			board.phase in ["intermission", "won"],
			(
				"Mission %d wave %d should be completable without losing."
				% [mission_id, wave_index + 1]
			)
		)
	assert(board.phase == "won", "Mission %d should complete all five waves." % mission_id)
