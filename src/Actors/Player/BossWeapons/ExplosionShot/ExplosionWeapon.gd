extends BossWeapon

# Explosion Weapon - Fires 4 blasts in cardinal directions when charged

const cardinal_speed := 120.0

func fire_charged() -> void:
	play(weapon.charged_sound)
	var directions = [
		Vector2(1, 0),   # right
		Vector2(-1, 0),  # left
		Vector2(0, -1),  # up
		Vector2(0, 1)    # down
	]
	for dir_vec in directions:
		var shot = instantiate_projectile(weapon.regular_shot)
		set_position_as_character_position(shot)
		shot.damage = shot.damage * 1.5
		# Override speed after deferred initialize completes
		shot.call_deferred("set_horizontal_speed", cardinal_speed * dir_vec.x)
		shot.call_deferred("set_vertical_speed", cardinal_speed * dir_vec.y)
