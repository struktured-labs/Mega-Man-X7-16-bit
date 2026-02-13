extends AttackAbility

# Fire homing missiles that track the player
export (PackedScene) var missile_projectile
export var missile_count := 2

func _Setup() -> void:
	turn_and_face_player()

func _Update(delta) -> void:
	process_gravity(delta)

	if attack_stage == 0:
		play_animation_once("missile_aim")
		next_attack_stage()

	elif attack_stage == 1 and has_finished_last_animation():
		play_animation_once("missile_fire")
		spawn_missiles()
		next_attack_stage()

	elif attack_stage == 2 and has_finished_last_animation():
		play_animation_once("missile_recover")
		next_attack_stage()

	elif attack_stage == 3 and timer > 0.4:
		play_animation_once("idle")
		EndAbility()

func spawn_missiles() -> void:
	if missile_projectile:
		for i in missile_count:
			var missile = instantiate(missile_projectile)
			missile.set_creator(self)
			missile.initialize(character.get_facing_direction())
			# Arc upward then track
			missile.set_horizontal_speed(80 * character.get_facing_direction())
			missile.set_vertical_speed(-200 - i * 80)
