extends BossIdle

func _Setup() -> void:
	if should_turn:
		turn_and_face_player()
	character.set_horizontal_speed(0)
	character.position.x = round(character.position.x)
	play_animation_once("idle")
