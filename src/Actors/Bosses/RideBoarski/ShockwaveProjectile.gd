extends GenericProjectile

# Ground shockwave that travels along the floor
export var speed := 180.0

func _Setup() -> void:
	set_horizontal_speed(speed * facing_direction)
	set_vertical_speed(0)

func _Update(delta) -> void:
	# Stay on ground
	process_gravity(delta)
	if is_on_wall() or timer > 2.5:
		destroy()

func _OnHit(_target_remaining_HP) -> void:
	disable_visuals()
