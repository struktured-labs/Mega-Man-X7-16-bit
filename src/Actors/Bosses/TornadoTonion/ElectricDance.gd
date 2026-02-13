extends AttackAbility

export var electric_ball : PackedScene
var drops_done := 0
const max_drops := 3

func _Setup() -> void:
	turn_and_face_player()
	drops_done = 0
	play_animation("dance_prepare")

func _Update(delta) -> void:
	process_gravity(delta)

	if attack_stage == 0 and has_finished_last_animation():
		play_animation("dance_jump")
		set_vertical_speed(-jump_velocity)
		next_attack_stage()

	elif attack_stage == 1 and timer > 0.2 and get_vertical_speed() > 0:
		play_animation("dance_drop")
		spawn_electric_ball()
		drops_done += 1
		next_attack_stage()

	elif attack_stage == 2 and character.is_on_floor():
		play_animation("dance_land")
		next_attack_stage()

	elif attack_stage == 3 and has_finished_last_animation():
		if drops_done < max_drops:
			turn_and_face_player()
			play_animation("dance_jump")
			set_vertical_speed(-jump_velocity)
			go_to_attack_stage(1)
		else:
			play_animation("dance_end")
			next_attack_stage()

	elif attack_stage == 4 and has_finished_last_animation():
		EndAbility()

func spawn_electric_ball() -> void:
	if electric_ball:
		var ball = instantiate(electric_ball)
		ball.set_creator(self)
		ball.initialize(-character.get_facing_direction())
		ball.global_position = character.global_position
		ball.set_vertical_speed(100)
		ball.set_horizontal_speed(0)
