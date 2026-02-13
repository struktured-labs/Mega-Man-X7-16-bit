extends AttackAbility

onready var damage_on_touch: Node2D = $"../DamageOnTouch"

func _Setup() -> void:
	turn_and_face_player()
	play_animation("slash_prepare")

func _Update(delta) -> void:
	process_gravity(delta)
	if attack_stage == 0 and has_finished_last_animation():
		play_animation("slash")
		damage_on_touch.activate()
		next_attack_stage()

	elif attack_stage == 1 and timer > 0.2:
		damage_on_touch.deactivate()
		play_animation("slash_end")
		next_attack_stage()

	elif attack_stage == 2 and has_finished_last_animation():
		EndAbility()

func _Interrupt() -> void:
	damage_on_touch.deactivate()
	._Interrupt()
