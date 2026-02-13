extends SimpleProjectile

export var spike_speed := 150.0

func _Setup():
	set_horizontal_speed(spike_speed * get_direction())

func _Update(delta) -> void:
	if is_on_wall() or timer > 2.0:
		destroy()
