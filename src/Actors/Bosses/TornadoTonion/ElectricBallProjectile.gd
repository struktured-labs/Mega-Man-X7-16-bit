extends SimpleProjectile

export var ball_lifetime := 3.0

func _Setup():
	set_vertical_speed(100)
	set_horizontal_speed(0)

func _Update(delta) -> void:
	process_gravity(delta, 300)
	if is_on_floor():
		set_vertical_speed(0)
		set_horizontal_speed(0)
	if timer > ball_lifetime:
		destroy()
