extends AttackAbility

var original_position := Vector2.ZERO
var target_x := 0.0

func _Setup() -> void:
	._Setup()
	original_position = character.global_position

func _Update(_delta) -> void:
	if attack_stage == 0:
		# Dive down off-screen
		play_animation_once("idle")
		var tween = new_tween()
		tween.tween_property(character, "global_position:y", character.global_position.y + 300, 0.6).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		tween.tween_callback(self, "next_attack_stage")
		next_attack_stage()

	elif attack_stage == 2:
		# Invisible, track player x
		animatedSprite.visible = false
		target_x = GameManager.get_player_position().x
		next_attack_stage()

	elif attack_stage == 3 and timer > 0.6:
		# Emerge at player position with splash
		character.global_position.x = target_x
		character.global_position.y = original_position.y + 200
		animatedSprite.visible = true
		play_animation_once("idle")
		screenshake(1.5)
		var tween = new_tween()
		tween.tween_property(character, "global_position:y", original_position.y, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		next_attack_stage()

	elif attack_stage == 4 and timer > 0.5:
		# Return to normal
		play_animation_once("idle")
		next_attack_stage()

	elif attack_stage == 5 and timer > 0.3:
		EndAbility()

func _Interrupt() -> void:
	._Interrupt()
	kill_tweens(tween_list)
	animatedSprite.visible = true
	character.global_position = original_position
