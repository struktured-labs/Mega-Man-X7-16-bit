extends GenericProjectile

# Spinning fire orb projectile
export var speed := 200.0

func _Setup():
	animatedSprite.play("idle")

func _OnHit(_target_remaining_HP) -> void:
	animatedSprite.play("explode")
	disable_damage()
	set_horizontal_speed(0)
	set_vertical_speed(0)
	yield(animatedSprite, "animation_finished")
	destroy()

func _Update(_delta) -> void:
	pass
