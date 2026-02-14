extends Weapon

# Axl's dual pistol buster: rapid fire, max 6 shots, no charge
# Shares shot count with all Axl bullets on screen

func _ready() -> void:
	._ready()
	Event.listen("shot_lemon", self, "on_lemon_shot_created")

func on_lemon_shot_created(emitter, shot):
	if emitter != self:
		connect_shot_event(shot)

func add_projectile_to_scene(charge_level) -> void:
	var shot = .add_projectile_to_scene(charge_level)
	if charge_level < 1:
		Event.emit_signal("shot_lemon", self, shot)

func has_ammo() -> bool:
	return shots_currently_alive < max_shots_alive

func position_shot(shot) -> void:
	shot.global_position = character.global_position
	var aim_dir = get_aim_direction()
	shot.projectile_setup(character.get_facing_direction(), character.shot_position.position)
	# Override velocity with aimed direction
	if aim_dir != Vector2.ZERO:
		var speed = shot.horizontal_velocity
		shot.velocity = aim_dir.normalized() * speed
		shot.set_horizontal_speed(shot.velocity.x)
		shot.set_vertical_speed(shot.velocity.y)

func get_aim_direction() -> Vector2:
	var h := 0.0
	var v := 0.0
	if Input.is_action_pressed("move_right"):
		h = 1.0
	elif Input.is_action_pressed("move_left"):
		h = -1.0
	if Input.is_action_pressed("move_up"):
		v = -1.0
	elif Input.is_action_pressed("move_down"):
		v = 1.0

	if h == 0.0 and v == 0.0:
		return Vector2(character.get_facing_direction(), 0)
	return Vector2(h, v)
