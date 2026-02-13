extends AttackAbility

# DESPERATION: Continuous back-and-forth charges with fire trail
export var rampage_speed := 600.0
export (PackedScene) var shockwave_projectile
var charges_done := 0
var max_charges := 3
signal ready_for_stun

func _Setup() -> void:
	turn_and_face_player()
	charges_done = 0
	character.emit_signal("damage_reduction", 0.5)

func _Update(delta) -> void:
	process_gravity(delta)

	if attack_stage == 0:
		play_animation_once("rage_roar")
		screenshake(1.5)
		emit_signal("ready_for_stun")
		next_attack_stage()

	elif attack_stage == 1 and has_finished_last_animation():
		start_charge()

	elif attack_stage == 2:
		if is_colliding_with_wall() or timer > 1.2:
			force_movement(0)
			screenshake(1.0)
			charges_done += 1
			if charges_done >= max_charges:
				next_attack_stage()
			else:
				turn()
				go_to_attack_stage(1)

	elif attack_stage == 3:
		# Final charge with jump slam
		turn_and_face_player()
		play_animation_once("jump_prepare")
		next_attack_stage()

	elif attack_stage == 4 and has_finished_last_animation():
		play_animation_once("jump")
		set_vertical_speed(-jump_velocity * 1.2)
		force_movement(horizontal_velocity * get_player_direction_relative())
		next_attack_stage()

	elif attack_stage == 5:
		process_gravity(delta)
		if timer > 0.1 and character.is_on_floor():
			play_animation_once("slam")
			force_movement(0)
			screenshake(2.5)
			spawn_shockwaves()
			next_attack_stage()

	elif attack_stage == 6 and has_finished_last_animation():
		play_animation_once("slam_recover")
		next_attack_stage()

	elif attack_stage == 7 and timer > 0.6:
		play_animation_once("idle")
		EndAbility()

func start_charge() -> void:
	play_animation("rush_loop")
	force_movement(rampage_speed)
	next_attack_stage()

func spawn_shockwaves() -> void:
	if shockwave_projectile:
		var wave_left = instantiate(shockwave_projectile)
		wave_left.set_creator(self)
		wave_left.initialize(-1)
		var wave_right = instantiate(shockwave_projectile)
		wave_right.set_creator(self)
		wave_right.initialize(1)

func _Interrupt() -> void:
	._Interrupt()
	character.emit_signal("damage_reduction", 1.0)
