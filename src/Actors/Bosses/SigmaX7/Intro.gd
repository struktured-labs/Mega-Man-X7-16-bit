extends GenericIntro

export var boss_bar : Texture

func connect_start_events() -> void:
	Log("Connecting boss events")
	Event.listen("warning_done", self, "execute_intro")
	Event.connect("character_talking", self, "on_talk")

func on_talk(who):
	if who == "Sigma":
		play_animation_once("talk")
	else:
		play_animation_once("idle")

func _Update(_delta) -> void:
	if attack_stage == 0:
		play_animation("seated_loop")
		start_dialog_or_go_to_attack_stage(2)

	elif attack_stage == 1:
		if seen_dialog():
			next_attack_stage()

	elif attack_stage == 2 and timer > 0.1:
		next_attack_stage()

	elif attack_stage == 3 and timer > 0.25:
		play_animation("intro")
		Event.emit_signal("play_boss_music")
		next_attack_stage()

	elif attack_stage == 4 and has_finished_last_animation():
		play_animation("intro_end")
		screenshake()
		next_attack_stage()

	elif attack_stage == 5 and has_finished_last_animation():
		Event.emit_signal("set_boss_bar", boss_bar)
		Event.emit_signal("boss_health_appear", character)
		next_attack_stage()

	elif attack_stage == 6 and timer > 1.55:
		EndAbility()
