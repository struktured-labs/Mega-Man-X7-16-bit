extends Enemy

# Simplified clone of Flame Hyenard
# Spawned by CloneAttack, performs one fire missile attack, then disappears

export (PackedScene) var projectile
var attack_timer := 0.0
var has_attacked := false
var lifetime := 2.5

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	attack_timer += delta

	if not has_attacked and attack_timer > 0.5:
		fire_at_player()
		has_attacked = true

	if attack_timer > lifetime:
		auto_destruct()

func fire_at_player() -> void:
	if projectile:
		var shot = projectile.instance()
		get_tree().current_scene.add_child(shot, true)
		shot.global_position = global_position
		shot.global_position.x += 16 * get_facing_direction()

		var player_pos = GameManager.get_player_position()
		var dir = (player_pos - global_position).normalized()
		shot.set_horizontal_speed(170 * dir.x)
		shot.set_vertical_speed(170 * dir.y)
		if "set_creator" in shot:
			shot.set_creator(self)
		if "initialize" in shot:
			shot.initialize(-get_facing_direction())

func auto_destruct() -> void:
	queue_free()
