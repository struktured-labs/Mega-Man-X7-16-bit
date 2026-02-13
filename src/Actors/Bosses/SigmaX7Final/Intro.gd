extends GenericIntro

export var boss_bar : Texture

func connect_start_events() -> void:
	Log("Connecting boss events")
	Event.listen("warning_done", self, "execute_intro")

func _Update(_delta) -> void:
	if attack_stage == 0:
		make_visible()
		play_animation("intro_start")
		Event.emit_signal("play_boss_music")
		screenshake(2.0)
		next_attack_stage()

	elif attack_stage == 1 and has_finished_last_animation():
		play_animation("intro_loop")
		next_attack_stage()

	elif attack_stage == 2 and timer > 1.0:
		play_animation("intro_end")
		next_attack_stage()

	elif attack_stage == 3 and has_finished_last_animation():
		Event.emit_signal("set_boss_bar", boss_bar)
		Event.emit_signal("boss_health_appear", character)
		next_attack_stage()

	elif attack_stage == 4 and timer > 1.55:
		EndAbility()
