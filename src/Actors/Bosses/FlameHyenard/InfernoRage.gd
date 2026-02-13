extends AttackAbility

export (PackedScene) var projectile
export (PackedScene) var fire_wall
export var rage_duration := 1.5
var missiles_fired := 0

signal ready_for_stun

func _Setup() -> void:
	._Setup()
	character.emit_signal("damage_reduction", 0.5)
	missiles_fired = 0

func _Update(delta) -> void:
	process_gravity(delta)

	if attack_stage == 0:
		# Roar
		play_animation_once("idle")
		screenshake()
		next_attack_stage()

	elif attack_stage == 1 and timer > rage_duration:
		# Fire walls rise from ground
		create_fire_wall(1)
		create_fire_wall(-1)
		emit_signal("ready_for_stun")
		next_attack_stage()

	elif attack_stage == 2 and timer > 0.5:
		# Rapid fire missiles while walls active
		if missiles_fired < 6:
			fire_missile()
			missiles_fired += 1
			if missiles_fired < 6:
				go_to_attack_stage(2)
			else:
				next_attack_stage()
		else:
			next_attack_stage()

	elif attack_stage == 3 and timer > 1.0:
		# Walls recede, recovery
		play_animation_once("idle")
		EndAbility()

func create_fire_wall(direction: int) -> void:
	if fire_wall:
		var instance = fire_wall.instance()
		var boss_death: Node2D = get_node_or_null("../BossDeath")
		get_tree().current_scene.add_child(instance, true)
		instance.set_global_position(global_position)
		if boss_death:
			boss_death.connect("screen_flash", instance, "on_boss_death")
		instance.global_position = GameManager.camera.get_camera_screen_center()
		instance.global_position.y += 4
		instance.global_position.x += GameManager.camera.width / 2 * direction - 48 * direction
		screenshake()

func fire_missile() -> void:
	if projectile:
		var shot = instantiate_projectile(projectile)
		shot.global_position = character.global_position
		shot.global_position.x += 16 * character.get_facing_direction()
		shot.global_position.y -= 8
		var target_dir = Tools.get_player_angle(global_position)
		shot.set_horizontal_speed(200 * target_dir.x)
		shot.set_vertical_speed(200 * target_dir.y)

func _Interrupt() -> void:
	._Interrupt()
	kill_tweens(tween_list)
	character.emit_signal("damage_reduction", 1)
