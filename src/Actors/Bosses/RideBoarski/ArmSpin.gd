extends AttackAbility

# Walk toward player, close-range spinning arm attack
export var walk_speed := 150.0
export var spin_duration := 1.5
var spin_timer := 0.0

func _Setup() -> void:
	turn_and_face_player()
	spin_timer = 0.0

func _Update(delta) -> void:
	process_gravity(delta)

	if attack_stage == 0:
		play_animation("walk")
		force_movement(walk_speed)
		if is_player_nearby_horizontally(80) or timer > 2.0:
			next_attack_stage()

	elif attack_stage == 1:
		play_animation_once("arm_spin_start")
		force_movement(0)
		next_attack_stage()

	elif attack_stage == 2:
		if has_finished_last_animation():
			play_animation("arm_spin_loop")
		spin_timer += delta
		if spin_timer >= spin_duration:
			next_attack_stage()

	elif attack_stage == 3:
		play_animation_once("arm_spin_end")
		next_attack_stage()

	elif attack_stage == 4 and has_finished_last_animation():
		play_animation_once("idle")
		EndAbility()

func _Interrupt() -> void:
	._Interrupt()
	spin_timer = 0.0
