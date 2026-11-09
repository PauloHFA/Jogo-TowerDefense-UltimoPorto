class_name MissionBoard
extends Node2D

signal message_requested(text: String)
signal wave_cleared(wave_index: int)
signal mission_won
signal mission_lost
signal truce_requested

const Campaign = preload("res://scripts/campaign_data.gd")
const Localization = preload("res://scripts/localization.gd")
const MissionRoutes = preload("res://scripts/mission_routes.gd")
const CombatEffectsScript = preload("res://scripts/combat_effects.gd")
const BoardPainterScript = preload("res://scripts/board_painter.gd")
const CombatRules = preload("res://scripts/combat_rules.gd")
const BOARD_ORIGIN := Vector2(140.0, 134.0)
const TILE_SIZE := 72
const BOARD_COLUMNS := 10
const BOARD_ROWS := 7
const WAVE_COUNT := 5
const CITY_HEALTH_MAX := 10
const SPAWN_INTERVAL := 0.72
const COLOR_PANEL_EDGE := Color("#40545b")
const COLOR_PATH_EDGE := Color("#94815a")
const COLOR_TOWER_DARK := Color("#49392d")
const COLOR_ENEMY := Color("#cc7054")
const COLOR_HEALTH := Color("#83bd77")
const CHAPTER_COLORS: Dictionary = {
	1: {"water": Color("#19323c"), "path": Color("#645943")},
	2: {"water": Color("#243039"), "path": Color("#81785f")},
	3: {"water": Color("#172a34"), "path": Color("#59666a")},
	4: {"water": Color("#163642"), "path": Color("#5b777b")},
	5: {"water": Color("#211f39"), "path": Color("#685b83")},
}
const MATERIAL_COLORS: Dictionary = {
	"madeira": Color("#b17a43"),
	"pedra": Color("#9a9b91"),
	"ferro": Color("#75959a"),
	"aco": Color("#bed0d0"),
	"cristal_mare": Color("#9ad9e4"),
}
const TOWER_COLORS: Dictionary = {
	"balista": Color("#c18b4d"),
	"farol_aa": Color("#80d7e8"),
	"muralha": Color("#958674"),
	"piche": Color("#c56839"),
	"canhao": Color("#606f7d"),
	"bobina": Color("#9bbfcb"),
	"morteiro": Color("#727f85"),
	"reparo": Color("#88b77b"),
	"prisma": Color("#8bd6dd"),
}
const ENDING_BOSS_MODIFIERS: Dictionary = {
	"selar": 0.85,
	"domar": 1.25,
	"dialogar": 0.72,
}

var mission_id := 1
var phase := "inactive"
var current_wave := -1
var endless_mode := false
var endless_completed_waves := 0
var ending_choice := ""
var wood := 100
var city_health := CITY_HEALTH_MAX
var build_mode := false
var selected_tower_id := "balista"
var selected_material_id := "madeira"
var selected_tower_index := -1
var hovered_cell := Vector2i(-1, -1)
var path_cells: Array[Vector2i] = []
var path_routes: Array[Array] = []
var route_lengths: Array[float] = []
var towers: Array[Dictionary] = []
var enemies: Array[Dictionary] = []
var wave_composition: Array[Dictionary] = []
var spawn_remaining := 0
var spawn_timer := 0.0
var storm_timer := 0.0
var storm_active := false
var truce_triggered := false
var crystal_corruption := 0.0
var reduced_motion := false
var high_contrast := false
var sound_enabled := true
var sound_volume := 0.65
var visual_time := 0.0
var shake_strength := 0.0
var shake_offset := Vector2.ZERO
var story_flags: Dictionary = {}
var effects: Variant
var painter: Variant
var english := false
var tutorial_step := 0


func _ready() -> void:
	visible = false
	effects = CombatEffectsScript.new()
	effects.z_index = 1
	add_child(effects)
	painter = BoardPainterScript.new()


