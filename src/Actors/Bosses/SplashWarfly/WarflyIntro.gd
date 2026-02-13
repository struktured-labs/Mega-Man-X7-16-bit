extends GenericIntro

func prepare_for_intro() -> void:
	Log("Preparing for Intro")
	make_invisible()

func _Update(_delta) -> void:
	if attack_stage == 0:
		# Fly in from above
		character.global_position.y -= 120
		play_animation("idle")
		turn_and_face_player()
		make_visible()
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(character, "global_position:y", character.global_position.y + 120, 1.0)
		tween_list.append(tween)
		next_attack_stage()

	elif attack_stage == 1 and timer > 1:
		turn_player_towards_boss()
		play_animation_once("idle")
		start_dialog_or_go_to_attack_stage(3)

	elif attack_stage == 2:
		if seen_dialog():
			next_attack_stage()

	elif attack_stage == 3:
		Event.emit_signal("play_boss_music")
		Event.emit_signal("boss_health_appear", character)
		play_animation_once("idle")
		next_attack_stage()

	elif attack_stage == 4 and timer > 1.0:
		play_animation("idle")
		EndAbility()
