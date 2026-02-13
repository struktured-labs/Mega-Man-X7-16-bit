extends AttackAbility

export (PackedScene) var torpedo_projectile
var volleys_fired := 0
var torpedoes_per_volley := 3
var total_volleys := 3
var spread_angle := 15.0

signal ready_for_stun

func _Setup() -> void:
	._Setup()
	character.emit_signal("damage_reduction", 0.5)
	volleys_fired = 0

func _Update(_delta) -> void:
	if attack_stage == 0:
		# Fly to top of screen
		play_animation_once("idle")
		var sc = GameManager.camera.get_camera_screen_center()
		var tween = new_tween()
		tween.tween_property(character, "global_position", Vector2(sc.x, sc.y - 80), 0.6).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		emit_signal("ready_for_stun")
		next_attack_stage()

	elif attack_stage == 1 and timer > 0.7:
		# Fire volleys
		fire_volley()
		volleys_fired += 1
		next_attack_stage()

	elif attack_stage == 2 and timer > 0.5:
		if volleys_fired < total_volleys:
			go_to_attack_stage(1)
		else:
			next_attack_stage()

	elif attack_stage == 3 and timer > 0.5:
		# Recovery
		play_animation_once("idle")
		EndAbility()

func fire_volley() -> void:
	var base_angle = Tools.get_player_angle(global_position)
	for i in range(torpedoes_per_volley):
		var shot = instantiate_projectile(torpedo_projectile)
		shot.global_position = character.global_position
		shot.global_position.y += 16
		var angle_offset = (i - 1) * deg2rad(spread_angle)
		var dir = Vector2(base_angle.x, base_angle.y).rotated(angle_offset)
		shot.set_horizontal_speed(300 * dir.x)
		shot.set_vertical_speed(300 * dir.y)

func _Interrupt() -> void:
	._Interrupt()
	kill_tweens(tween_list)
	character.emit_signal("damage_reduction", 1)
