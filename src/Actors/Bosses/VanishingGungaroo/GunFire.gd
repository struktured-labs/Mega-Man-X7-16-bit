extends AttackAbility

export var bullet_projectile: PackedScene
var bullets_fired := 0
var max_bullets := 4
onready var jump_sfx: AudioStreamPlayer2D = $jump_sfx
onready var shot_sfx: AudioStreamPlayer2D = $shot_sfx
onready var land_sfx: AudioStreamPlayer2D = $land_sfx

func _Setup() -> void:
	._Setup()
	bullets_fired = 0

func _Update(delta) -> void:
	if attack_stage == 0 and has_finished_last_animation():
		jump_sfx.play()
		play_animation_once("jump")
		set_vertical_speed(-get_jump_velocity() * 0.9)
		force_movement(get_horizontal_velocity() * 0.3 * get_player_direction_relative())
		next_attack_stage_on_next_frame()

	elif attack_stage == 1:
		process_gravity(delta)
		if timer > 0.15 and bullets_fired < max_bullets:
			fire_bullet()
			bullets_fired += 1
			timer = 0
		if character.is_on_floor():
			land_sfx.play()
			play_animation_once("land")
			decay_speed(0.5, 0.25)
			next_attack_stage_on_next_frame()

	elif attack_stage == 2 and has_finished_last_animation():
		play_animation_once("idle")
		EndAbility()

func fire_bullet() -> void:
	shot_sfx.play()
	play_animation_once("shoot")
	var p = instantiate_projectile(bullet_projectile)
	var angle = -0.3 + bullets_fired * 0.2
	p.set_horizontal_speed(200 * character.get_facing_direction())
	p.set_vertical_speed(100 + bullets_fired * 40)

func _Interrupt() -> void:
	._Interrupt()
