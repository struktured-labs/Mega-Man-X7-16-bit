extends AttackAbility

export var big_rock : PackedScene
export var small_rock : PackedScene

func _Setup() -> void:
	turn_and_face_player()
	play_animation("throw_prepare")

func _Update(delta) -> void:
	process_gravity(delta)
	if attack_stage == 0 and has_finished_last_animation():
		play_animation("throw")
		spawn_big_rock()
		next_attack_stage()

	elif attack_stage == 1 and has_finished_last_animation():
		EndAbility()

func spawn_big_rock() -> void:
	if big_rock:
		var rock = instantiate(big_rock)
		rock.set_creator(self)
		rock.initialize(character.get_facing_direction())
		rock.set_horizontal_speed(180.0 * character.get_facing_direction())
		rock.set_vertical_speed(-120.0)
		rock.connect("zero_health", self, "_on_big_rock_destroyed", [rock])
		rock.connect("projectile_end", self, "_on_big_rock_destroyed")

func _on_big_rock_destroyed(rock) -> void:
	if is_instance_valid(rock) and small_rock:
		var angles := [-0.5, 0.0, 0.5]
		for angle in angles:
			var sr = instantiate(small_rock)
			sr.set_creator(self)
			sr.initialize(character.get_facing_direction())
			sr.global_position = rock.global_position
			sr.set_horizontal_speed(120.0 * character.get_facing_direction() + angle * 80.0)
			sr.set_vertical_speed(-200.0 + abs(angle) * 60.0)
