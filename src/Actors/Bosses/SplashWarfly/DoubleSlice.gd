extends AttackAbility

var slice_speed := 380.0

func _Setup() -> void:
	._Setup()

func _Update(_delta) -> void:
	process_gravity(_delta)

	if attack_stage == 0:
		# Slash 1 toward player
		turn_and_face_player()
		play_animation_once("idle")
		force_movement(slice_speed)
		set_vertical_speed(-100)
		next_attack_stage()

	elif attack_stage == 1 and timer > 0.35:
		# Reposition - tween to offset position
		decay_speed(1.0, 0.2)
		var offset_x = -60 * character.get_facing_direction()
		var tween = new_tween()
		tween.tween_property(character, "global_position:x", character.global_position.x + offset_x, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
		play_animation_once("idle")
		next_attack_stage()

	elif attack_stage == 2 and timer > 0.4:
		# Slash 2
		turn_and_face_player()
		play_animation_once("idle")
		force_movement(slice_speed * 1.2)
		set_vertical_speed(80)
		next_attack_stage()

	elif attack_stage == 3 and timer > 0.4:
		# Recovery
		decay_speed(1.0, 0.3)
		play_animation_once("idle")
		next_attack_stage()

	elif attack_stage == 4 and timer > 0.3:
		EndAbility()

func _Interrupt() -> void:
	._Interrupt()
	kill_tweens(tween_list)
