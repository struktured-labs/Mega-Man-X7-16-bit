extends SimpleProjectile

export var shockwave_speed := 200.0

func _Setup() -> void:
	set_horizontal_speed(shockwave_speed * facing_direction)
	set_vertical_speed(0)

func _Update(_delta) -> void:
	if is_on_wall():
		destroy()
		return
	if not is_on_floor():
		set_vertical_speed(200)

func _OnHit(_target_remaining_HP) -> void:
	if not emitted:
		disable_visuals()
		deactivate()
		hitparticle.emit()
		emitted = true

func _OnScreenExit() -> void:
	destroy()

func explode() -> void:
	pass
