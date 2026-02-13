extends GenericIntro

func prepare_for_intro() -> void:
	make_invisible()

func _Setup() -> void:
	._Setup()

func _Update(delta) -> void:
	process_gravity(delta)

	if attack_stage == 0:
		make_visible()
		play_animation_once("intro_charge")
		force_movement(horizontal_velocity)
		next_attack_stage()

	elif attack_stage == 1:
		if is_colliding_with_wall() or timer > 1.5:
			force_movement(0)
			screenshake(1.0)
			play_animation_once("intro_land")
			next_attack_stage()

	elif attack_stage == 2 and has_finished_last_animation():
		turn_and_face_player()
		turn_player_towards_boss()
		play_animation_once("intro_roar")
		next_attack_stage()

	elif attack_stage == 3:
		start_dialog_or_go_to_attack_stage(5)

	elif attack_stage == 4 and timer > 0.5:
		play_animation_once("idle")
		if dialog_concluded:
			next_attack_stage()

	elif attack_stage == 5:
		play_animation_once("idle")
		Event.emit_signal("play_boss_music")
		Event.emit_signal("boss_health_appear", character)
		next_attack_stage_on_next_frame()

	elif attack_stage == 6 and timer > 1.0:
		EndAbility()

func _Interrupt() -> void:
	Event.emit_signal("boss_start", character)
	GameManager.end_cutscene()
	character.emit_signal("intro_concluded")
