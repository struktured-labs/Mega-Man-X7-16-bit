extends AttackAbility

var charge_speed := 420.0

func _Setup() -> void:
	._Setup()

func _Update(_delta) -> void:
	process_gravity(_delta)

	if attack_stage == 0:
		# Face player and crouch
		turn_and_face_player()
		play_animation_once("idle")
		next_attack_stage()

	elif attack_stage == 1 and timer > 0.4:
		# Charge at player with fire aura
		play_animation_once("idle")
		force_movement(charge_speed)
		next_attack_stage()

	elif attack_stage == 2:
		# Continue charging until wall hit or timer
		if is_colliding_with_wall() or timer > 0.6:
			# Skid stop
			decay_speed(1.0, 0.3)
			play_animation_once("idle")
			next_attack_stage()

	elif attack_stage == 3 and timer > 0.4:
		EndAbility()

func _Interrupt() -> void:
	._Interrupt()
	kill_tweens(tween_list)
