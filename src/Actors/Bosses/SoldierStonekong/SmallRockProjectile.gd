extends SimpleProjectile

func _Update(delta) -> void:
	process_gravity(delta, 600)
	if is_on_wall() or is_on_floor() or timer > 3.0:
		destroy()
