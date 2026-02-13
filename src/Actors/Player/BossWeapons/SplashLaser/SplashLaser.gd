extends SimplePlayerProjectile

# SplashLaser - Water beam from Splash Warfly
# Fast straight projectile that pierces through enemies

const speed := 500.0
const pierce := true

func _Setup() -> void:
	._Setup()
	set_horizontal_speed(speed * get_facing_direction())

func _Update(delta) -> void:
	._Update(delta)

func _OnHit(_target_remaining_HP) -> void:
	# Pierce through - don't destroy on hit
	pass

func set_direction(new_direction):
	facing_direction = new_direction
	if not animatedSprite:
		animatedSprite = get_node("animatedSprite")
	animatedSprite.scale.x = new_direction
