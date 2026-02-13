extends AttackAbility

# DESPERATION - Death walls + teleport attacks, adapted from Lumine Darkness
export var death_walls : PackedScene
export var energy_projectile : PackedScene
export var music : AudioStream
onready var tween := TweenController.new(self, false)
onready var roar_sfx: AudioStreamPlayer2D = $roar_sfx
onready var shot_sfx: AudioStreamPlayer2D = $shot_sfx
var walls : Array
var projectile_timer := 0.0
const projectile_interval := 0.4

func _Setup():
	character.emit_signal("damage_reduction", 0.5)
	turn_and_face_player()
	walls = []
	projectile_timer = 0.0

func _Update(_delta) -> void:
	if attack_stage == 0:
		play_animation("scream_prepare")
		roar_sfx.play_rp()
		screenshake(2.0)
		next_attack_stage()

	elif attack_stage == 1 and timer > 1.5:
		play_animation("scream")
		if music:
			GameManager.music_player.start_fade_out()
			GameManager.music_player.play_song_wo_fadein(music)
		create_wall(1)
		create_wall(-1)
		next_attack_stage()

	elif attack_stage == 2 and has_finished_last_animation():
		play_animation("scream_loop")
		next_attack_stage()

	elif attack_stage == 3: # Rain energy projectiles
		projectile_timer += _delta
		if projectile_timer > projectile_interval:
			projectile_timer = 0.0
			spawn_energy_rain()

		if timer > 8.0:
			next_attack_stage()

	elif attack_stage == 4:
		play_animation("scream_end")
		for wall in walls:
			if is_instance_valid(wall):
				wall.deactivate()
		next_attack_stage()

	elif attack_stage == 5 and has_finished_last_animation():
		EndAbility()

func create_wall(scalex : int):
	if death_walls:
		var wall = death_walls.instance()
		var center = GameManager.camera.get_camera_screen_center()
		get_tree().current_scene.add_child(wall)
		wall.position = center
		wall.position.x += (210 * scalex)
		wall.scale.x = scalex
		wall.activate()
		walls.append(wall)

func spawn_energy_rain() -> void:
	if energy_projectile:
		var center = GameManager.camera.get_camera_screen_center()
		var x_offset = rand_range(-150, 150)
		var proj = instantiate(energy_projectile)
		proj.set_creator(self)
		proj.initialize(1)
		proj.global_position = Vector2(center.x + x_offset, center.y - 120)
		proj.set_horizontal_speed(rand_range(-30, 30))
		proj.set_vertical_speed(250)
		shot_sfx.play_rp()

func _Interrupt():
	._Interrupt()
	character.emit_signal("damage_reduction", 1)
	for wall in walls:
		if is_instance_valid(wall):
			wall.deactivate()
	tween.reset()
