extends AttackAbility

onready var jump_sfx: AudioStreamPlayer2D = $jump_sfx
onready var kick_sfx: AudioStreamPlayer2D = $kick_sfx
onready var land_sfx: AudioStreamPlayer2D = $land_sfx

func _Setup() -> void:
	._Setup()

func _Update(delta) -> void:
	if attack_stage == 0 and has_finished_last_animation():
		play_animation_once("crouch")
		next_attack_stage_on_next_frame()

	elif attack_stage == 1 and timer > 0.2:
		jump_sfx.play()
		play_animation_once("jump")
		set_vertical_speed(-get_jump_velocity())
		force_movement(get_horizontal_velocity() * get_player_direction_relative())
		next_attack_stage_on_next_frame()

	elif attack_stage == 2:
		process_gravity(delta)
		if character.get_vertical_speed() > 0:
			kick_sfx.play()
			play_animation_once("kick")
			next_attack_stage_on_next_frame()

	elif attack_stage == 3:
		process_gravity(delta)
		if character.is_on_floor():
			land_sfx.play()
			screenshake()
			play_animation_once("land")
			decay_speed(0.5, 0.35)
			next_attack_stage_on_next_frame()

	elif attack_stage == 4 and has_finished_last_animation():
		play_animation_once("idle")
		EndAbility()

func _Interrupt() -> void:
	._Interrupt()
