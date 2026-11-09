extends Node2D

var reduced_motion := false
var sound_enabled := true
var sound_volume := 0.65
var shake_offset := Vector2.ZERO
var projectiles: Array[Dictionary] = []
var particles: Array[Dictionary] = []
var sound_player: AudioStreamPlayer


func _ready() -> void:
	sound_player = AudioStreamPlayer.new()
	add_child(sound_player)


func clear() -> void:
	projectiles.clear()
	particles.clear()
	queue_redraw()


func set_shake_offset(offset: Vector2) -> void:
	shake_offset = offset


func add_projectile(start: Vector2, finish: Vector2, color: Color, role: String) -> void:
	var duration := 0.28 if role in ["splash", "prism"] else 0.18
	if reduced_motion:
		duration *= 0.65
	(
		projectiles
		. append(
			{
				"start": start,
				"finish": finish,
				"progress": 0.0,
				"duration": duration,
				"color": color,
				"role": role,
			}
		)
	)
	spawn_burst(start, color, 5, 65.0)
	spawn_burst(finish, color, 8, 110.0)
	queue_redraw()


func spawn_burst(position: Vector2, color: Color, count: int, force: float) -> void:
	if reduced_motion:
		count = maxi(4, count / 3)
	var actual_count := mini(count, maxi(0, 260 - particles.size()))
	for _index in range(actual_count):
		var angle := randf_range(0.0, TAU)
		var speed := randf_range(force * 0.25, force)
		var life := randf_range(0.22, 0.72)
		(
			particles
			. append(
				{
					"position": position,
					"velocity": Vector2.RIGHT.rotated(angle) * speed,
					"life": life,
					"max_life": life,
					"color": color,
					"size": randf_range(2.0, 6.5),
					"rotation": angle,
					"spin": randf_range(-10.0, 10.0),
				}
			)
		)
	queue_redraw()


func play_sfx(kind: String) -> void:
	if not sound_enabled or sound_volume <= 0.0 or not is_instance_valid(sound_player):
		return
	var tones: Dictionary = {
		"build": [520.0, 920.0, 0.12],
		"shot": [180.0, 100.0, 0.07],
		"hit": [330.0, 85.0, 0.12],
		"boss": [90.0, 38.0, 0.48],
	}
	var tone: Array = tones.get(kind, tones["hit"])
	sound_player.stop()
	sound_player.stream = _make_tone(float(tone[0]), float(tone[1]), float(tone[2]))
	sound_player.volume_db = linear_to_db(sound_volume)
	sound_player.play()


func _process(delta: float) -> void:
	for index in range(projectiles.size() - 1, -1, -1):
		var projectile: Dictionary = projectiles[index]
		projectile["progress"] = (
			float(projectile["progress"]) + delta / float(projectile["duration"])
		)
		if float(projectile["progress"]) >= 1.0:
			projectiles.remove_at(index)
	for index in range(particles.size() - 1, -1, -1):
		var particle: Dictionary = particles[index]
		particle["life"] = float(particle["life"]) - delta
		particle["velocity"] = Vector2(particle["velocity"]) + Vector2(0.0, 68.0 * delta)
		particle["position"] = Vector2(particle["position"]) + Vector2(particle["velocity"]) * delta
		particle["rotation"] = float(particle["rotation"]) + float(particle["spin"]) * delta
		if float(particle["life"]) <= 0.0:
			particles.remove_at(index)
	if not projectiles.is_empty() or not particles.is_empty():
		queue_redraw()


func _make_tone(start_frequency: float, end_frequency: float, duration: float) -> AudioStreamWAV:
	var sample_rate := 11025
	var sample_count := int(sample_rate * duration)
	var samples := PackedByteArray()
	samples.resize(sample_count * 2)
	for index in range(sample_count):
		var progress := float(index) / float(sample_count)
		var envelope := pow(1.0 - progress, 2.0)
		var frequency := lerpf(start_frequency, end_frequency, progress)
		var sample := int(
			sin(TAU * frequency * float(index) / float(sample_rate)) * envelope * 16000.0
		)
		samples.encode_s16(index * 2, sample)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = samples
	return stream


func _draw() -> void:
	draw_set_transform(shake_offset, 0.0, Vector2.ONE)
	for projectile in projectiles:
		var progress := clampf(float(projectile["progress"]), 0.0, 1.0)
		var start: Vector2 = projectile["start"]
		var finish: Vector2 = projectile["finish"]
		var position := start.lerp(finish, progress)
		var color: Color = projectile["color"]
		var tail := start.lerp(position, 0.72)
		draw_line(tail, position, color.lightened(0.4), 5.0 if not reduced_motion else 2.0, true)
		draw_circle(position, 6.0 if not reduced_motion else 3.0, color.lightened(0.65))
		if String(projectile["role"]) == "chain":
			draw_line(position, finish, color, 3.0, true)
	for particle in particles:
		var alpha := clampf(float(particle["life"]) / float(particle["max_life"]), 0.0, 1.0)
		var color: Color = particle["color"]
		color.a *= alpha
		var size := float(particle["size"]) * (0.45 + alpha * 0.75)
		draw_set_transform(
			shake_offset + Vector2(particle["position"]), float(particle["rotation"]), Vector2.ONE
		)
		draw_rect(Rect2(Vector2(-size * 0.5, -size * 0.5), Vector2(size, size)), color, true)
		draw_set_transform(shake_offset, 0.0, Vector2.ONE)
