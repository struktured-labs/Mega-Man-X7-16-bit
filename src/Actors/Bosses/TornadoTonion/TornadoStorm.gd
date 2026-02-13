extends AttackAbility

export var tornado_projectile : PackedScene
var storm_speed := 300.0
onready var damage_on_touch: Node2D = $"../DamageOnTouch"

signal ready_for_stun

func _Setup() -> void:
	play_animation("rage_prepare")
	character.emit_signal("damage_reduction", 0.5)

func _Update(delta) -> void:
	process_gravity(delta)
	if attack_stage == 0 and has_finished_last_animation():
		play_animation("rage_loop")
		screenshake(1.5)
		next_attack_stage()

	elif attack_stage == 1 and timer > 0.5:
		spawn_tornadoes()
		emit_signal("ready_for_stun")
		next_attack_stage()

	elif attack_stage == 2 and timer > 0.5:
		turn_and_face_player()
		play_animation("spin_loop")
		force_movement(storm_speed)
		damage_on_touch.activate()
		next_attack_stage()

	elif attack_stage == 3:
		if is_colliding_with_wall() or timer > 1.5:
			force_movement(0)
			damage_on_touch.deactivate()
			play_animation("spin_end")
			next_attack_stage()

	elif attack_stage == 4 and has_finished_last_animation():
		play_animation("idle")
		EndAbility()

func _Interrupt() -> void:
	character.emit_signal("damage_reduction", 1.0)
	damage_on_touch.deactivate()
	force_movement(0)
	._Interrupt()

func spawn_tornadoes() -> void:
	if not tornado_projectile:
		return
	var speeds := [150.0, 200.0, 250.0]
	var dirs := [-1, 1, -1]
	for i in range(3):
		var t = instantiate(tornado_projectile)
		t.set_creator(self)
		t.initialize(dirs[i])
		t.global_position.x += 24 * dirs[i]
		t.set_horizontal_speed(speeds[i] * dirs[i])
