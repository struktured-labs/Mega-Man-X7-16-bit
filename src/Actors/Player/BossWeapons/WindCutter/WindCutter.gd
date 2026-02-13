extends SimplePlayerProjectile

# WindCutter - Boomerang from Wind Crowrang
# Goes forward, returns to player if doesn't hit an enemy

const forward_speed := 350.0
const return_speed := 300.0
const forward_distance := 160.0
var returning := false
var start_x := 0.0

func _Setup() -> void:
	._Setup()
	start_x = global_position.x
	set_horizontal_speed(forward_speed * get_facing_direction())

func _Update(delta) -> void:
	._Update(delta)
	if not ending and not returning:
		var distance = abs(global_position.x - start_x)
		if distance >= forward_distance:
			start_return()
	if returning and is_instance_valid(creator):
		var dir_to_player = sign(creator.global_position.x - global_position.x)
		set_horizontal_speed(return_speed * dir_to_player)
		var y_dir = sign(creator.global_position.y - global_position.y)
		set_vertical_speed(return_speed * 0.5 * y_dir)
		# Check if returned to player
		var dist_to_player = global_position.distance_to(creator.global_position)
		if dist_to_player < 16:
			destroy()
	# Spin animation
	if not ending:
		animatedSprite.rotation += 15.0 * delta

func start_return() -> void:
	returning = true
	animatedSprite.play("return")

func _OnHit(_target_remaining_HP) -> void:
	disable_visuals()

func _OnDeflect() -> void:
	start_return()

func set_direction(new_direction):
	facing_direction = new_direction
	if not animatedSprite:
		animatedSprite = get_node("animatedSprite")
	animatedSprite.scale.x = new_direction