func start_mission(
	new_mission_id: int,
	initial_wood: int,
	is_endless: bool,
	selected_ending: String,
	puzzle_bonus: bool,
	narrative_flags: Dictionary = {}
) -> void:
	mission_id = new_mission_id
	endless_mode = is_endless
	ending_choice = selected_ending
	story_flags = narrative_flags.duplicate(true)
	tutorial_step = 0
	current_wave = -1
	endless_completed_waves = 0
	wave_composition.clear()
	spawn_remaining = 0
	spawn_timer = 0.0
	towers.clear()
	enemies.clear()
	city_health = CITY_HEALTH_MAX
	var chapter := int(Campaign.mission_at(mission_id - 1)["chapter"])
	selected_material_id = String(Campaign.material_for_chapter(chapter)["id"])
	wood = initial_wood + (50 if puzzle_bonus else 0)
	crystal_corruption = 0.0
	storm_timer = 0.0
	storm_active = false
	truce_triggered = false
	selected_tower_index = -1
	build_mode = false
	effects.clear()
	shake_strength = 0.0
	shake_offset = Vector2.ZERO
	_build_path()
	phase = "build"
	visible = true
	queue_redraw()


func select_tower(tower_id: String) -> void:
	selected_tower_id = tower_id


func toggle_build_mode() -> void:
	if phase not in ["build", "intermission"]:
		return
	build_mode = not build_mode
	selected_tower_index = -1
	var spec: Dictionary = Campaign.tower_by_id(selected_tower_id)
	if mission_id == 1 and tutorial_step == 0 and build_mode:
		_request_message(
			(
				"Tutorial · step 1/3: select Build and place a Ballista on open ground."
				if english
				else "Tutorial · etapa 1/3: selecione Construir e coloque uma Balista em terreno livre."
			)
		)
	elif build_mode:
		var tower_name := Localization.tower_name(String(spec["id"]), english, String(spec["name"]))
		_request_message(
			(
				"Click open ground to build %s." % tower_name
				if english
				else "Clique em terreno livre para construir %s." % tower_name
			)
		)
	else:
		_request_message("Build mode canceled." if english else "Modo de construção cancelado.")
	queue_redraw()


func toggle_pause() -> void:
	if phase == "combat":
		phase = "paused"
		_request_message("Game paused." if english else "Jogo pausado.")
	elif phase == "paused":
		phase = "combat"
		_request_message("Combat resumed." if english else "Combate retomado.")


func cycle_material() -> void:
	var chapter := int(Campaign.mission_at(mission_id - 1)["chapter"])
	var available: Array[Dictionary] = []
	for material in Campaign.MATERIALS:
		if int(material["chapter"]) <= chapter:
			available.append(material)
	for index in range(available.size()):
		if String(available[index]["id"]) == selected_material_id:
			selected_material_id = String(available[(index + 1) % available.size()]["id"])
			break
	var material_name := Localization.material_name(
		selected_material_id, english, String(_material_spec(selected_material_id)["name"])
	)
	_request_message(
		(
			"Material selected: %s." % material_name
			if english
			else "Material selecionado: %s." % material_name
		)
	)


func upgrade_selected_tower() -> void:
	if selected_tower_index < 0 or selected_tower_index >= towers.size():
		return
	var tower: Dictionary = towers[selected_tower_index]
	if int(tower["level"]) >= 3:
		_request_message(
			(
				"This structure is already at maximum level."
				if english
				else "Esta construção já alcançou o nível máximo."
			)
		)
		return
	var spec: Dictionary = Campaign.tower_by_id(String(tower["id"]))
	var material: Dictionary = _material_spec(selected_material_id)
	var price := roundi(
		float(spec["cost"]) * float(material["cost"]) * (0.65 + float(tower["level"]) * 0.45)
	)
	if wood < price:
		_request_message(
			(
				"Not enough wood to upgrade: %d needed; you have %d." % [price, wood]
				if english
				else (
					"Madeira insuficiente para melhorar: %d necessária; você tem %d."
					% [price, wood]
				)
			)
		)
		return
	wood -= price
	tower["level"] = int(tower["level"]) + 1
	tower["material"] = selected_material_id
	tower["max_health"] = 100.0 * float(material["durability"])
	tower["health"] = float(tower["max_health"])
	var tower_name := Localization.tower_name(String(spec["id"]), english, String(spec["name"]))
	var material_name := Localization.material_name(
		selected_material_id, english, String(material["name"])
	)
	_request_message(
		(
			"%s upgraded to level %d with %s." % [tower_name, int(tower["level"]), material_name]
			if english
			else (
				"%s melhorada para nível %d com %s."
				% [tower_name, int(tower["level"]), material_name]
			)
		)
	)
	queue_redraw()


