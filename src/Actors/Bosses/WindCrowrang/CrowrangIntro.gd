extends GenericIntro

onready var land: AudioStreamPlayer2D = $land
onready var swoop: AudioStreamPlayer2D = $swoop

func prepare_for_intro() -> void:
	animatedSprite.visible = true
	set_starting_position()
	play_animation_once("fly_idle")
	character.modulate = Color(0, 0, 0, 0.5)

func _Setup() -> void:
	._Setup()
	var tween = get_tree().create_tween()
	tween.tween_property(character, "modulate", Color(1, 1, 1, 1), 0.5)

func _Update(delta) -> void:
	if attack_stage == 0 and has_finished_last_animation():
		swoop.play()
		play_animation_once("dive")
		set_vertical_speed(get_jump_velocity())
		force_movement(200 * get_player_direction_relative())
		next_attack_stage_on_next_frame()

	elif attack_stage == 1:
		process_gravity(delta / 2)
		if character.is_on_floor():
			land.play()
			force_movement(0)
			turn_and_face_player()
			turn_player_towards_boss()
			play_animation_once("land")
			decay_speed(-0.35, 0.5)
			next_attack_stage()

	elif attack_stage == 2:
		start_dialog_or_go_to_attack_stage(4)

	elif attack_stage == 3 and timer > 0.5:
		play_animation_once("idle")
		if dialog_concluded:
			next_attack_stage()

	elif attack_stage == 4:
		play_animation_once("intro")
		Event.emit_signal("play_boss_music")
		next_attack_stage_on_next_frame()

	elif attack_stage == 5 and has_finished_last_animation():
		Event.emit_signal("boss_health_appear", character)
		if timer > 3:
			EndAbility()

func _Interrupt() -> void:
	Event.emit_signal("boss_start", character)
	GameManager.end_cutscene()
	character.emit_signal("intro_concluded")

func set_starting_position() -> void:
	var top = get_distance_from_ceiling()
	var camera_center = GameManager.camera.get_camera_screen_center()
	character.global_position = Vector2(camera_center.x, character.global_position.y - top + 20)
