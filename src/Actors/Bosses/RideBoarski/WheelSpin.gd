extends AttackAbility

# Spawn wheel projectiles that roll along the ground
export (PackedScene) var wheel_projectile
export var wheel_count := 2

func _Setup() -> void:
	turn_and_face_player()

func _Update(delta) -> void:
	process_gravity(delta)

	if attack_stage == 0:
		play_animation_once("wheel_prepare")
		next_attack_stage()

	elif attack_stage == 1 and has_finished_last_animation():
		play_animation_once("wheel_throw")
		spawn_wheels()
		next_attack_stage()

	elif attack_stage == 2 and has_finished_last_animation():
		play_animation_once("idle")
		EndAbility()

func spawn_wheels() -> void:
	if wheel_projectile:
		for i in wheel_count:
			var wheel = instantiate(wheel_projectile)
			wheel.set_creator(self)
			wheel.initialize(character.get_facing_direction())
			wheel.set_horizontal_speed((200 + i * 60) * character.get_facing_direction())
