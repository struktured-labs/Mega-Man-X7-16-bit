extends AttackAbility

onready var charge_sfx: AudioStreamPlayer2D = $charge_sfx
onready var impact_sfx: AudioStreamPlayer2D = $impact_sfx

func _Setup() -> void:
	._Setup()

func _Update(delta) -> void:
	process_gravity(delta)

	if attack_stage == 0 and has_finished_last_animation():
		play_animation_once("ride_windup")
		charge_sfx.play()
		next_attack_stage_on_next_frame()

	elif attack_stage == 1 and has_finished_last_animation():
		play_animation_once("ride_charge")
		force_movement(get_horizontal_velocity())
		next_attack_stage_on_next_frame()

	elif attack_stage == 2:
		if timer > 0.75 or is_colliding_with_wall():
			impact_sfx.play()
			screenshake(2.0)
			play_animation_once("ride_impact")
			decay_speed(0.5, 0.35)
			next_attack_stage_on_next_frame()

	elif attack_stage == 3 and has_finished_last_animation():
		turn_and_face_player()
		play_animation_once("ride_idle")
		next_attack_stage_on_next_frame()

	elif attack_stage == 4 and timer > 0.3:
		EndAbility()

func _Interrupt() -> void:
	._Interrupt()
