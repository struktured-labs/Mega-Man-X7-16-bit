extends SimplePlayerProjectile

# SniperMissile - Homing missile from Snipe Anteator
# Seeks nearest enemy with smooth homing

const bypass_shield := true
const speed := 350.0
export var tracking_time := 1.2
export var tracker_update_interval := 0.06
onready var tracker: Area2D = $tracker
var target : Node2D
var track_timer := 0.0

func _Setup() -> void:
	._Setup()
	set_horizontal_speed(speed * get_facing_direction())

func _Update(delta) -> void:
	if has_hit_scenery():
		on_wall_hit()
		return
	._Update(delta)
	go_after_nearest_target(delta)
	set_rotation(Vector2(get_horizontal_speed(), get_vertical_speed()).angle())

func on_wall_hit() -> void:
	animatedSprite.visible = true
	if is_collided_moving():
		disable_visuals()
		return
	explode()

func explode() -> void:
	disable_visuals()

func go_after_nearest_target(delta) -> void:
	if not ending and not target:
		track_timer += delta
		if track_timer > tracker_update_interval:
			target = tracker.get_closest_target()
			track_timer = 0
	if is_tracking():
		var target_dir = Tools.get_angle_between(target, self)
		var target_speed = Vector2(speed * target_dir.x, speed * target_dir.y)
		slowly_turn_towards_target(target_speed, delta)

func slowly_turn_towards_target(target_speed : Vector2, delta : float) -> void:
	var current_speed = Vector2(get_horizontal_speed(), get_vertical_speed())
	var current_angle = current_speed.normalized().angle()
	var target_angle = target_speed.normalized().angle()
	var new_angle = lerp_angle(current_angle, target_angle, delta * 12)
	var new_dir = Vector2(cos(new_angle), sin(new_angle))
	set_horizontal_speed(new_dir.x * speed)
	set_vertical_speed(new_dir.y * speed)

func is_tracking() -> bool:
	if timer > tracking_time or ending:
		return false
	if is_instance_valid(target):
		if target.name == "actual_center":
			if target.get_parent().current_health > 0:
				return true
		elif target.current_health > 0:
			return true
		else:
			target = null
	return false

func _OnHit(_v) -> void:
	._OnHit(_v)
	ending = true

func deflect(_var) -> void:
	pass

func angle_to_vector2(angle) -> Vector2:
	return Vector2(cos(angle), sin(angle))

func set_direction(new_direction):
	facing_direction = new_direction
