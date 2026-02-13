extends SimpleProjectile

func _Setup() -> void:
	set_horizontal_speed(0)
	set_vertical_speed(100)

func _Update(delta) -> void:
	process_gravity(delta * 0.5)
	if is_on_floor():
		deactivate()

func deactivate() -> void:
	.deactivate()
	set_horizontal_speed(0)
	set_vertical_speed(0)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 1.5)
	tween.tween_callback(self, "destroy")

func _OnHit(_target_remaining_HP) -> void:
	pass

func explode() -> void:
	pass

func _OnScreenExit() -> void:
	destroy()
