extends GenericProjectile

# Fast, powerful sniper bullet
export var speed := 600.0

func _Setup() -> void:
	pass # Speed set by the attack that spawns this

func _Update(_delta) -> void:
	# Destroy on wall hit or after timeout
	if is_on_wall() or is_on_floor() or is_on_ceiling() or timer > 3.0:
		destroy()

func _OnHit(_target_remaining_HP) -> void:
	disable_visuals()
