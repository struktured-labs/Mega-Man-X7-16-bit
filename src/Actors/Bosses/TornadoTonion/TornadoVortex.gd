extends AttackAbility

export var tornado_projectile : PackedScene

func _Setup() -> void:
	turn_and_face_player()
	play_animation("tornado_prepare")

func _Update(delta) -> void:
	process_gravity(delta)
	if attack_stage == 0 and has_finished_last_animation():
		play_animation("tornado_cast")
		spawn_tornado()
		next_attack_stage()

	elif attack_stage == 1 and has_finished_last_animation():
		EndAbility()

func spawn_tornado() -> void:
	if tornado_projectile:
		var t = instantiate(tornado_projectile)
		t.set_creator(self)
		t.initialize(character.get_facing_direction())
		t.global_position.x += 24 * character.get_facing_direction()
