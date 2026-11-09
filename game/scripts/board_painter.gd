extends RefCounted

const Campaign = preload("res://scripts/campaign_data.gd")
const BOARD_ORIGIN := Vector2(140.0, 134.0)
const TILE_SIZE := 72
const BOARD_COLUMNS := 10
const BOARD_ROWS := 7
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


func draw_scene(canvas: CanvasItem, board: Variant) -> void:
	if board.phase == "inactive":
		return
	canvas.draw_set_transform(board.shake_offset, 0.0, Vector2.ONE)
	var chapter := int(Campaign.mission_at(board.mission_id - 1)["chapter"])
	var chapter_colors: Dictionary = CHAPTER_COLORS[chapter].duplicate()
	if board.high_contrast:
		chapter_colors["water"] = Color("#101820")
		chapter_colors["path"] = Color("#a39b6b")
	var path_edge := Color("#fff4a8") if board.high_contrast else COLOR_PATH_EDGE
	canvas.draw_rect(
		Rect2(BOARD_ORIGIN, Vector2(BOARD_COLUMNS * TILE_SIZE, BOARD_ROWS * TILE_SIZE)),
		chapter_colors["water"],
		true
	)
	for cell in board.path_cells:
		var tile_rect := Rect2(
			BOARD_ORIGIN + Vector2(cell.x * TILE_SIZE, cell.y * TILE_SIZE),
			Vector2(TILE_SIZE, TILE_SIZE)
		)
		canvas.draw_rect(tile_rect, chapter_colors["path"], true)
		canvas.draw_rect(tile_rect, path_edge, false, 2.0 if board.high_contrast else 1.0)
	var grid_color := (
		Color(0.88, 0.96, 1.0, 0.65) if board.high_contrast else Color(0.48, 0.62, 0.63, 0.35)
	)
	for column in range(BOARD_COLUMNS + 1):
		var x := BOARD_ORIGIN.x + column * TILE_SIZE
		canvas.draw_line(
			Vector2(x, BOARD_ORIGIN.y),
			Vector2(x, BOARD_ORIGIN.y + BOARD_ROWS * TILE_SIZE),
			grid_color,
			1.0
		)
	for row in range(BOARD_ROWS + 1):
		var y := BOARD_ORIGIN.y + row * TILE_SIZE
		canvas.draw_line(
			Vector2(BOARD_ORIGIN.x, y),
			Vector2(BOARD_ORIGIN.x + BOARD_COLUMNS * TILE_SIZE, y),
			grid_color,
			1.0
		)
	if (
		board.build_mode
		and board.hovered_cell.x >= 0
		and not board.path_cells.has(board.hovered_cell)
	):
		var spec: Dictionary = Campaign.tower_by_id(board.selected_tower_id)
		canvas.draw_circle(
			_cell_center(board.hovered_cell),
			float(spec["range"]) * TILE_SIZE,
			Color(0.65, 0.78, 0.46, 0.12)
		)
		canvas.draw_rect(
			Rect2(
				(
					BOARD_ORIGIN
					+ Vector2(board.hovered_cell.x * TILE_SIZE, board.hovered_cell.y * TILE_SIZE)
				),
				Vector2(TILE_SIZE, TILE_SIZE)
			),
			Color(0.72, 0.83, 0.58, 0.2),
			true
		)
	for index in range(board.towers.size()):
		var tower: Dictionary = board.towers[index]
		var center := _cell_center(tower["cell"])
		if index == board.selected_tower_index:
			canvas.draw_circle(center, 26.0, Color(0.8, 0.9, 0.62, 0.16))
		_draw_tower(canvas, board, tower, center)
	for enemy in board.enemies:
		_draw_enemy(canvas, board, enemy)
	canvas.draw_rect(
		Rect2(BOARD_ORIGIN, Vector2(BOARD_COLUMNS * TILE_SIZE, BOARD_ROWS * TILE_SIZE)),
		COLOR_PANEL_EDGE,
		false,
		2.0
	)
	canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_tower(canvas: CanvasItem, board: Variant, tower: Dictionary, center: Vector2) -> void:
	var tower_id := String(tower["id"])
	var color: Color = TOWER_COLORS.get(tower_id, Color("#b17a43"))
	var material_color: Color = MATERIAL_COLORS.get(String(tower["material"]), color)
	var build_age := float(tower.get("build_age", 1.0))
	var build_scale := lerpf(0.55, 1.0, 1.0 - exp(-build_age * 8.0))
	var recoil := float(tower.get("recoil", 0.0))
	var recoil_offset := Vector2(-recoil * 5.0, recoil * 2.0)
	canvas.draw_set_transform(
		board.shake_offset + center + recoil_offset,
		sin(board.visual_time * 2.2 + center.x) * 0.025,
		Vector2.ONE * build_scale
	)
	var radius_scale := 1.0 + sin(board.visual_time * 4.0 + center.y) * 0.035
	canvas.draw_circle(Vector2(0.0, 5.0), 23.0 * radius_scale, COLOR_TOWER_DARK)
	if tower_id == "muralha":
		canvas.draw_rect(Rect2(Vector2(-22.0, -20.0), Vector2(44.0, 40.0)), material_color, true)
		canvas.draw_line(Vector2(-22.0, -5.0), Vector2(22.0, -5.0), COLOR_TOWER_DARK, 3.0)
	elif tower_id == "piche":
		canvas.draw_circle(Vector2.ZERO, 20.0, color)
		canvas.draw_circle(Vector2.ZERO, 10.0, material_color)
	elif tower_id in ["canhao", "morteiro"]:
		canvas.draw_circle(Vector2.ZERO, 19.0, material_color)
		canvas.draw_line(Vector2.ZERO, Vector2(18.0, -12.0), COLOR_TOWER_DARK, 8.0)
	elif tower_id == "farol_aa":
		canvas.draw_circle(Vector2.ZERO, 18.0, material_color)
		canvas.draw_colored_polygon(
			PackedVector2Array(
				[Vector2(0.0, -28.0), Vector2(17.0, 0.0), Vector2(0.0, 28.0), Vector2(-17.0, 0.0)]
			),
			color
		)
		canvas.draw_circle(
			Vector2.ZERO, 5.0 + absf(sin(board.visual_time * 5.0)) * 3.0, Color("#effcff")
		)
	elif tower_id == "bobina":
		canvas.draw_colored_polygon(
			PackedVector2Array(
				[Vector2(0.0, -23.0), Vector2(19.0, 0.0), Vector2(0.0, 23.0), Vector2(-19.0, 0.0)]
			),
			color
		)
	elif tower_id == "reparo":
		canvas.draw_circle(Vector2.ZERO, 20.0, color)
		canvas.draw_rect(Rect2(Vector2(-4.0, -13.0), Vector2(8.0, 26.0)), Color("#f2e7ca"), true)
		canvas.draw_rect(Rect2(Vector2(-13.0, -4.0), Vector2(26.0, 8.0)), Color("#f2e7ca"), true)
	elif tower_id == "prisma":
		canvas.draw_colored_polygon(
			PackedVector2Array([Vector2(0.0, -23.0), Vector2(20.0, 17.0), Vector2(-20.0, 17.0)]),
			color
		)
	else:
		canvas.draw_rect(Rect2(Vector2(-14.0, -17.0), Vector2(28.0, 34.0)), material_color, true)
		canvas.draw_rect(Rect2(Vector2(-5.0, -25.0), Vector2(10.0, 25.0)), COLOR_TOWER_DARK, true)
		canvas.draw_circle(Vector2(0.0, -17.0), 8.0, color)
	for level_index in range(int(tower["level"])):
		canvas.draw_circle(Vector2(-7.0 + level_index * 7.0, 20.0), 2.0, Color("#f2e7ca"))
	canvas.draw_set_transform(board.shake_offset, 0.0, Vector2.ONE)


