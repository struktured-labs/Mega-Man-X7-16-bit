extends BossWeapon

# MovingWheel Weapon - Fires 3 wheels when charged

func fire_charged() -> void:
	play(weapon.charged_sound)
	for i in range(3):
		var shot = instantiate_projectile(weapon.regular_shot)
		var dir = character.get_facing_direction()
		var pos = Vector2(
			character.global_position.x + shot_position.position.x * dir,
			shot_position.global_position.y
		)
		pos.x += (i * 16.0) * dir
		shot.global_position = pos
