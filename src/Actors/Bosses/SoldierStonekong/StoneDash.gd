extends AttackAbility

export var shockwave_projectile : PackedScene
var dash_speed := 400.0

func _Setup() -> void:
	turn_and_face_player()
	play_animation("dash_prepare")

func _Update(delta) -> void:
	process_gravity(delta)
	if attack_stage == 0 and has_finished_last_animation():
		play_animation("dash")
		force_movement(dash_speed)
		next_attack_stage()

	elif attack_stage == 1:
		if is_colliding_with_wall() or timer > 0.8:
			force_movement(0)
			set_vertical_speed(-jump_velocity)
			play_animation("jump")
			next_attack_stage()

	elif attack_stage == 2 and timer > 0.1 and get_vertical_speed() > 0:
		play_animation("slam")
		next_attack_stage()

	elif attack_stage == 3 and character.is_on_floor():
		play_animation("slam_land")
		force_movement(0)
		screenshake(1.5)
		spawn_shockwaves()
		next_attack_stage()

	elif attack_stage == 4 and has_finished_last_animation():
		EndAbility()

func spawn_shockwaves() -> void:
	if shockwave_projectile:
		var left = instantiate(shockwave_projectile)
		left.set_creator(self)
		left.initialize(1)
		left.global_position.y = character.global_position.y + 20

		var right = instantiate(shockwave_projectile)
		right.set_creator(self)
		right.initialize(-1)
		right.global_position.y = character.global_position.y + 20
