extends SimpleProjectile

export var tornado_speed := 200.0
export var lifetime := 3.0

func _Setup():
	set_horizontal_speed(tornado_speed * get_direction())

func _Update(delta) -> void:
	if is_on_wall() or timer > lifetime:
		destroy()
