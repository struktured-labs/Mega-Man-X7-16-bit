extends GenericProjectile

# Rolling wheel projectile that travels along the ground
export var speed := 200.0

func _Setup() -> void:
	set_horizontal_speed(speed * facing_direction)

func _Update(delta) -> void:
	process_gravity(delta)
	if is_on_wall():
		destroy()
	if timer > 4.0:
		destroy()

func _OnHit(_target_remaining_HP) -> void:
	disable_visuals()
