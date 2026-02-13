extends GenericProjectile

var speed := 200.0
export var tracker_update_interval := 0.03
export var transform_time := 1.0
var last_dir := Vector2(0, 0)
var emitted := false

func initialize(_direction) -> void:
	Log("Initializing")
	activate()
	reset_timer()
	_Setup()

func _Setup() -> void:
	animatedSprite.play("default")

func _Update(delta) -> void:
	if is_on_floor() or is_on_wall() or is_on_ceiling():
		explode()
		return

	if attack_stage == 0:
		# Homing phase
		var target_dir = Tools.get_player_angle(global_position)
		var target_speed = Vector2(speed * target_dir.x, speed * target_dir.y)
		slowly_turn_towards_target(target_speed)
		set_rotation(Vector2(get_horizontal_speed(), get_vertical_speed()).angle())
		if timer > transform_time:
			next_attack_stage()

	elif attack_stage == 1:
		# Speed up and go straight
		set_horizontal_speed(last_dir.x * speed * 3)
		set_vertical_speed(last_dir.y * speed * 3)
		next_attack_stage()

func _OnHit(_target_remaining_HP) -> void:
	if not emitted:
		explode()

func explode() -> void:
	disable_visuals()
	deactivate()
	emitted = true
	set_rotation(0)

func slowly_turn_towards_target(target_speed: Vector2) -> void:
	var current_speed = Vector2(get_horizontal_speed(), get_vertical_speed())
	var current_angle = current_speed.normalized().angle()
	var target_angle = target_speed.normalized().angle()
	var new_angle = lerp_angle(current_angle, target_angle, tracker_update_interval)
	var new_speed = Vector2(cos(new_angle), sin(new_angle))
	set_horizontal_speed(new_speed.x * speed)
	set_vertical_speed(new_speed.y * speed)
	last_dir = new_speed
