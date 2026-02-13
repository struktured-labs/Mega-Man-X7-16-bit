extends BossWeapon

# SplashLaser Weapon - Fires rapid 3-shot burst when charged

func fire_charged() -> void:
	play(weapon.charged_sound)
	fire_burst()

func fire_burst() -> void:
	for i in range(3):
		var shot = instantiate_projectile(weapon.regular_shot)
		var dir = character.get_facing_direction()
		var pos = Vector2(
			character.global_position.x + shot_position.position.x * dir,
			shot_position.global_position.y
		)
		pos.x += (i * 12.0) * dir
		shot.global_position = pos
		shot.damage = shot.damage * 1.5
