extends AttackAbility

# Fires bouncing bullets - inspired by Cutman's boomerang bounce logic
export var projectile : PackedScene
onready var shot_sfx: AudioStreamPlayer2D = $shot_sfx
onready var charge_sfx: AudioStreamPlayer2D = $charge_sfx
onready var shot_pos: Position2D = $"../animatedSprite/shot_pos"

func _Setup() -> void:
	turn_and_face_player()
	play_animation("cannon_prepare")
	charge_sfx.play()

func _Update(_delta) -> void:
	process_gravity(_delta)

	if attack_stage == 0 and has_finished_last_animation():
		play_animation("cannon_prepare_loop")
		next_attack_stage()

	elif attack_stage == 1 and timer > 0.5:
		play_animation("cannon_start")
		fire_ricochet_bullet(0)
		shot_sfx.play_rp()
		screenshake(0.5)
		next_attack_stage()

	elif attack_stage == 2 and timer > 0.3:
		fire_ricochet_bullet(-15)
		shot_sfx.play_rp()
		next_attack_stage()

	elif attack_stage == 3 and timer > 0.3:
		fire_ricochet_bullet(15)
		shot_sfx.play_rp()
		next_attack_stage()

	elif attack_stage == 4 and has_finished_last_animation():
		play_animation("cannon_end")
		charge_sfx.stop()
		next_attack_stage()

	elif attack_stage == 5 and has_finished_last_animation():
		EndAbility()

func fire_ricochet_bullet(angle_offset : float) -> void:
	var bullet = instantiate(projectile)
	bullet.set_creator(self)
	bullet.initialize(character.get_facing_direction())
	bullet.global_position = shot_pos.global_position
	var dir = character.get_facing_direction()
	var base_angle = deg2rad(angle_offset)
	bullet.set_horizontal_speed(300 * dir * cos(base_angle))
	bullet.set_vertical_speed(300 * sin(base_angle))
