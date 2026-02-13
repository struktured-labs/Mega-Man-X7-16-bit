extends AttackAbility

# DESPERATION: Room goes dark, fires precision shots from shadows
export (PackedScene) var bullet_projectile
export var shot_speed := 600.0
var teleport_count := 0
var max_teleports := 4
var darkness_active := false
onready var damage_node: Node2D = $"../Damage"
onready var dot_node: Node2D = $"../DamageOnTouch"

signal ready_for_stun

func _Setup() -> void:
	turn_and_face_player()
	teleport_count = 0
	darkness_active = false
	character.emit_signal("damage_reduction", 0.5)

func _Update(delta) -> void:
	process_gravity(delta)

	if attack_stage == 0:
		play_animation_once("desperation_prepare")
		screenshake(1.0)
		next_attack_stage()

	elif attack_stage == 1 and has_finished_last_animation():
		# Darken room
		activate_darkness()
		emit_signal("ready_for_stun")
		next_attack_stage()

	elif attack_stage == 2:
		# Teleport sequence
		if teleport_count >= max_teleports:
			go_to_attack_stage(6)
			return
		# Disappear
		character.animatedSprite.visible = false
		damage_node.deactivate()
		dot_node.deactivate()
		next_attack_stage()

	elif attack_stage == 3 and timer > 0.4:
		# Reposition
		teleport_to_random_position()
		next_attack_stage()

	elif attack_stage == 4 and timer > 0.2:
		# Reappear and aim
		character.animatedSprite.visible = true
		damage_node.activate()
		dot_node.activate()
		turn_and_face_player()
		play_animation_once("snipe_fire")
		fire_sniper_shot()
		screenshake(0.5)
		teleport_count += 1
		next_attack_stage()

	elif attack_stage == 5 and timer > 0.6:
		# Loop back for next teleport
		go_to_attack_stage(2)

	elif attack_stage == 6:
		# End darkness
		deactivate_darkness()
		character.animatedSprite.visible = true
		damage_node.activate()
		dot_node.activate()
		play_animation_once("desperation_end")
		next_attack_stage()

	elif attack_stage == 7 and has_finished_last_animation():
		play_animation_once("idle")
		EndAbility()

func activate_darkness() -> void:
	darkness_active = true
	Event.emit_signal("screenshake", 1.0)

func deactivate_darkness() -> void:
	darkness_active = false

func teleport_to_random_position() -> void:
	var camera_center = GameManager.camera.get_camera_screen_center()
	var offset_x = BossRNG.rng.randi_range(-120, 120)
	var target_x = camera_center.x + offset_x
	# Raycast down to find floor
	var space_state = get_world_2d().direct_space_state
	var from = Vector2(target_x, camera_center.y - 200)
	var to = Vector2(target_x, camera_center.y + 200)
	var result = space_state.intersect_ray(from, to, [character], 1)
	if result:
		character.global_position = Vector2(target_x, result["position"].y)
	else:
		character.global_position = Vector2(target_x, character.global_position.y)

func fire_sniper_shot() -> void:
	if bullet_projectile:
		var target_dir = (GameManager.get_player_position() - global_position).normalized()
		var bullet = instantiate(bullet_projectile)
		bullet.set_creator(self)
		bullet.initialize(character.get_facing_direction())
		bullet.set_horizontal_speed(shot_speed * target_dir.x)
		bullet.set_vertical_speed(shot_speed * target_dir.y)

func _Interrupt() -> void:
	._Interrupt()
	character.animatedSprite.visible = true
	if damage_node:
		damage_node.activate()
	if dot_node:
		dot_node.activate()
	deactivate_darkness()
	character.emit_signal("damage_reduction", 1.0)
