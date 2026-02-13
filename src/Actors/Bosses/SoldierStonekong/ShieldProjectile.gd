extends SimpleProjectile

export var arc_height := -150.0
export var return_speed := 180.0
var returning := false
var origin_x := 0.0
var travel_distance := 200.0

func _Setup():
	origin_x = global_position.x
	set_horizontal_speed(speed * get_direction())
	set_vertical_speed(arc_height)

func _Update(delta) -> void:
	process_gravity(delta, 300)

	if not returning:
		if timer > 0.6:
			returning = true
			set_horizontal_speed(-return_speed * get_direction())
			set_vertical_speed(arc_height * 0.5)
	else:
		if timer > 1.2:
			destroy()
