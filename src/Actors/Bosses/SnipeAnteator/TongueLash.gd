extends GrabAttack

# Long-range tongue grab attack
onready var grab_area: Node2D = $GrabArea
var lash_timer := 0.0

func _ready() -> void:
	grab_area.connect("touch_target", self, "apply_stuck_state")

func _Setup() -> void:
	._Setup()
	grab_area.handle_direction()
	grabbed_player = false
	mashes_pressed = 0
	lash_timer = 0.0

func _Update(delta) -> void:
	process_gravity(delta)

	if attack_stage == 0:
		play_animation_once("tongue_prepare")
		next_attack_stage()

	elif attack_stage == 1 and has_finished_last_animation():
		play_animation_once("tongue_lash")
		force_movement(horizontal_velocity * 0.3)
		next_attack_stage()

	elif attack_stage == 2 and timer > 0.064:
		grab_area.activate()
		next_attack_stage_on_next_frame()

	elif attack_stage == 3:
		if grabbed_player:
			play_animation_once("tongue_grab")
			force_movement(0)
			next_attack_stage()
		elif timer > 0.5 or is_colliding_with_wall():
			force_movement(0)
			go_to_attack_stage(5)

	elif attack_stage == 4:
		# Grabbed player - deal damage
		lash_timer += delta
		manage_mashing()
		if mashed_enough() or lash_timer > 2.0:
			GameManager.player.stop_forced_movement()
			if lash_timer > 0.5:
				GameManager.player.damage(4, get_parent())
			else:
				GameManager.player.damage(1, get_parent())
			next_attack_stage()

	elif attack_stage == 5:
		play_animation_once("tongue_retract")
		if has_finished_last_animation():
			play_animation_once("idle")
			EndAbility()

func _Interrupt() -> void:
	GameManager.player.stop_forced_movement()
	lash_timer = 0.0

func set_player_state_and_animation() -> void:
	GameManager.player.force_movement()
	GameManager.player.play_animation("damage")
	GameManager.player.animatedSprite.set_frame(10)
	GameManager.player.grabbed = true

func reposition_player() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(GameManager.player, "global_position", get_safe_player_grab_position(), translate_duration).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
