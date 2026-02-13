extends GenericProjectile

# Fast horizontal beam that pierces through targets
var piercing := true

func _Setup() -> void:
	animatedSprite.play("default")

func _Update(_delta) -> void:
	process_movement()

func _OnHit(_target_remaining_HP) -> void:
	if not piercing:
		disable_visuals()

func _OnScreenExit() -> void:
	destroy()
