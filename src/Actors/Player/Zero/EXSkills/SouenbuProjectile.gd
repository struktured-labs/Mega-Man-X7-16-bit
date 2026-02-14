extends SimplePlayerProjectile

# Souenbu - Boomerang blade that travels out and returns to Zero

export var travel_speed := 280.0
export var travel_distance := 120.0
export var return_speed := 320.0
export var lifetime := 3.0

var return_target : Node2D
var start_position : Vector2
var returning := false

func set_return_target(target: Node2D) -> void:
	return_target = target

func _Setup() -> void:
	._Setup()
	start_position = global_position
	set_horizontal_speed(travel_speed * get_facing_direction())

func _Update(delta) -> void:
	._Update(delta)

	if not returning:
		var dist = abs(global_position.x - start_position.x)
		if dist >= travel_distance:
			returning = true
	else:
		if is_instance_valid(return_target):
			var dir_to_owner = (return_target.global_position - global_position).normalized()
			velocity.x = dir_to_owner.x * return_speed
			velocity.y = dir_to_owner.y * return_speed
			# Check if returned close enough
			if global_position.distance_to(return_target.global_position) < 12:
				destroy()
		else:
			# Owner gone, just reverse direction
			set_horizontal_speed(-travel_speed * get_facing_direction())

	if timer > lifetime:
		destroy()
