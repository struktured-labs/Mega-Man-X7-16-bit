extends AttackAbility

export var shockwave_projectile: PackedScene
onready var jump_sfx: AudioStreamPlayer2D = $jump_sfx
onready var slam_sfx: AudioStreamPlayer2D = $slam_sfx

func _Setup() -> void:
	._Setup()

func _Update(delta) -> void:
	if attack_stage == 0 and has_finished_last_animation():
		jump_sfx.play()
		play_animation_once("ride_jump")
		set_vertical_speed(-get_jump_velocity() * 1.2)
		force_movement(0)
		next_attack_stage_on_next_frame()

	elif attack_stage == 1:
		process_gravity(delta)
		if character.get_vertical_speed() > 0:
			play_animation_once("ride_slam")
			set_vertical_speed(get_jump_velocity() * 2)
			next_attack_stage_on_next_frame()

	elif attack_stage == 2:
		process_gravity(delta)
		if character.is_on_floor():
			slam_sfx.play()
			screenshake(3.0)
			play_animation_once("ride_land")
			spawn_shockwaves()
			next_attack_stage_on_next_frame()

	elif attack_stage == 3 and timer > 0.6:
		play_animation_once("ride_idle")
		EndAbility()

func spawn_shockwaves() -> void:
	var left = instantiate(shockwave_projectile)
	left.set_creator(self)
	left.initialize(-1)
	left.global_position = character.global_position + Vector2(-20, 0)

	var right = instantiate(shockwave_projectile)
	right.set_creator(self)
	right.initialize(1)
	right.global_position = character.global_position + Vector2(20, 0)

func _Interrupt() -> void:
	._Interrupt()
