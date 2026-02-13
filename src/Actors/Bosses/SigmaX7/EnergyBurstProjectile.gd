extends GenericProjectile

# Circular energy burst for Sigma's counter guard
export var speed := 0.0
export var expand_speed := 3.0
var expand_timer := 0.0

func _Setup():
	animatedSprite.play("idle")
	set_horizontal_speed(0)
	set_vertical_speed(0)

func _Update(_delta) -> void:
	expand_timer += _delta
	var s = 1.0 + expand_timer * expand_speed
	scale = Vector2(s, s)
	if expand_timer > 0.5:
		disable_damage()
	if expand_timer > 0.8:
		destroy()

func _OnHit(_target_remaining_HP) -> void:
	pass
