extends Lemon

# Axl's Copy Bullet - slower, spawns DNACore on kill
# Speed: 150 (vs 360 normal), damage: 2

var dna_core_scene : PackedScene = preload("res://src/Actors/Player/Axl/DNACore.tscn")

func hit(target):
	if active:
		hit_time = 0.01
		countdown_to_destruction = 0.01
		target.damage(damage, self)
		emit_hit_particle()
		disable_projectile_visual()
		call_deferred("disable_damage")
		remove_from_group("Player Projectile")

		# Check if enemy was killed - spawn DNACore
		if target.has_method("has_health"):
			if not target.has_health():
				spawn_dna_core(target)

func spawn_dna_core(enemy) -> void:
	if dna_core_scene:
		var core = dna_core_scene.instance()
		get_tree().current_scene.add_child(core, true)
		core.global_position = enemy.global_position
		core.enemy_name = enemy.name if enemy else "Unknown"

func launch_setup(direction, _launcher_velocity := 0.0):
	set_horizontal_speed(horizontal_velocity * direction)
