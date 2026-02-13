extends AttackAbility

export var shield_projectile : PackedScene

func _Setup() -> void:
	turn_and_face_player()
	play_animation("shield_prepare")

func _Update(delta) -> void:
	process_gravity(delta)
	if attack_stage == 0 and has_finished_last_animation():
		play_animation("shield_throw")
		spawn_shield()
		next_attack_stage()

	elif attack_stage == 1 and timer > 1.2:
		play_animation("shield_catch")
		next_attack_stage()

	elif attack_stage == 2 and has_finished_last_animation():
		EndAbility()

func spawn_shield() -> void:
	if shield_projectile:
		var s = instantiate(shield_projectile)
		s.set_creator(self)
		s.initialize(character.get_facing_direction())
		s.global_position.x += 16 * character.get_facing_direction()
