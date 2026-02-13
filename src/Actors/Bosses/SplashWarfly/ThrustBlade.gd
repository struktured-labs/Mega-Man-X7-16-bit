extends AttackAbility

var thrust_speed := 450.0

func _Setup() -> void:
	._Setup()

func _Update(_delta) -> void:
	process_gravity(_delta)

	if attack_stage == 0:
		# Face player and prepare
		turn_and_face_player()
		play_animation_once("idle")
		next_attack_stage()

	elif attack_stage == 1 and timer > 0.3:
		# Dash toward player
		play_animation_once("idle")
		force_movement(thrust_speed)
		var target_dir = Tools.get_player_angle(global_position)
		set_vertical_speed(thrust_speed * target_dir.y * 0.5)
		next_attack_stage()

	elif attack_stage == 2 and timer > 0.4:
		# Decelerate
		decay_speed(1.0, 0.3)
		decay_vertical_speed(0.3)
		play_animation_once("idle")
		next_attack_stage()

	elif attack_stage == 3 and timer > 0.35:
		EndAbility()

func _Interrupt() -> void:
	._Interrupt()
	kill_tweens(tween_list)