func start_next_wave() -> void:
	if phase not in ["build", "intermission"]:
		return
	if endless_mode:
		current_wave = endless_completed_waves % WAVE_COUNT
	else:
		current_wave += 1
	wave_composition = _get_wave_composition(current_wave)
	spawn_remaining = wave_composition.size()
	spawn_timer = 0.0
	build_mode = false
	selected_tower_index = -1
	phase = "combat"
	var tutorial_hint := ""
	if mission_id == 1 and tutorial_step == 1:
		tutorial_step = 2
		tutorial_hint = (
			"\nTutorial · step 2/3: watch enemy targets and your towers' range."
			if english
			else "\nTutorial · etapa 2/3: acompanhe os alvos e o alcance das torres."
		)
	var objective: Dictionary = Campaign.encounter_for_mission(mission_id)
	_request_message(
		(
			"%s %d · %d %s. %s %s%s"
			% [
				"Wave" if english else "Onda",
				current_wave + 1,
				spawn_remaining,
				"enemies" if english else "inimigos",
				"Objective:" if english else "Objetivo:",
				Localization.objective(mission_id, english, String(objective["objective"])),
				tutorial_hint,
			]
		)
	)


func resume_truce() -> void:
	if phase == "story_pause":
		phase = "combat"


func _process(delta: float) -> void:
	_update_visuals(delta)
	if phase == "combat":
		_update_combat(delta)


func _update_visuals(delta: float) -> void:
	visual_time += delta
	shake_strength = maxf(0.0, shake_strength - delta * (24.0 if reduced_motion else 15.0))
	shake_offset = Vector2.ZERO
	if shake_strength > 0.0:
		var shake_scale := 0.35 if reduced_motion else 1.0
		shake_offset = (
			Vector2(
				randf_range(-shake_strength, shake_strength),
				randf_range(-shake_strength, shake_strength)
			)
			* shake_scale
		)
	for enemy in enemies:
		enemy["hit_flash"] = maxf(0.0, float(enemy.get("hit_flash", 0.0)) - delta * 4.0)
		enemy["animation_time"] = float(enemy.get("animation_time", 0.0)) + delta
	for tower in towers:
		tower["recoil"] = maxf(0.0, float(tower.get("recoil", 0.0)) - delta * 7.0)
		tower["build_age"] = float(tower.get("build_age", 0.0)) + delta
	effects.reduced_motion = reduced_motion
	effects.sound_enabled = sound_enabled
	effects.sound_volume = sound_volume
	effects.set_shake_offset(shake_offset)
	if visible and phase == "combat":
		queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_P and phase in ["combat", "paused"]:
			toggle_pause()
			return
		if event.keycode == KEY_ESCAPE and phase in ["combat", "paused"]:
			toggle_pause()
			return
	if phase not in ["build", "combat", "intermission"]:
		return
	if event is InputEventMouseMotion:
		hovered_cell = _cell_at(event.position)
		queue_redraw()
	elif event is InputEventMouseButton and event.pressed:
		var cell := _cell_at(event.position)
		if event.button_index == MOUSE_BUTTON_LEFT:
			_handle_board_click(cell)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_sell_tower(cell)
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			build_mode = false
			selected_tower_index = -1
			_request_message("Build canceled." if english else "Construção cancelada.")
		elif event.keycode == KEY_SPACE and phase in ["build", "intermission"]:
			start_next_wave()


func _build_path() -> void:
	path_cells.clear()
	path_routes.clear()
	route_lengths.clear()
	var primary := MissionRoutes.for_mission(mission_id)
	var routes: Array[Array] = [primary]
	if mission_id == 8:
		(
			routes
			. append(
				[
					Vector2i(0, 6),
					Vector2i(3, 6),
					Vector2i(3, 4),
					Vector2i(6, 4),
					Vector2i(6, 2),
					Vector2i(8, 2),
					Vector2i(8, 3),
					Vector2i(9, 3),
				]
			)
		)

	for waypoints: Array in routes:
		var points: Array[Vector2] = []
		for waypoint: Vector2i in waypoints:
			points.append(_cell_center(waypoint))
		for segment_index in range(waypoints.size() - 1):
			var start: Vector2i = waypoints[segment_index]
			var finish: Vector2i = waypoints[segment_index + 1]
			var step := Vector2i(signi(finish.x - start.x), signi(finish.y - start.y))
			var cell := start
			while true:
				if not path_cells.has(cell):
					path_cells.append(cell)
				if cell == finish:
					break
				cell += step
		var route_length := 0.0
		for index in range(points.size() - 1):
			route_length += points[index].distance_to(points[index + 1])
		path_routes.append(points)
		route_lengths.append(route_length)


