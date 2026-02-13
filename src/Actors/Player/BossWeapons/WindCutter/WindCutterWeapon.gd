extends BossWeapon

# WindCutter Weapon - Fires 8-directional homing shots when charged

func fire_charged() -> void:
	play(weapon.charged_sound)
	for i in range(8):
		var angle = i * (2 * PI / 8)
		var shot = instantiate_projectile(weapon.charged_shot)
		set_position_as_character_position(shot)
		# launch_angle is read by _Setup which runs via deferred initialize
		shot.launch_angle = angle
