extends GenericProjectile

# Ant bomb that crawls along surfaces, explodes after timer
export var crawl_speed := 120.0
export var fuse_time := 3.0
var on_surface := false

func _Setup() -> void:
	set_horizontal_speed(crawl_speed * facing_direction)

func _Update(delta) -> void:
	process_gravity(delta)

	# Once on floor, crawl along it
	if is_on_floor():
		on_surface = true
		set_horizontal_speed(crawl_speed * facing_direction)
		set_vertical_speed(0)

	# Reverse direction when hitting walls
	if is_on_wall():
		facing_direction *= -1
		set_horizontal_speed(crawl_speed * facing_direction)
		if animatedSprite:
			animatedSprite.scale.x = facing_direction

	# Explode after fuse time
	if timer > fuse_time:
		explode()

func explode() -> void:
	# Could spawn explosion effect here
	destroy()

func _OnHit(_target_remaining_HP) -> void:
	explode()
