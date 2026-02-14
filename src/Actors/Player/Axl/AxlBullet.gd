extends Lemon

# Axl's dual pistol bullet: faster, smaller collision, 2 damage
# Can be aimed in 8 directions

var aim_direction := Vector2.ZERO

func references_setup(direction):
	set_direction(direction)
	animatedSprite.scale.x = direction
	$particles2D.scale.x = direction
	update_facing_direction()
	$animatedSprite.set_frame(int(rand_range(0, 8)))
	original_pitch = audio.pitch_scale

func launch_setup(direction, _launcher_velocity := 0.0):
	if aim_direction != Vector2.ZERO:
		var speed = horizontal_velocity
		var vel = aim_direction.normalized() * speed
		set_horizontal_speed(vel.x)
		velocity.y = vel.y
		# Rotate sprite to match aim direction
		var angle = aim_direction.angle()
		animatedSprite.rotation = angle if direction > 0 else angle + PI
	else:
		set_horizontal_speed(horizontal_velocity * direction)

func set_aim(dir: Vector2) -> void:
	aim_direction = dir
