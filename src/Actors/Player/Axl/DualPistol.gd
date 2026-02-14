extends Shot

# Axl's dual pistol - rapid fire, no charge, 8-directional aiming
# Fires every 0.12s while fire button is held
# Max 6 bullets on screen

var rapid_fire_timer := 0.0
var rapid_fire_interval := 0.12
var current_weapon_index := 0
var charge_level := 0

func _ready() -> void:
	if active:
		update_list_of_weapons()
		set_buster_as_weapon()
		Event.listen("shot_layer_disabled", self, "on_shot_layer_disabled")
		Event.listen("shot_layer_enabled", self, "on_shot_layer_enabled")
		Event.listen("weapon_select_left", self, "change_current_weapon_left")
		Event.listen("weapon_select_right", self, "change_current_weapon_right")
		Event.listen("weapon_select_buster", self, "set_buster_as_weapon")
		Event.listen("select_weapon", self, "direct_weapon_select")
		Event.listen("add_to_ammo_reserve", self, "_on_add_to_ammo_reserve")

func _StartCondition() -> bool:
	if current_weapon and character.has_control():
		if current_weapon_is_buster():
			return current_weapon.has_ammo()
		elif not current_weapon.is_cooling_down():
			return has_infinite_regular_ammo() or current_weapon.has_ammo()
	return false

func _Setup():
	next_shot_ready = false
	rapid_fire_timer = 0.0
	fire(current_weapon)

func _Update(_delta: float) -> void:
	if got_hit():
		return

	rapid_fire_timer += _delta
	# Rapid fire: auto-fire while held
	if action_pressed() and rapid_fire_timer >= rapid_fire_interval:
		if _StartCondition():
			fire(current_weapon)
			rapid_fire_timer = 0.0

func _EndCondition() -> bool:
	if not character.is_executing("Forced") and not action_pressed():
		return Has_time_ran_out()
	return false

func fire(weapon):
	enable_animation_layer()
	restart_animation()
	weapon.fire(0) # Axl never charges
	timer = 0.0

func should_execute_on_hold() -> bool:
	return true

# Weapon management (simplified from PrimaryShot - no charge)
func change_current_weapon_left():
	var index = weapons.find(current_weapon)
	if index - 1 < 0:
		set_current_weapon(weapons[weapons.size() - 1])
	else:
		set_current_weapon(weapons[index - 1])

func change_current_weapon_right():
	var index = weapons.find(current_weapon)
	if index + 1 > weapons.size() - 1:
		set_current_weapon(weapons[0])
	else:
		set_current_weapon(weapons[index + 1])

func set_current_weapon(weapon):
	current_weapon = weapon
	update_character_palette()
	Event.emit_signal("changed_weapon", current_weapon)
	next_shot_ready = false

func direct_weapon_select(weapon_resource):
	for weapon in weapons:
		if "weapon" in weapon:
			if weapon.weapon == weapon_resource:
				set_current_weapon(weapon)
				return

func update_character_palette() -> void:
	if not current_weapon:
		set_buster_as_weapon()
	if current_weapon_is_buster():
		character.change_palette(current_weapon.get_palette())
	else:
		character.change_palette(current_weapon.get_palette())

func current_weapon_is_buster() -> bool:
	return "Buster" in current_weapon.name

func weapon_cooldown_ended(_weapon) -> void:
	if next_shot_ready and character.listening_to_inputs:
		if has_infinite_regular_ammo() or current_weapon.has_ammo():
			next_shot_ready = false
			if executing:
				EndAbility()
			ExecuteOnce()

func unlock_weapon(collectible : String) -> void:
	for child in get_children():
		if child is BossWeapon:
			if child.should_unlock(collectible):
				child.active = true

func _on_add_to_ammo_reserve(amount) -> void:
	var lowest_ammo_weapon
	for weapon in weapons:
		if weapon is BossWeapon:
			if lowest_ammo_weapon:
				if weapon.current_ammo < lowest_ammo_weapon.current_ammo:
					lowest_ammo_weapon = weapon
			else:
				if weapon.current_ammo < 28:
					lowest_ammo_weapon = weapon
	if lowest_ammo_weapon:
		lowest_ammo_weapon.increase_ammo(amount)
