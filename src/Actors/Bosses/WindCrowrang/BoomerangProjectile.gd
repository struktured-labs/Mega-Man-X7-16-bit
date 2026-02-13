extends GenericProjectile

export var speed := 300.0
var bounce_count := 0
var max_bounces := 8
var returning := false
var boss_ref: KinematicBody2D

func _Setup() -> void:
	set_horizontal_speed(speed * facing_direction)
	set_vertical_speed(-80)

func _Update(delta) -> void:
	if returning and is_instance_valid(boss_ref):
		var dir = (boss_ref.global_position - global_position).normalized()
		set_horizontal_speed(dir.x * speed * 1.5)
		set_vertical_speed(dir.y * speed * 1.5)
		if global_position.distance_to(boss_ref.global_position) < 24:
			destroy()
		return

	process_gravity(delta * 0.3)

	if is_on_wall():
		set_horizontal_speed(-get_horizontal_speed())
		bounce_count += 1
	if is_on_floor() or is_on_ceiling():
		set_vertical_speed(-get_vertical_speed() * 0.8)
		bounce_count += 1

	if bounce_count >= max_bounces:
		returning = true

	set_rotation(Vector2(get_horizontal_speed(), get_vertical_speed()).angle())

func _OnHit(_target_remaining_HP) -> void:
	pass

func _OnScreenExit() -> void:
	destroy()

func explode() -> void:
	pass
