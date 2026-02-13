extends AttackAbility

export var dagger_projectile: PackedScene
onready var dash_sfx: AudioStreamPlayer2D = $dash_sfx
onready var slash_sfx: AudioStreamPlayer2D = $slash_sfx

var daggers_spawned := 0

func _Setup() -> void:
	._Setup()
	daggers_spawned = 0

func _Update(delta) -> void:
	if attack_stage == 0 and has_finished_last_animation():
		dash_sfx.play()
		play_animation_once("dash")
		force_movement(get_horizontal_velocity())
		next_attack_stage_on_next_frame()

	elif attack_stage == 1:
		if timer > 0.1 and daggers_spawned < 3:
			spawn_dagger()
			daggers_spawned += 1
		if is_player_nearby_horizontally(48) or timer > 0.6 or is_colliding_with_wall():
			slash_sfx.play()
			next_attack_stage_on_next_frame()

	elif attack_stage == 2:
		force_movement(get_horizontal_velocity() * 0.15)
		set_vertical_speed(-get_jump_velocity() * 0.3)
		play_animation_once("slash")
		next_attack_stage_on_next_frame()

	elif attack_stage == 3:
		process_gravity(delta)
		if character.is_on_floor():
			play_animation_once("land")
			decay_speed(0.45, 0.35)
			next_attack_stage_on_next_frame()

	elif attack_stage == 4 and has_finished_last_animation():
		play_animation_once("idle")
		EndAbility()

func spawn_dagger() -> void:
	var p = instantiate(dagger_projectile)
	p.set_creator(self)
	p.initialize(-character.get_facing_direction())
	p.set_horizontal_speed(0)
	p.set_vertical_speed(100)

func _Interrupt() -> void:
	._Interrupt()
