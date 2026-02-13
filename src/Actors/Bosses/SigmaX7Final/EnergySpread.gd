extends AttackAbility

# Projectile spread - fires 8 energy balls in spread pattern
export var projectile : PackedScene
onready var shot_sfx: AudioStreamPlayer2D = $shot_sfx
onready var charge_sfx: AudioStreamPlayer2D = $charge_sfx
onready var shot_pos: Position2D = $"../animatedSprite/shot_pos"

func _Setup() -> void:
	turn_and_face_player()
	play_animation("blast_prepare")
	charge_sfx.play()

func _Update(_delta) -> void:
	if attack_stage == 0 and has_finished_last_animation():
		play_animation("blast_prepare_loop")
		next_attack_stage()

	elif attack_stage == 1 and timer > 0.8:
		play_animation("blast")
		shot_sfx.play_rp()
		screenshake()
		fire_spread()
		next_attack_stage()

	elif attack_stage == 2 and has_finished_last_animation():
		play_animation("blast_end")
		charge_sfx.stop()
		next_attack_stage()

	elif attack_stage == 3 and has_finished_last_animation():
		EndAbility()

func fire_spread() -> void:
	var dir = character.get_facing_direction()
	var angles = [-60, -40, -20, -5, 5, 20, 40, 60]
	for angle in angles:
		var bullet = instantiate(projectile)
		bullet.set_creator(self)
		bullet.initialize(dir)
		bullet.global_position = shot_pos.global_position
		var rad = deg2rad(angle)
		bullet.set_horizontal_speed(200 * dir * cos(rad))
		bullet.set_vertical_speed(200 * sin(rad))
