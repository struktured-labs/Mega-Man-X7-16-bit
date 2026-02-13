extends AttackAbility

# Multi-hit fire kick combo adapted from BurnRooster's FireCombo pattern
var impulse := 60.0

func _Setup() -> void:
	._Setup()

func _Update(delta) -> void:
	process_gravity(delta)

	if attack_stage == 0:
		# Initial approach
		tween_speed(relative_to_player_distance(impulse, 300), impulse / 6, 0.35)
		next_attack_stage()

	elif attack_stage == 1 and timer > 0.35:
		# Low kick
		play_animation_once("idle")
		force_movement(relative_to_player_distance(horizontal_velocity, 400))
		call_deferred("decay_speed", 1, 0.3)
		next_attack_stage()

	elif attack_stage == 2 and timer > 0.3:
		# Turn and high kick
		turn_and_face_player()
		play_animation_once("idle")
		force_movement(relative_to_player_distance(horizontal_velocity, 160))
		set_vertical_speed(-jump_velocity / 1.25)
		call_deferred("decay_speed", 1, 0.65)
		next_attack_stage()

	elif attack_stage == 3 and timer > 0.3:
		# Aerial kick
		play_animation_once("idle")
		next_attack_stage()

	elif attack_stage == 4 and character.is_on_floor():
		# Land
		play_animation_once("idle")
		next_attack_stage()

	elif attack_stage == 5 and timer > 0.3:
		EndAbility()

func relative_to_player_distance(speed, multiplier := 150.0) -> float:
	return speed * abs(get_distance_to_player() / multiplier)

func _Interrupt() -> void:
	._Interrupt()
	kill_tweens(tween_list)
