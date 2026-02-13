extends AttackAbility

export var falling_rock : PackedScene
export var ground_spike : PackedScene

signal ready_for_stun

func _Setup() -> void:
	turn_and_face_player()
	play_animation("rage_prepare")
	character.emit_signal("damage_reduction", 0.5)

func _Update(delta) -> void:
	process_gravity(delta)
	if attack_stage == 0 and has_finished_last_animation():
		play_animation("rage_loop")
		screenshake(1.5)
		next_attack_stage()

	elif attack_stage == 1 and timer > 0.5:
		spawn_falling_rocks()
		emit_signal("ready_for_stun")
		next_attack_stage()

	elif attack_stage == 2 and timer > 2.0:
		spawn_ground_spikes()
		next_attack_stage()

	elif attack_stage == 3 and timer > 2.0:
		play_animation("rage_end")
		next_attack_stage()

	elif attack_stage == 4 and has_finished_last_animation():
		play_animation("idle")
		EndAbility()

func _Interrupt() -> void:
	character.emit_signal("damage_reduction", 1.0)
	._Interrupt()

func spawn_falling_rocks() -> void:
	if not falling_rock:
		return
	var camera_center = GameManager.camera.get_camera_screen_center()
	for i in range(8):
		var delay = i * 0.25
		Tools.timer(delay, "create_falling_rock", self)

func create_falling_rock() -> void:
	if not executing or not falling_rock:
		return
	var camera_center = GameManager.camera.get_camera_screen_center()
	var random_x = camera_center.x + rand_range(-160, 160)
	var rock = instantiate(falling_rock)
	rock.set_creator(self)
	rock.initialize(1)
	rock.global_position = Vector2(random_x, camera_center.y - 120)
	rock.set_horizontal_speed(0)
	rock.set_vertical_speed(50)
	screenshake(0.5)

func spawn_ground_spikes() -> void:
	if not ground_spike:
		return
	var left = instantiate(ground_spike)
	left.set_creator(self)
	left.initialize(1)
	left.global_position = Vector2(character.global_position.x - 16, character.global_position.y + 16)
	left.set_horizontal_speed(-150)

	var right = instantiate(ground_spike)
	right.set_creator(self)
	right.initialize(-1)
	right.global_position = Vector2(character.global_position.x + 16, character.global_position.y + 16)
	right.set_horizontal_speed(150)
