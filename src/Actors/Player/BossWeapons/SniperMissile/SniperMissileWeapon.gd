extends BossWeapon

# SniperMissile Weapon - Fires 3 homing missiles when charged

func fire_charged() -> void:
	play(weapon.charged_sound)
	var offsets = [0.0, -20.0, 20.0]
	for i in range(3):
		var shot = instantiate_projectile(weapon.regular_shot)
		var dir = character.get_facing_direction()
		var pos = Vector2(
			character.global_position.x + shot_position.position.x * dir,
			shot_position.global_position.y + offsets[i]
		)
		shot.global_position = pos
