extends AttackAbility

# Dual sword slash combo - adapted from CopyDash
const travel_speed := 460.0
onready var highslash: Node2D = $highslash
onready var lowslash: Node2D = $lowslash
onready var dash_sfx: AudioStreamPlayer2D = $dash_sfx
onready var slash_sfx: AudioStreamPlayer2D = $slash_sfx

func _Setup() -> void:
	turn_and_face_player()

func _Update(_delta) -> void:
	process_gravity(_delta)

	if attack_stage == 0:
		play_animation("dash_prepare")
		slash_sfx.play_rp(0.03)
		next_attack_stage()

	elif attack_stage == 1 and has_finished_last_animation():
		play_animation("dash_prepare_loop")
		next_attack_stage()

	elif attack_stage == 2 and timer > 0.2:
		play_animation("dash_start")
		force_movement(travel_speed)
		dash_sfx.play_rp()
		next_attack_stage()

	elif attack_stage == 3:
		if get_distance_from_player() <= 64 or not is_player_in_front():
			next_attack_stage()
		elif has_finished_last_animation():
			play_animation_once("dash_start_loop")

	elif attack_stage == 4:
		play_animation("dash_slash_1")
		highslash.activate()
		slash_sfx.play_rp(0.03)
		decay_speed(0.5, 0.3)
		next_attack_stage()

	elif attack_stage == 5 and has_finished_last_animation():
		play_animation("dash_slash_1_loop")
		next_attack_stage()

	elif attack_stage == 6 and timer > 0.15:
		if not is_player_in_front():
			go_to_attack_stage(10)
		else:
			force_movement(travel_speed)
			play_animation("dash_start")
			dash_sfx.play_rp()
			next_attack_stage()

	elif attack_stage == 7:
		if get_distance_from_player() <= 64 or not is_player_in_front():
			next_attack_stage()
		elif has_finished_last_animation():
			play_animation_once("dash_start_loop")

	elif attack_stage == 8:
		play_animation("dash_slash_2")
		lowslash.activate()
		slash_sfx.play_rp(0.03)
		decay_speed(0.5, 0.3)
		next_attack_stage()

	elif attack_stage == 9 and has_finished_last_animation():
		play_animation("dash_slash_2_end")
		next_attack_stage()

	elif attack_stage == 10 and has_finished_last_animation():
		EndAbility()

func _Interrupt() -> void:
	._Interrupt()

func turn_and_face_player():
	.turn_and_face_player()
	highslash.handle_direction()
	lowslash.handle_direction()
