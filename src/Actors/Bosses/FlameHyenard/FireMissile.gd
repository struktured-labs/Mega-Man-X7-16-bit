extends AttackAbility

export (PackedScene) var projectile
var missiles_fired := 0
var total_missiles := 3

func _Setup() -> void:
	._Setup()
	missiles_fired = 0

func _Update(_delta) -> void:
	process_gravity(_delta)

	if attack_stage == 0:
		# Aim at player
		turn_and_face_player()
		play_animation_once("idle")
		next_attack_stage()

	elif attack_stage == 1 and timer > 0.3:
		# Fire missiles with delay
		if missiles_fired < total_missiles:
			fire_homing_missile()
			missiles_fired += 1
			if missiles_fired < total_missiles:
				go_to_attack_stage(1)
			else:
				next_attack_stage()
		else:
			next_attack_stage()

	elif attack_stage == 2 and timer > 0.5:
		# Recovery
		play_animation_once("idle")
		EndAbility()

func fire_homing_missile() -> void:
	var shot = instantiate_projectile(projectile)
	shot.global_position = character.global_position
	shot.global_position.x += 16 * character.get_facing_direction()
	shot.global_position.y -= 8
	var target_dir = Tools.get_player_angle(global_position)
	shot.set_horizontal_speed(170 * target_dir.x)
	shot.set_vertical_speed(170 * target_dir.y)

func _Interrupt() -> void:
	._Interrupt()
	kill_tweens(tween_list)
