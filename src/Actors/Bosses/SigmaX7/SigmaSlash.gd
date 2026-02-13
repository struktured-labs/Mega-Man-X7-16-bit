extends AttackAbility

# 3-hit saber combo - adapted from SatanSigma GroundCombo
onready var slash_1: Node2D = $slash1
onready var slash_2: Node2D = $slash2
onready var slash_3: Node2D = $slash3
onready var slash_sfx: AudioStreamPlayer2D = $slash_sfx

func _Setup() -> void:
	turn_and_face_player()

func _Update(delta) -> void:
	if attack_stage == 0 and has_finished_last_animation():
		play_animation("slash_1_prepare")
		next_attack_stage()

	elif attack_stage == 1 and has_finished_last_animation():
		play_animation("slash_1_prepare_loop")
		go_to_attack_stage(3)

	elif attack_stage == 3 and has_finished_last_animation():
		play_animation("slash_1")
		slash_sfx.play_rp()
		slash_1.activate()
		screenshake()
		tween_speed(220, 0, 0.35)
		next_attack_stage()

	elif attack_stage == 4 and has_finished_last_animation():
		play_animation("slash_1_loop")
		next_attack_stage()

	elif attack_stage == 5 and timer > 0.1:
		turn_and_face_player()
		play_animation("slash_2_prepare")
		tween_speed(220, 0, 0.35)
		next_attack_stage()

	elif attack_stage == 6 and has_finished_last_animation():
		play_animation("slash_2_prepare_loop")
		next_attack_stage()

	elif attack_stage == 7 and timer > 0.1:
		play_animation("slash_2")
		slash_sfx.play_rp()
		slash_2.activate()
		screenshake()
		tween_speed(100, 0, 0.5)
		next_attack_stage()

	elif attack_stage == 8 and has_finished_last_animation():
		play_animation("slash_2_loop")
		next_attack_stage()

	elif attack_stage == 9 and timer > 0.25:
		if is_player_in_front():
			play_animation("slash_3_prepare")
			tween_speed(20)
			next_attack_stage()
		else:
			play_animation("slash_2_end")
			go_to_attack_stage(13)

	elif attack_stage == 10 and has_finished_last_animation():
		play_animation("slash_3")
		slash_sfx.play_rp()
		slash_3.activate()
		screenshake()
		tween_speed(70)
		next_attack_stage()

	elif attack_stage == 11 and has_finished_last_animation():
		play_animation("slash_3_loop")
		next_attack_stage()

	elif attack_stage == 12 and timer > 0.3:
		play_animation("slash_3_end")
		next_attack_stage()

	elif attack_stage == 13 and has_finished_last_animation():
		EndAbility()

func turn_and_face_player():
	.turn_and_face_player()
	slash_1.handle_direction()
	slash_2.handle_direction()
	slash_3.handle_direction()
