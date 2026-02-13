extends SimpleProjectile

export var split_on_impact := true

func _Update(delta) -> void:
	process_gravity(delta, 400)
	if is_on_wall() or is_on_floor():
		if split_on_impact:
			emit_signal("zero_health")
		destroy()

	if timer > 4.0:
		destroy()
