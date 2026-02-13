extends GenericProjectile

# Homing missile that tracks the player position
export var speed := 160.0
export var turn_rate := 3.0
export var homing_delay := 0.3
var direction := Vector2.ZERO

func _Setup() -> void:
	direction = Vector2(facing_direction, -1).normalized()

func _Update(delta) -> void:
	if timer > homing_delay:
		# Track player
		var target_pos = GameManager.get_player_position()
		var desired_dir = (target_pos - global_position).normalized()
		direction = direction.linear_interpolate(desired_dir, turn_rate * delta)
		direction = direction.normalized()

	set_horizontal_speed(speed * direction.x)
	set_vertical_speed(speed * direction.y)

	# Update rotation to face movement direction
	set_rotation(direction.angle())

	# Destroy after timeout or wall collision
	if timer > 5.0 or is_on_wall() or is_on_floor() or is_on_ceiling():
		destroy()

func _OnHit(_target_remaining_HP) -> void:
	disable_visuals()
