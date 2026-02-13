extends SimpleProjectile

export var wave_speed := 200.0

func _Setup():
	set_horizontal_speed(wave_speed * get_direction())

func _Update(delta) -> void:
	if is_on_wall() or timer > 2.0:
		destroy()
