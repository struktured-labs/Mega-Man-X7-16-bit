extends AttackAbility

var dive_count := 0
var max_dives := 5
onready var dive_sfx: AudioStreamPlayer2D = $dive_sfx
onready var roar_sfx: AudioStreamPlayer2D = $roar_sfx
onready var land_sfx: AudioStreamPlayer2D = $land_sfx

func _Setup() -> void:
	._Setup()
	dive_count = 0
	character.emit_signal("damage_reduction", 0.5)

func _Update(delta) -> void:
	if attack_stage == 0:
		process_gravity(delta)
		if has_finished_last_animation():
			roar_sfx.play()
			play_animation_once("desperation_roar")
			next_attack_stage_on_next_frame()

	elif attack_stage == 1 and timer > 0.5:
		fly_to_ceiling()
		next_attack_stage_on_next_frame()

	elif attack_stage == 2 and timer > 0.4:
		if dive_count < max_dives:
			start_dive()
			next_attack_stage_on_next_frame()
		else:
			go_to_attack_stage_on_next_frame(6)

	elif attack_stage == 3:
		set_vertical_speed(700)
		var player_x = GameManager.get_player_position().x
		var diff = player_x - character.global_position.x
		force_movement(clamp(diff * 3, -300, 300))
		process_gravity(delta * 0.5)
		if character.is_on_floor():
			screenshake(3.0)
			land_sfx.play()
			dive_count += 1
			play_animation_once("dive_land")
			next_attack_stage_on_next_frame()

	elif attack_stage == 4 and timer > 0.15:
		fly_to_ceiling()
		go_to_attack_stage_on_next_frame(5)

	elif attack_stage == 5 and timer > 0.3:
		go_to_attack_stage(2)

	elif attack_stage == 6 and timer > 0.3:
		play_animation_once("exhausted")
		next_attack_stage_on_next_frame()

	elif attack_stage == 7 and timer > 1.0:
		set_vertical_speed(get_jump_velocity() * 0.5)
		next_attack_stage_on_next_frame()

	elif attack_stage == 8:
		process_gravity(delta)
		if character.is_on_floor():
			land_sfx.play()
			play_animation_once("land")
			next_attack_stage_on_next_frame()

	elif attack_stage == 9 and timer > 0.5:
		play_animation_once("idle")
		EndAbility()

func fly_to_ceiling() -> void:
	var ceiling_dist = get_distance_from_ceiling()
	var target_y = character.global_position.y - ceiling_dist + 30
	var tween = get_tree().create_tween()
	tween.tween_property(character, "global_position:y", target_y, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_list.append(tween)
	force_movement(0)
	play_animation_once("fly_idle")

func start_dive() -> void:
	dive_sfx.play()
	play_animation_once("dive")
	force_movement(0)

func _Interrupt() -> void:
	character.emit_signal("damage_reduction", 1)
	._Interrupt()
