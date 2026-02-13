extends GenericProjectile

# Splash damage area that appears when Warfly emerges from submerge
var lifetime := 0.8

func _Setup() -> void:
	animatedSprite.play("default")

func _Update(_delta) -> void:
	if timer > lifetime:
		destroy()

func _OnHit(_target_remaining_HP) -> void:
	pass

func _OnScreenExit() -> void:
	destroy()
