extends GenericProjectile

# Ground shockwave from giant punch
export var speed := 250.0

func _Setup():
	set_horizontal_speed(speed * get_direction())
	animatedSprite.play("idle")

func _Update(_delta) -> void:
	if is_on_wall():
		destroy()

func _OnHit(_target_remaining_HP) -> void:
	disable_visuals()
	deactivate()
