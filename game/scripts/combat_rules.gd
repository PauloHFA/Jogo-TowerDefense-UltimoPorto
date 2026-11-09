extends RefCounted

const Campaign = preload("res://scripts/campaign_data.gd")
const TILE_SIZE := 72


static func find_target(board: Variant, tower: Dictionary, spec: Dictionary) -> int:
	var tower_position: Vector2 = board._cell_center(tower["cell"])
	var material: Dictionary = board._material_spec(String(tower["material"]))
	var level_multiplier := 1.0 + float(int(tower["level"]) - 1) * 0.45
	var target_range := float(spec["range"]) * TILE_SIZE
	target_range *= float(material["range"]) * level_multiplier
	if String(spec["role"]) == "antiair":
		target_range += TILE_SIZE * 0.65
	if board.storm_active:
		target_range *= 0.78
	var target_index := -1
	var furthest_progress := -1.0
	for index in range(board.enemies.size()):
		var enemy: Dictionary = board.enemies[index]
		if (
			String(spec["role"]) == "antiair"
			and not bool(Campaign.ENEMIES[String(enemy["id"])]["flying"])
		):
			continue
		var enemy_position: Vector2 = board._enemy_position(
			float(enemy["distance"]), int(enemy["route"])
		)
		if (
			tower_position.distance_to(enemy_position) <= target_range
			and float(enemy["distance"]) > furthest_progress
		):
			target_index = index
			furthest_progress = float(enemy["distance"])
	return target_index


static func apply_damage(
	enemy: Dictionary,
	damage: float,
	damage_type: String,
	armor_piercing: float,
	ignore_armor := false
) -> float:
	var spec: Dictionary = Campaign.ENEMIES[String(enemy["id"])]
	var multiplier := float(spec.get("weaknesses", {}).get(damage_type, 1.0))
	multiplier *= float(spec.get("resistances", {}).get(damage_type, 1.0))
	var armor := 0.0
	if not ignore_armor:
		armor = maxf(0.0, float(spec["armor"]) - armor_piercing)
	var applied := damage * multiplier * (1.0 - armor)
	enemy["health"] = float(enemy["health"]) - applied
	enemy["hit_flash"] = 1.0
	return applied


static func enemy_speed(board: Variant, spec: Dictionary) -> float:
	var speed := float(spec["speed"])
	if board.storm_active:
		speed *= 0.78
	if board.mission_id == 5:
		for enemy in board.enemies:
			if String(enemy["id"]) == "caranguejo_sineiro":
				speed *= 1.15
				break
	return speed


static func synergy_multiplier(
	board: Variant, tower: Dictionary, spec: Dictionary, target: Dictionary
) -> float:
	var tower_id := String(tower["id"])
	var target_is_flying := bool(Campaign.ENEMIES[String(target["id"])]["flying"])
	if String(spec["role"]) == "antiair" and target_is_flying:
		return 1.2
	var center: Vector2 = board._cell_center(tower["cell"])
	for neighbor in board.towers:
		if neighbor == tower:
			continue
		var distance := center.distance_to(board._cell_center(neighbor["cell"]))
		if distance > TILE_SIZE * 1.65:
			continue
		var neighbor_id := String(neighbor["id"])
		if [tower_id, neighbor_id].has("piche") and [tower_id, neighbor_id].has("bobina"):
			return 1.2
		if [tower_id, neighbor_id].has("balista") and [tower_id, neighbor_id].has("muralha"):
			if not target_is_flying:
				return 1.18
		if [tower_id, neighbor_id].has("farol_aa") and [tower_id, neighbor_id].has("bobina"):
			if target_is_flying:
				return 1.25
	return 1.0
