extends AttackAbility

# High-speed charge across arena, wall impact + shockwave
export var rush_speed := 500.0
export (PackedScene) var shockwave_projectile

func _Setup() -> void:
	turn_and_face_player()

func _Update(delta) -> void:
	process_gravity(delta)

	if attack_stage == 0:
		play_animation_once("rush_prepare")
		next_attack_stage()

	elif attack_stage == 1 and has_finished_last_animation():
		play_animation("rush_loop")
		force_movement(rush_speed)
		screenshake(0.5)
		next_attack_stage()

	elif attack_stage == 2:
		if is_colliding_with_wall() or timer > 1.5:
			force_movement(0)
			screenshake(1.5)
			play_animation_once("rush_impact")
			spawn_shockwaves()
			next_attack_stage()

	elif attack_stage == 3 and has_finished_last_animation():
		turn_and_face_player()
		play_animation_once("rush_recover")
		next_attack_stage()

	elif attack_stage == 4 and timer > 0.4:
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
