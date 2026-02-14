extends SimplePlayerProjectile

# MovingWheel - Spinning wheel from Ride Boomer
# Rolls along floor and follows terrain, climbs walls

const speed := 300.0
const wall_climb_speed := 250.0
var on_ground := false
var on_wall := false
var climb_direction := 0

func _Setup() -> void:
	._Setup()
	set_horizontal_speed(speed * get_facing_direction())

func _Update(delta) -> void:
	._Update(delta)
	if not ending:
		handle_terrain()
		if not on_ground and not on_wall:
			process_gravity(delta, 600)
		# Rotate sprite based on movement
		animatedSprite.rotation += 12.0 * delta * get_facing_direction()

func handle_terrain() -> void:
	if is_on_floor():
		on_ground = true
		on_wall = false
		set_vertical_speed(0)
		set_horizontal_speed(speed * get_facing_direction())
	elif is_on_wall():
		# Climb wall
		on_wall = true
		on_ground = false
		set_horizontal_speed(0)
		set_vertical_speed(-wall_climb_speed)
	elif is_on_ceiling():
		# Roll along ceiling
		on_ground = false
		on_wall = false
		set_vertical_speed(0)
		set_horizontal_speed(-speed * get_facing_direction())

func _OnHit(_target_remaining_HP) -> void:
	disable_visuals()

func set_direction(new_direction):
	facing_direction = new_direction
	if not animatedSprite:
		animatedSprite = get_node("animatedSprite")
	animatedSprite.scale.x = new_direction