func _handle_board_click(cell: Vector2i) -> void:
	if cell.x < 0:
		return
	if build_mode:
		_try_place_tower(cell)
		return
	selected_tower_index = _tower_at(cell)
	if selected_tower_index >= 0:
		var tower: Dictionary = towers[selected_tower_index]
		var spec: Dictionary = Campaign.tower_by_id(String(tower["id"]))
		var tower_name := Localization.tower_name(String(spec["id"]), english, String(spec["name"]))
		var material_name := Localization.material_name(
			String(tower["material"]), english, String(_material_spec(tower["material"])["name"])
		)
		_request_message(
			(
				(
					"%s · level %d/3 · %s. Use Upgrade or right-click to sell."
					% [tower_name, int(tower["level"]), material_name]
				)
				if english
				else (
					"%s · nível %d/3 · %s. Use Melhorar ou clique direito para vender."
					% [tower_name, int(tower["level"]), material_name]
				)
			)
		)
	queue_redraw()


func _try_place_tower(cell: Vector2i) -> void:
	if cell.x >= BOARD_COLUMNS or cell.y >= BOARD_ROWS:
		return
	if path_cells.has(cell):
		_request_message(
			(
				"You cannot block the Shells' route."
				if english
				else "Não é possível bloquear o caminho dos Cascos."
			)
		)
		return
	if _tower_at(cell) != -1:
		_request_message(
			"This tile is already occupied." if english else "Este terreno já está ocupado."
		)
		return
	var spec: Dictionary = Campaign.tower_by_id(selected_tower_id)
	var material: Dictionary = _material_spec(selected_material_id)
	var price := roundi(float(spec["cost"]) * float(material["cost"]))
	if wood < price:
		_request_message(
			(
				"Not enough wood: %d needed; you have %d." % [price, wood]
				if english
				else "Madeira insuficiente: %d necessária; você tem %d." % [price, wood]
			)
		)
		return
	wood -= price
	var max_health := 100.0 * float(material["durability"])
	var tower_position := _cell_center(cell)
	(
		towers
		. append(
			{
				"id": selected_tower_id,
				"cell": cell,
				"material": selected_material_id,
				"level": 1,
				"health": max_health,
				"max_health": max_health,
				"cooldown": 0.2,
				"disabled": 0.0,
				"ability_clock": 0.0,
				"recoil": 0.0,
				"build_age": 0.0,
			}
		)
	)
	effects.spawn_burst(
		tower_position, TOWER_COLORS.get(selected_tower_id, Color("#b17a43")), 24, 150.0
	)
	effects.play_sfx("build")
	build_mode = false
	var tower_name := Localization.tower_name(String(spec["id"]), english, String(spec["name"]))
	var material_name := Localization.material_name(
		selected_material_id, english, String(material["name"])
	)
	var placement_message := (
		"%s built with %s. Cost: %d wood." % [tower_name, material_name, price]
		if english
		else "%s construída em %s. Custo: %d madeiras." % [tower_name, material_name, price]
	)
	if mission_id == 1 and tutorial_step == 0:
		tutorial_step = 1
		placement_message += (
			"\nTutorial · step 2/3: start the first wave and watch the targets."
			if english
			else "\nTutorial · etapa 2/3: inicie a primeira onda e observe os alvos."
		)
	_request_message(placement_message)
	queue_redraw()


