extends AttackAbility

# Fire ant-shaped bombs that crawl along surfaces
export (PackedScene) var ant_bomb_projectile
export var bomb_count := 3

func _Setup() -> void:
	turn_and_face_player()

func _Update(delta) -> void:
	process_gravity(delta)

	if attack_stage == 0:
		play_animation_once("fire_prepare")
		next_attack_stage()

	elif attack_stage == 1 and has_finished_last_animation():
		play_animation_once("fire")
		spawn_ant_bombs()
		next_attack_stage()

	elif attack_stage == 2 and has_finished_last_animation():
		play_animation_once("fire_recover")
		next_attack_stage()

	elif attack_stage == 3 and timer > 0.3:
		play_animation_once("idle")
		EndAbility()

func spawn_ant_bombs() -> void:
	if ant_bomb_projectile:
		for i in bomb_count:
			var bomb = instantiate(ant_bomb_projectile)
			bomb.set_creator(self)
			bomb.initialize(character.get_facing_direction())
			# Slightly varied speeds for spread
			bomb.set_horizontal_speed((120 + i * 40) * character.get_facing_direction())
			bomb.set_vertical_speed(-80 - i * 20)
