extends SimplePlayerProjectile

# Hieijin - Homing slash projectile that tracks nearest enemy

export var travel_speed := 220.0
export var homing_strength := 3.0
export var lifetime := 2.5

var target : Node2D

func _Setup() -> void:
	._Setup()
	set_horizontal_speed(travel_speed * get_facing_direction())
	find_nearest_enemy()

func find_nearest_enemy() -> void:
	var enemies = get_tree().get_nodes_in_group("Enemy")
	var min_dist := 99999.0
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy is KinematicBody2D:
			var dist = global_position.distance_to(enemy.global_position)
			if dist < min_dist:
				min_dist = dist
				target = enemy

func _Update(delta) -> void:
	._Update(delta)
	if is_instance_valid(target):
		var dir_to_target = (target.global_position - global_position).normalized()
		velocity.x += dir_to_target.x * homing_strength
		velocity.y += dir_to_target.y * homing_strength
		velocity = velocity.clamped(travel_speed * 1.2)
	if timer > lifetime:
		destroy()