func _sell_tower(cell: Vector2i) -> void:
	var index := _tower_at(cell)
	if index < 0:
		return
	var tower: Dictionary = towers[index]
	var spec: Dictionary = Campaign.tower_by_id(String(tower["id"]))
	var material: Dictionary = _material_spec(String(tower["material"]))
	var paid := roundi(float(spec["cost"]) * float(material["cost"]))
	var refund := roundi(float(paid) * 0.5)
	wood += refund
	towers.remove_at(index)
	selected_tower_index = -1
	_request_message(
		(
			"Structure sold for half its cost: %d wood." % refund
			if english
			else "Construção vendida pela metade do custo: %d madeiras." % refund
		)
	)
	queue_redraw()


func _tower_at(cell: Vector2i) -> int:
	for index in range(towers.size()):
		if towers[index]["cell"] == cell:
			return index
	return -1


func _get_wave_composition(wave_index: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if endless_mode:
		var pool: Array[String] = Campaign.available_enemies(5)
		var count := 15 + endless_completed_waves * 3
		for index in range(count):
			var enemy_id: String = pool[(index + endless_completed_waves * 3) % pool.size()]
			result.append({"id": enemy_id, "boss": false})
		if endless_completed_waves % WAVE_COUNT == WAVE_COUNT - 1:
			result.append({"id": "coracao_mare", "boss": true})
		return result
	for enemy in Campaign.wave_composition(mission_id, wave_index):
		result.append(enemy)
	return result


func _update_combat(delta: float) -> void:
	if mission_id == 17:
		storm_timer += delta
		if storm_timer >= 8.0:
			storm_timer = 0.0
			storm_active = not storm_active
			if english:
				_request_message(
					"Storm: towers lose range." if storm_active else "The wind slows the Shells."
				)
			else:
				_request_message(
					(
						"Tempestade: "
						+ (
							"as torres perdem alcance."
							if storm_active
							else "o vento abranda os Cascos."
						)
					)
				)

	if spawn_remaining > 0:
		spawn_timer -= delta
		if spawn_timer <= 0.0:
			_spawn_enemy()
			spawn_remaining -= 1
			spawn_timer = SPAWN_INTERVAL * (0.72 if storm_active else 1.0)
			if (
				mission_id == 19
				and current_wave == 2
				and not truce_triggered
				and spawn_remaining == int(wave_composition.size() / 2)
			):
				truce_triggered = true
				phase = "story_pause"
				truce_requested.emit()
				return

	for enemy_index in range(enemies.size() - 1, -1, -1):
		var enemy: Dictionary = enemies[enemy_index]
		var enemy_spec: Dictionary = Campaign.ENEMIES[String(enemy["id"])]
		enemy["distance"] = (
			float(enemy["distance"]) + CombatRules.enemy_speed(self, enemy_spec) * delta
		)
		_enemy_disables_tower(enemy, enemy_spec, delta)
		enemy["burn_clock"] = float(enemy["burn_clock"]) - delta
		if float(enemy["burn_clock"]) <= 0.0 and float(enemy["burning"]) > 0.0:
			_apply_damage(enemy, float(enemy["burning"]), "fire", 0.0, true)
			enemy["burn_clock"] = 0.5
			if float(enemy["health"]) <= 0.0:
				_kill_enemy(enemy_index)
				continue
		var route_id := int(enemy["route"])
		if float(enemy["distance"]) >= route_lengths[route_id]:
			enemies.remove_at(enemy_index)
			city_health -= 2 if enemy_spec["ability"] in ["siege", "burst"] else 1
			if city_health <= 0:
				city_health = 0
				phase = "lost"
				mission_lost.emit()
				return

	_update_towers(delta)
	if phase != "combat":
		return
	if spawn_remaining == 0 and enemies.is_empty():
		if endless_mode:
			phase = "intermission"
			endless_completed_waves += 1
			_request_message(
				(
					(
						"Wave %d repelled. Prepare: the next one will be harder."
						% endless_completed_waves
					)
					if english
					else (
						"Onda %d repelida. Prepare-se: a próxima será mais difícil."
						% endless_completed_waves
					)
				)
			)
			wave_cleared.emit(current_wave)
		elif current_wave == WAVE_COUNT - 1:
			phase = "won"
			mission_won.emit()
		else:
			phase = "intermission"
			_request_message(
				(
					"Wave repelled. Reinforce your defenses before the next one."
					if english
					else "Onda repelida. Reforce as defesas antes da próxima."
				)
			)
			if mission_id == 1 and current_wave == 0:
				tutorial_step = 3
				_request_message(
					(
						"Tutorial complete! Now try combining your defenses."
						if english
						else "Tutorial concluído! Agora experimente combinar suas defesas."
					)
				)
			wave_cleared.emit(current_wave)


func _spawn_enemy() -> void:
	if wave_composition.is_empty():
		return
	var spawn_index := wave_composition.size() - spawn_remaining
	var entry: Dictionary = wave_composition[clampi(spawn_index, 0, wave_composition.size() - 1)]
	var spec: Dictionary = Campaign.ENEMIES[String(entry["id"])]
	var chapter := int(Campaign.mission_at(mission_id - 1)["chapter"])
	var health := float(spec["health"]) * (1.0 + float(chapter - 1) * 0.12)
	if mission_id == 25 and String(entry["id"]) == "coracao_mare":
		health *= float(ENDING_BOSS_MODIFIERS.get(ending_choice, 1.0))
		if bool(story_flags.get("vorraz_trusted", false)):
			health *= 0.9
		elif story_flags.has("vorraz_trusted"):
			health *= 1.1
		if bool(story_flags.get("ramiro_trusted", false)):
			health *= 0.9
	if endless_mode:
		health *= 1.0 + float(endless_completed_waves + 1) * 0.22
	health *= 1.0 + crystal_corruption
	var route_id := 0
	if path_routes.size() > 1 and spawn_remaining % 2 == 0:
		route_id = 1
	(
		enemies
		. append(
			{
				"id": String(entry["id"]),
				"distance": 0.0,
				"health": health,
				"max_health": health,
				"route": route_id,
				"burning": 0.0,
				"burn_clock": 0.5,
				"ability_clock": 1.5,
				"boss": bool(entry["boss"]),
				"hit_flash": 0.0,
				"animation_time": randf() * TAU,
			}
		)
	)
	var enemy_position := _enemy_position(0.0, route_id)
	if bool(entry["boss"]):
		effects.spawn_burst(enemy_position, Color("#f0c46c"), 54, 280.0)
		_screen_shake(10.0)
		effects.play_sfx("boss")
		_request_message(
			(
				(
					"%s arrived on the battlefield!"
					% Localization.enemy_name(String(entry["id"]), english, String(spec["name"]))
				)
				if english
				else "%s chegou ao campo de batalha!" % String(spec["name"])
			)
		)
	else:
		effects.spawn_burst(enemy_position, Color("#8cb6bf"), 9, 70.0)
	if _has_prism_tower():
		crystal_corruption = minf(0.55, crystal_corruption + 0.025)


func _update_towers(delta: float) -> void:
	for tower_index in range(towers.size()):
		var tower: Dictionary = towers[tower_index]
		tower["cooldown"] = maxf(0.0, float(tower["cooldown"]) - delta)
		tower["disabled"] = maxf(0.0, float(tower["disabled"]) - delta)
		if float(tower["disabled"]) > 0.0:
			continue
		var spec: Dictionary = Campaign.tower_by_id(String(tower["id"]))
		if String(spec["role"]) == "repair":
			_repair_nearest_tower(tower, spec)
			continue
		if String(spec["role"]) == "wall":
			_defend_with_wall(tower, delta)
			continue
		if float(tower["cooldown"]) > 0.0:
			continue
		var target_index := _find_target(tower, spec)
		if target_index < 0:
			continue
		var target: Dictionary = enemies[target_index]
		var target_position := _enemy_position(float(target["distance"]), int(target["route"]))
		var material: Dictionary = _material_spec(String(tower["material"]))
		var level_multiplier := 1.0 + float(int(tower["level"]) - 1) * 0.45
		var damage := float(spec["damage"]) * float(material["power"]) * level_multiplier
		damage *= _synergy_multiplier(tower, spec, target)
		var damage_type := String(spec.get("damage_type", "physical"))
		tower["recoil"] = 1.0
		effects.add_projectile(
			_cell_center(tower["cell"]),
			target_position,
			TOWER_COLORS.get(String(tower["id"]), Color("#d9e7dc")),
			String(spec["role"])
		)
		if String(spec["role"]) in ["splash", "chain", "prism"]:
			_screen_shake(3.2 if String(spec["role"]) != "prism" else 5.0)
		effects.play_sfx("shot")
		if String(spec["role"]) == "burn":
			target["burning"] = maxf(float(target["burning"]), damage * 0.45)
			_apply_damage(target, damage, damage_type, float(material["armor_piercing"]))
			if float(target["health"]) <= 0.0:
				_kill_enemy(target_index)
		elif String(spec["role"]) == "splash":
			_damage_area(
				target_position,
				damage,
				TILE_SIZE * 0.58,
				float(material["armor_piercing"]),
				damage_type
			)
		elif String(spec["role"]) == "chain":
			_damage_area(
				target_position, damage, 12.0, float(material["armor_piercing"]), damage_type
			)
			var extra_targets := 0
			for enemy_index in range(enemies.size()):
				if extra_targets >= 2:
					break
				var other: Dictionary = enemies[enemy_index]
				var other_position := _enemy_position(float(other["distance"]), int(other["route"]))
				if other_position.distance_to(target_position) <= TILE_SIZE * 1.25:
					_apply_damage(
						other, damage * 0.65, damage_type, float(material["armor_piercing"])
					)
					extra_targets += 1
			_remove_defeated_enemies()
		else:
			_apply_damage(target, damage, damage_type, float(material["armor_piercing"]))
			if float(target["health"]) <= 0.0:
				_kill_enemy(target_index)
		tower["cooldown"] = float(spec["cooldown"]) / float(material["fire_rate"])
		tower["cooldown"] /= 1.0 + float(int(tower["level"]) - 1) * 0.12
		if storm_active:
			tower["cooldown"] = float(tower["cooldown"]) * 1.15


func _enemy_disables_tower(enemy: Dictionary, spec: Dictionary, delta: float) -> void:
	if String(spec["ability"]) != "disable":
		return
	enemy["ability_clock"] = float(enemy["ability_clock"]) - delta
	if float(enemy["ability_clock"]) > 0.0:
		return
	var enemy_position := _enemy_position(float(enemy["distance"]), int(enemy["route"]))
	var best_index := -1
	var best_distance := TILE_SIZE * 1.35
	for index in range(towers.size()):
		var tower_position := _cell_center(towers[index]["cell"])
		var distance := enemy_position.distance_to(tower_position)
		if distance < best_distance and float(towers[index]["disabled"]) <= 0.0:
			best_index = index
			best_distance = distance
	if best_index >= 0:
		towers[best_index]["disabled"] = 2.8
		enemy["ability_clock"] = 4.5
		_request_message(
			(
				"The Demolition Octopus disabled a structure for a few seconds!"
				if english
				else "Polvo-Sapador desativou uma construção por alguns segundos!"
			)
		)
	else:
		enemy["ability_clock"] = 0.8


func _find_target(tower: Dictionary, spec: Dictionary) -> int:
	return CombatRules.find_target(self, tower, spec)


func _damage_area(
	center: Vector2, damage: float, radius: float, armor_piercing: float, damage_type: String
) -> void:
	for index in range(enemies.size() - 1, -1, -1):
		var enemy: Dictionary = enemies[index]
		var position := _enemy_position(float(enemy["distance"]), int(enemy["route"]))
		if position.distance_to(center) > radius:
			continue
		_apply_damage(enemy, damage, damage_type, armor_piercing)
		if float(enemy["health"]) <= 0.0:
			_kill_enemy(index)


func _apply_damage(
	enemy: Dictionary,
	damage: float,
	damage_type: String,
	armor_piercing: float,
	ignore_armor := false
) -> float:
	return CombatRules.apply_damage(enemy, damage, damage_type, armor_piercing, ignore_armor)


func _synergy_multiplier(tower: Dictionary, spec: Dictionary, target: Dictionary) -> float:
	return CombatRules.synergy_multiplier(self, tower, spec, target)


func _remove_defeated_enemies() -> void:
	for index in range(enemies.size() - 1, -1, -1):
		if float(enemies[index]["health"]) <= 0.0:
			_kill_enemy(index)


func _screen_shake(strength: float) -> void:
	shake_strength = maxf(shake_strength, strength)


func _kill_enemy(index: int) -> void:
	if index < 0 or index >= enemies.size():
		return
	var enemy: Dictionary = enemies[index]
	var spec: Dictionary = Campaign.ENEMIES[String(enemy["id"])]
	wood += int(spec["reward"])
	var position := _enemy_position(float(enemy["distance"]), int(enemy["route"]))
	var burst_count := 56 if bool(enemy["boss"]) else 22
	effects.spawn_burst(
		position,
		Color("#f2c56b") if bool(enemy["boss"]) else COLOR_ENEMY,
		burst_count,
		320.0 if bool(enemy["boss"]) else 185.0
	)
	if bool(enemy["boss"]):
		_screen_shake(12.0)
		effects.play_sfx("boss")
	else:
		effects.play_sfx("hit")
	if String(enemy["id"]) == "coracao_mare" and endless_mode:
		enemies.remove_at(index)
		return
	if String(enemy["id"]) == "caranguejo_sineiro":
		_request_message(
			(
				"The bell is silent. The Shells have lost their rhythm!"
				if english
				else "O sino silenciou. Os Cascos perderam o ritmo!"
			)
		)
	enemies.remove_at(index)


func _repair_nearest_tower(tower: Dictionary, spec: Dictionary) -> void:
	if float(tower["cooldown"]) > 0.0:
		return
	var center := _cell_center(tower["cell"])
	var best_index := -1
	var best_distance := INF
	for index in range(towers.size()):
		if towers[index] == tower:
			continue
		var distance := center.distance_to(_cell_center(towers[index]["cell"]))
		if (
			distance <= float(spec["range"]) * TILE_SIZE
			and distance < best_distance
			and float(towers[index]["health"]) < float(towers[index]["max_health"])
		):
			best_index = index
			best_distance = distance
	if best_index >= 0:
		towers[best_index]["health"] = minf(
			float(towers[best_index]["max_health"]), float(towers[best_index]["health"]) + 14.0
		)
	tower["cooldown"] = float(spec["cooldown"])


func _defend_with_wall(tower: Dictionary, delta: float) -> void:
	if float(tower["health"]) <= 0.0:
		return
	var center := _cell_center(tower["cell"])
	for enemy in enemies:
		var enemy_position := _enemy_position(float(enemy["distance"]), int(enemy["route"]))
		if center.distance_to(enemy_position) < TILE_SIZE * 1.1:
			tower["health"] = float(tower["health"]) - 9.0 * delta
			enemy["distance"] = maxf(0.0, float(enemy["distance"]) - 12.0 * delta)
			if float(tower["health"]) <= 0.0:
				tower["health"] = 0.0
				_request_message(
					(
						"A Shell destroyed one of your Walls."
						if english
						else "Uma muralha foi destruída por um Casco."
					)
				)
			break


func _has_prism_tower() -> bool:
	for tower in towers:
		if String(tower["id"]) == "prisma":
			return true
	return false


func _material_spec(material_id: String) -> Dictionary:
	for material in Campaign.MATERIALS:
		if String(material["id"]) == material_id:
			return material
	return Campaign.MATERIALS[0]


func _request_message(text: String) -> void:
	message_requested.emit(Localization.board_message(text, english))


func _cell_center(cell: Vector2i) -> Vector2:
	return (
		BOARD_ORIGIN + Vector2((float(cell.x) + 0.5) * TILE_SIZE, (float(cell.y) + 0.5) * TILE_SIZE)
	)


func _cell_at(position: Vector2) -> Vector2i:
	var local := position - BOARD_ORIGIN
	if local.x < 0.0 or local.y < 0.0:
		return Vector2i(-1, -1)
	var cell := Vector2i(floori(local.x / TILE_SIZE), floori(local.y / TILE_SIZE))
	if cell.x >= BOARD_COLUMNS or cell.y >= BOARD_ROWS:
		return Vector2i(-1, -1)
	return cell


func _enemy_position(distance: float, route_id: int) -> Vector2:
	var points: Array = path_routes[route_id]
	var remaining := distance
	for index in range(points.size() - 1):
		var start: Vector2 = points[index]
		var finish: Vector2 = points[index + 1]
		var segment_length := start.distance_to(finish)
		if remaining <= segment_length:
			return start.lerp(finish, remaining / segment_length)
		remaining -= segment_length
	return points.back()


func _draw() -> void:
	painter.draw_scene(self, self)
