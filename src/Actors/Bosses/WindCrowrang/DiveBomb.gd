extends AttackAbility

var walljump_count := 0
onready var jump_sfx: AudioStreamPlayer2D = $jump_sfx
onready var dive_sfx: AudioStreamPlayer2D = $dive_sfx
onready var land_sfx: AudioStreamPlayer2D = $land_sfx

func _Setup() -> void:
	._Setup()
	walljump_count = 0

func start_wallslide() -> void:
	land_sfx.play()
	force_movement(0)
	adjust_position_to_wall()
	set_direction_relative_to_camera()
	decay_vert_speed(0.15)
	walljump_count += 1
	play_animation_once("wall_cling")

func _Update(delta):
	if attack_stage == 0 and has_finished_last_animation():
		jump_sfx.play()
		play_animation_once("jump")
		set_vertical_speed(-get_jump_velocity() * 0.7)
		force_movement(get_horizontal_velocity() * 1.3)
		next_attack_stage_on_next_frame()

	elif attack_stage == 1:
		process_gravity(delta / 2)
		if has_finished_last_animation():
			play_animation_once("fly_idle")
		if is_colliding_with_wall():
			start_wallslide()
			next_attack_stage_on_next_frame()

	elif attack_stage == 2 and timer > 0.3:
		play_animation_once("wall_prepare")
		next_attack_stage_on_next_frame()

	elif attack_stage == 3:
		jump_sfx.play()
		play_animation_once("walljump")
		if is_player_nearby_horizontally(64):
			set_vertical_speed(-get_jump_velocity() * 0.65)
			force_movement(get_horizontal_velocity() * 1.3)
			next_attack_stage_on_next_frame()
		else:
			force_movement(get_horizontal_velocity() * 1.3)
			set_vertical_speed(-get_jump_velocity() / 2)
			go_to_attack_stage_on_next_frame(5)

	elif attack_stage == 4:
		process_gravity(delta / 2)
		if has_finished_last_animation():
			play_animation_once("fly_idle")
		if is_colliding_with_wall():
			start_wallslide()
			go_to_attack_stage_on_next_frame(2)

	elif attack_stage == 5:
		if walljump_count < 2:
			process_gravity(delta / 2)
		if has_finished_last_animation():
			play_animation_once("fly_idle")
		if is_player_nearby_horizontally(64) and not is_player_above():
			next_attack_stage_on_next_frame()
		elif is_colliding_with_wall():
			start_wallslide()
			go_to_attack_stage_on_next_frame(2)

	elif attack_stage == 6:
		decay_move_speed()
		set_vertical_speed(0)
		play_animation_once("dive_prepare")
		next_attack_stage_on_next_frame()

	elif attack_stage == 7 and timer > 0.15:
		dive_sfx.play()
		play_animation_once("dive")
		set_vertical_speed(get_jump_velocity() * 2)
		process_gravity(delta)
		if character.is_on_floor():
			screenshake()
			land_sfx.play()
			play_animation_once("land")
			next_attack_stage_on_next_frame()

	elif attack_stage == 8 and timer > 0.5:
		play_animation_once("idle")
		if has_finished_last_animation():
			EndAbility()

func decay_vert_speed(duration: float = 0.15) -> void:
	var tween = get_tree().create_tween()
	tween.tween_method(self, "set_vertical_speed", -50.0, 0.0, duration)

func decay_move_speed(duration: float = 0.15) -> void:
	var tween = get_tree().create_tween()
	tween.tween_method(self, "force_movement", get_horizontal_velocity(), 0.0, duration)

func _Interrupt() -> void:
	play_animation_once("idle")
	._Interrupt()

func process_gravity(_delta: float, gravity := default_gravity) -> void:
	character.add_vertical_speed(gravity * _delta)
