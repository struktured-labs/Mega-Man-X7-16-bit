extends AttackAbility

export (PackedScene) var projectile

func _Setup() -> void:
	._Setup()

func _Update(_delta) -> void:
	process_gravity(_delta)

	if attack_stage == 0:
		# Aim at player
		turn_and_face_player()
		play_animation_once("idle")
		next_attack_stage()

	elif attack_stage == 1 and timer > 0.4:
		# Fire beam projectile
		play_animation_once("idle")
		fire_beam()
		next_attack_stage()

	elif attack_stage == 2 and timer > 0.5:
		# Recovery
		play_animation_once("idle")
		EndAbility()

func fire_beam() -> void:
	var shot = instantiate_projectile(projectile)
	shot.global_position = character.global_position
	shot.global_position.x += 24 * character.get_facing_direction()
	shot.set_horizontal_speed(500 * character.get_facing_direction())
	shot.set_vertical_speed(0)

func _Interrupt() -> void:
	._Interrupt()
	kill_tweens(tween_list)
