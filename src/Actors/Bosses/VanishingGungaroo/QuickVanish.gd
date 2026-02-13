extends AttackAbility

onready var vanish_sfx: AudioStreamPlayer2D = $vanish_sfx
onready var appear_sfx: AudioStreamPlayer2D = $appear_sfx

func _Setup() -> void:
	._Setup()

func _Update(_delta) -> void:
	if attack_stage == 0 and has_finished_last_animation():
		play_animation_once("vanish")
		next_attack_stage_on_next_frame()

	elif attack_stage == 1 and timer > 0.15:
		vanish_sfx.play()
		character.animatedSprite.visible = false
		force_movement(0)
		next_attack_stage_on_next_frame()

	elif attack_stage == 2 and timer > 0.4:
		reposition_behind_player()
		character.animatedSprite.visible = true
		appear_sfx.play()
		play_animation_once("appear_slash")
		turn_and_face_player()
		next_attack_stage_on_next_frame()

	elif attack_stage == 3 and timer > 0.3:
		play_animation_once("slash_recovery")
		next_attack_stage_on_next_frame()

	elif attack_stage == 4 and has_finished_last_animation():
		play_animation_once("idle")
		EndAbility()

func reposition_behind_player() -> void:
	var player_pos = GameManager.get_player_position()
	var behind_offset = -60 * get_player_direction_relative()
	character.global_position.x = player_pos.x + behind_offset

func _Interrupt() -> void:
	character.animatedSprite.visible = true
	._Interrupt()
