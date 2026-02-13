extends AttackAbility

var blade_speed := 350.0
onready var damage_on_touch: Node2D = $"../DamageOnTouch"

func _Setup() -> void:
	turn_and_face_player()
	play_animation("spin_prepare")

func _Update(delta) -> void:
	process_gravity(delta)
	if attack_stage == 0 and has_finished_last_animation():
		play_animation("spin_loop")
		force_movement(blade_speed)
		damage_on_touch.activate()
		next_attack_stage()

	elif attack_stage == 1:
		if is_colliding_with_wall() or timer > 1.0:
			decay_speed(1.0, 0.3)
			damage_on_touch.deactivate()
			play_animation("spin_end")
			next_attack_stage()

	elif attack_stage == 2 and has_finished_last_animation():
		force_movement(0)
		EndAbility()

func _Interrupt() -> void:
	damage_on_touch.deactivate()
	force_movement(0)
	._Interrupt()
