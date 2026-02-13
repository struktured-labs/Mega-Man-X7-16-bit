extends AttackAbility

onready var damage_on_touch: Node2D = $"../DamageOnTouch"
onready var damage: Node2D = $"../Damage"
var spin_duration := 2.0

func _Setup() -> void:
	play_animation("spin_start")

func _Update(delta) -> void:
	process_gravity(delta)
	if attack_stage == 0 and has_finished_last_animation():
		play_animation("spin_loop")
		damage_on_touch.activate()
		character.add_invulnerability("spin_shield")
		damage.can_get_hit = false
		next_attack_stage()

	elif attack_stage == 1 and timer > spin_duration:
		character.remove_invulnerability("spin_shield")
		damage.can_get_hit = true
		damage_on_touch.deactivate()
		play_animation("spin_end")
		next_attack_stage()

	elif attack_stage == 2 and has_finished_last_animation():
		EndAbility()

func _Interrupt() -> void:
	character.remove_invulnerability("spin_shield")
	damage.can_get_hit = true
	damage_on_touch.deactivate()
	._Interrupt()
