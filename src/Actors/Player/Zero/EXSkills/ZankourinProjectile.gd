extends SimplePlayerProjectile

# Zankourin - Rolling energy disc that rolls along the ground

export var travel_speed := 200.0
export var lifetime := 2.0

func _Setup() -> void:
	._Setup()
	set_horizontal_speed(travel_speed * get_facing_direction())

func _Update(delta) -> void:
	._Update(delta)
	# Apply gravity to roll along ground
	process_gravity(delta, 900.0, 400.0)
	if timer > lifetime:
		destroy()
