extends GenericIntro

func _Setup() -> void:
	GameManager.start_cutscene()
	turn_and_face_player()

func _Update(delta) -> void:
	process_gravity(delta)
	if attack_stage == 0 and timer > 0.5:
		make_visible()
		turn_player_towards_boss()
		play_animation("land")
		next_attack_stage()

	elif attack_stage == 1 and has_finished_last_animation():
		play_animation("idle")
		start_dialog_or_go_to_attack_stage(3)

	elif attack_stage == 2:
		if seen_dialog():
			next_attack_stage()

	elif attack_stage == 3:
		Event.emit_signal("play_boss_music")
		play_animation("rage")
		next_attack_stage()

	elif attack_stage == 4 and timer > 0.75:
		Event.emit_signal("boss_health_appear", character)
		play_animation("ready")
		next_attack_stage()

	elif attack_stage == 5 and timer > 1.25:
		play_animation("idle")
		next_attack_stage()

	elif attack_stage == 6 and has_finished_last_animation():
		EndAbility()

func _Interrupt() -> void:
	Event.emit_signal("boss_start", character)
	GameManager.end_cutscene()
	character.emit_signal("intro_concluded")
