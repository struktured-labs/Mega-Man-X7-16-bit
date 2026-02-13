extends SimpleProjectile

func _Setup():
	set_vertical_speed(50)

func _Update(delta) -> void:
	process_gravity(delta, 600)
	if is_on_floor():
		_OnHit(0)
	if timer > 4.0:
		destroy()
