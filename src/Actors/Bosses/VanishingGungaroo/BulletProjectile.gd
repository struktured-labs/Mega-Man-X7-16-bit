extends SimpleProjectile

func _Setup() -> void:
	set_horizontal_speed(speed * facing_direction)

func _Update(delta) -> void:
	process_gravity(delta * 0.3)
	if is_on_floor() or is_on_wall():
		deactivate()

func deactivate() -> void:
	.deactivate()
	set_horizontal_speed(0)
	set_vertical_speed(0)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.5)
	tween.tween_callback(self, "destroy")

func _OnHit(_target_remaining_HP) -> void:
	if not emitted:
		disable_visuals()
		deactivate()
		hitparticle.emit()
		emitted = true

func explode() -> void:
	pass
