extends GenericProjectile

# Bullet that bounces off walls
export var speed := 300.0
export var max_bounces := 5
var bounces := 0

func _Setup():
	animatedSprite.play("idle")

func _Update(_delta) -> void:
	if is_on_wall():
		velocity.x = -velocity.x
		bounces += 1
	if is_on_ceiling() or is_on_floor():
		velocity.y = -velocity.y
		bounces += 1

	if bounces >= max_bounces:
		animatedSprite.play("explode")
		disable_damage()
		set_horizontal_speed(0)
		set_vertical_speed(0)
		yield(animatedSprite, "animation_finished")
		destroy()

func _OnHit(_target_remaining_HP) -> void:
	disable_visuals()
	deactivate()
