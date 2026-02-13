extends AttackAbility

# Jump slam creating ground shockwaves on landing
export (PackedScene) var shockwave_projectile

func _Setup() -> void:
	turn_and_face_player()

func _Update(delta) -> void:
	if attack_stage == 0:
		play_animation_once("jump_prepare")
		next_attack_stage()

	elif attack_stage == 1 and has_finished_last_animation():
		play_animation_once("jump")
		set_vertical_speed(-jump_velocity)
		force_movement(horizontal_velocity * get_player_direction_relative())
		next_attack_stage()

	elif attack_stage == 2:
		process_gravity(delta)
		if get_vertical_speed() > 0:
			play_animation_once("fall")
		if timer > 0.1 and character.is_on_floor():
			next_attack_stage()

	elif attack_stage == 3:
		play_animation_once("slam")
		force_movement(0)
		screenshake(2.0)
		spawn_shockwaves()
		next_attack_stage()

	elif attack_stage == 4 and has_finished_last_animation():
		play_animation_once("slam_recover")
		next_attack_stage()

	elif attack_stage == 5 and timer > 0.5:
		play_animation_once("idle")
		EndAbility()

func spawn_shockwaves() -> void:
	if shockwave_projectile:
		var wave_left = instantiate(shockwave_projectile)
		wave_left.set_creator(self)
		wave_left.initialize(-1)
		var wave_right = instantiate(shockwave_projectile)
		wave_right.set_creator(self)
		wave_right.initialize(1)
