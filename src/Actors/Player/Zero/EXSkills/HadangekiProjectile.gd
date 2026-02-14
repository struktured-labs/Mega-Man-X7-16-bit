extends SimplePlayerProjectile

# Hadangeki - Saber wave projectile (ground energy wave)

export var travel_speed := 260.0
export var lifetime := 1.5

func _Setup() -> void:
	._Setup()
	set_horizontal_speed(travel_speed * get_facing_direction())

func _Update(delta) -> void:
	._Update(delta)
	if timer > lifetime:
		destroy()
