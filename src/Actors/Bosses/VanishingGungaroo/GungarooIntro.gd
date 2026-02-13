extends GenericIntro

onready var land_sfx: AudioStreamPlayer2D = $land_sfx
onready var jump_sfx: AudioStreamPlayer2D = $jump_sfx

func prepare_for_intro() -> void:
	animatedSprite.visible = true
	character.global_position.x = GameManager.camera.get_camera_screen_center().x + 100
	play_animation_once("idle")
	character.modulate = Color(0, 0, 0, 0.5)

func _Setup() -> void:
	._Setup()
	var tween = get_tree().create_tween()
	tween.tween_property(character, "modulate", Color(1, 1, 1, 1), 0.5)

func _Update(delta) -> void:
	if attack_stage == 0 and has_finished_last_animation():
		jump_sfx.play()
		play_animation_once("jump")
		set_vertical_speed(-get_jump_velocity() * 0.8)
		force_movement(-200)
		next_attack_stage_on_next_frame()

	elif attack_stage == 1:
		process_gravity(delta)
		if character.is_on_floor():
			land_sfx.play()
			force_movement(0)
			turn_and_face_player()
			turn_player_towards_boss()
			play_animation_once("land")
			decay_speed(-0.35, 0.5)
			screenshake()
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
