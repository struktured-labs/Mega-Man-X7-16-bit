extends GenericIntro

func prepare_for_intro() -> void:
	Log("Preparing for Intro")
	animatedSprite.visible = true
	play_animation("idle")

func _Update(_delta) -> void:
	process_gravity(_delta)

	if attack_stage == 0:
		# Hyenard jumps in from side
		turn_and_face_player()
		set_vertical_speed(-jump_velocity)
		force_movement(200)
		play_animation_once("idle")
		next_attack_stage()

	elif attack_stage == 1:
		if timer > 0.25 and character.is_on_floor():
			play_animation_once("idle")
			turn_player_towards_boss()
			turn_and_face_player()
			force_movement(-80)
			decay_speed(1, 0.35)
			screenshake(0.9)
			next_attack_stage()

	elif attack_stage == 2 and timer > 0.4:
		play_animation_once("idle")
		start_dialog_or_go_to_attack_stage(4)

	elif attack_stage == 3:
		if seen_dialog():
			next_attack_stage()

	elif attack_stage == 4:
		Event.emit_signal("play_boss_music")
		Event.emit_signal("boss_health_appear", character)
		play_animation_once("idle")
		next_attack_stage()

	elif attack_stage == 5 and timer > 0.5:
		play_animation_once("idle")
		EndAbility()
