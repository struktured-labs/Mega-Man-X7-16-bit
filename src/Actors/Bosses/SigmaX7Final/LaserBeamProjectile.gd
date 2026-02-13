extends GenericProjectile

# Sweeping laser beam for Sigma Final's eye laser
export var beam_length := 400.0

func _Setup():
	animatedSprite.play("idle")
	set_horizontal_speed(0)
	set_vertical_speed(0)

func _Update(_delta) -> void:
	pass

func _OnHit(_target_remaining_HP) -> void:
	pass