func _draw_enemy(canvas: CanvasItem, board: Variant, enemy: Dictionary) -> void:
	var spec: Dictionary = Campaign.ENEMIES[String(enemy["id"])]
	var center: Vector2 = board._enemy_position(float(enemy["distance"]), int(enemy["route"]))
	var is_boss := bool(enemy["boss"])
	var radius := 19.0 if is_boss else 13.0
	var bob := (
		sin(float(enemy.get("animation_time", 0.0)) * 8.0)
		* (4.0 if not board.reduced_motion else 1.0)
	)
	center.y += bob - (11.0 if bool(spec["flying"]) else 0.0)
	var color := COLOR_ENEMY
	if is_boss:
		color = Color("#d49c55")
	elif bool(spec["flying"]):
		color = Color("#8ba9bd")
	elif String(spec["ability"]) == "disable":
		color = Color("#8e79a9")
	color = color.lerp(Color.WHITE, float(enemy.get("hit_flash", 0.0)) * 0.85)
	var squash := (
		1.0
		+ (
			sin(float(enemy.get("animation_time", 0.0)) * 12.0)
			* (0.1 if not board.reduced_motion else 0.025)
		)
	)
	canvas.draw_set_transform(board.shake_offset + center, 0.0, Vector2(squash, 2.0 - squash))
	canvas.draw_circle(Vector2.ZERO, radius + 4.0, COLOR_TOWER_DARK)
	canvas.draw_circle(Vector2.ZERO, radius, color)
	canvas.draw_circle(Vector2(-5.0, -2.0), 2.5, Color("#f2e7ca"))
	canvas.draw_circle(Vector2(5.0, -2.0), 2.5, Color("#f2e7ca"))
	canvas.draw_set_transform(board.shake_offset, 0.0, Vector2.ONE)
	var health_ratio := clampf(float(enemy["health"]) / float(enemy["max_health"]), 0.0, 1.0)
	var health_color := Color("#61ff7b") if board.high_contrast else COLOR_HEALTH
	canvas.draw_rect(
		Rect2(center + Vector2(-18.0, -27.0), Vector2(36.0, 4.0)), COLOR_TOWER_DARK, true
	)
	canvas.draw_rect(
		Rect2(center + Vector2(-18.0, -27.0), Vector2(36.0 * health_ratio, 4.0)), health_color, true
	)


func _cell_center(cell: Vector2i) -> Vector2:
	return (
		BOARD_ORIGIN + Vector2((float(cell.x) + 0.5) * TILE_SIZE, (float(cell.y) + 0.5) * TILE_SIZE)
	)
