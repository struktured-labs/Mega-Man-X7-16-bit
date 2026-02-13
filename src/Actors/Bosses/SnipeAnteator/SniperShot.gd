extends AttackAbility

# Targeting laser tracks player, then fires powerful precise shot
export (PackedScene) var bullet_projectile
export var track_duration := 1.0
export var shot_speed := 600.0
export var shot_damage := 8.0
var target_direction := Vector2.ZERO

func _Setup() -> void:
	turn_and_face_player()
	target_direction = Vector2.ZERO

func _Update(delta) -> void:
	process_gravity(delta)

	if attack_stage == 0:
		play_animation_once("snipe_prepare")
		next_attack_stage()

	elif attack_stage == 1:
		# Track player with targeting laser
		play_animation("snipe_aim")
		target_direction = (GameManager.get_player_position() - global_position).normalized()
		if timer > track_duration:
			next_attack_stage()

	elif attack_stage == 2:
		play_animation_once("snipe_fire")
		fire_sniper_shot()
		screenshake(0.5)
		next_attack_stage()

	elif attack_stage == 3 and has_finished_last_animation():
		play_animation_once("snipe_recover")
		next_attack_stage()

	elif attack_stage == 4 and timer > 0.5:
		play_animation_once("idle")
		EndAbility()

func fire_sniper_shot() -> void:
	if bullet_projectile:
		var bullet = instantiate(bullet_projectile)
		bullet.set_creator(self)
		bullet.initialize(character.get_facing_direction())
		bullet.set_horizontal_speed(shot_speed * target_direction.x)
		bullet.set_vertical_speed(shot_speed * target_direction.y)
