extends Character

export var skip_intro := false

var current_armor = []
var flash_timer := 0.0
var block_charging := false
var dashfall := false
var dashjumps_since_jump := 0
var raycast_down : RayCast2D
var colliding := true
var grabbed := false
onready var lowjumpcast: Label = $lowjumpcast

# Axl-specific
var stored_dna_enemy := ""
var is_transformed := false

signal walljump
signal wallslide
signal dashjump
signal airdash
signal firedash
signal collected_health(amount)
signal weapon_stasis
signal end_weapon_stasis
signal dry_dash
signal received_damage
signal equipped_armor
signal at_max_hp

var ride : Node2D

func deactivate():
	stop_listening_to_inputs()
	stop_shot()
	Log ("not active")

func activate():
	if is_colliding():
		.activate()
	return

func has_control() -> bool:
	if grabbed:
		return true
	if listening_to_inputs:
		return true
	elif ride:
		return ride.listening_to_inputs
	return false

func is_riding() -> bool:
	return is_instance_valid(ride)

func on_land() -> void:
	dashjumps_since_jump = 0
	dashfall = false

func dashjump_signal() -> void:
	emit_signal("dashjump")
	dashjumps_since_jump += 1

func airdash_signal() -> void:
	emit_signal("airdash")

func firedash_signal() -> void:
	emit_signal("firedash")

func update_facing_direction():
	if direction.x < 0:
		facing_right = false
		Event.emit_signal("player_faced_left")
	elif direction.x > 0:
		facing_right = true
		Event.emit_signal("player_faced_right")
	if animatedSprite.scale.x != get_facing_direction():
		animatedSprite.scale.x = get_facing_direction()

func reduce_hitbox():
	collisor.disabled = true

func increase_hitbox():
	collisor.disabled = false

func _ready() -> void:
	Event.listen("collected", self, "equip_parts")
	Event.listen("collected", self, "collect")
	listen("land", self, "on_land")

	save_original_colors()
	GameManager.set_player(self)
	Event.call_deferred("emit_signal", "player_set")

func _process(delta: float) -> void:
	process_flash(delta)

func spike_touch():
	if should_instantly_die() and not is_invulnerable():
		Log("Death by Spikes")
		emit_signal("zero_health")

func lava_touch():
	if should_instantly_die():
		Log("Death by Lava")
		emit_signal("zero_health")

func void_touch():
	Log("Death by falling")
	emit_signal("zero_health")

func should_instantly_die() -> bool:
	return not is_executing("Ride")

func process_flash(delta):
	if flash_timer > 0:
		flash_timer += delta
		if flash_timer > 0.034:
			end_flash()

func equip_parts(collectible : String):
	if is_heart(collectible):
		equip_heart()
	elif is_subtank(collectible):
		equip_subtank(collectible)
	elif is_weapon(collectible):
		equip_weapon(collectible)

func is_weapon(collectible : String) -> bool:
	return "weapon" in collectible

func equip_weapon(collectible : String) -> void:
	get_node("DualPistol").unlock_weapon(collectible)

func get_current_weapon():
	return get_node("DualPistol").current_weapon

func is_heart(collectible : String) -> bool:
	return "heart" in collectible or "life" in collectible

func is_subtank(collectible : String) -> bool:
	return "tank" in collectible

func equip_heart():
	GameManager.player.max_health += 2
	GameManager.player.recover_health(2)

func recover_health(value : float):
	if current_health < max_health:
		current_health += value
	if current_health >= max_health:
		emit_signal("at_max_hp")

func equip_subtank(collectible : String):
	for subtank in $Subtanks.get_children():
		if subtank.subtank.id == collectible:
			subtank.activate()

func get_subtank_current_health(id) -> int:
	for subtank in $Subtanks.get_children():
		if subtank.get_id() == id:
			return subtank.current_health
	return -1

func is_full_armor() -> String:
	return "no_armor"

func finished_equipping() -> void:
	get_node("DualPistol").update_list_of_weapons()

func has_any_upgrades() -> bool:
	return false

func collect(collectible: String):
	GameManager.add_collectible_to_savedata(collectible)

func save_original_colors():
	colors.append(animatedSprite.material.get_shader_param("MainColor1"))
	colors.append(animatedSprite.material.get_shader_param("MainColor2"))
	colors.append(animatedSprite.material.get_shader_param("MainColor3"))
	colors.append(animatedSprite.material.get_shader_param("MainColor4"))
	colors.append(animatedSprite.material.get_shader_param("MainColor5"))
	colors.append(animatedSprite.material.get_shader_param("MainColor6"))

func change_palette(new_colors, paint_armor := true):
	if not animatedSprite:
		animatedSprite = get_node("animatedSprite")
	set_new_colors_on_shader_parameters(animatedSprite, new_colors)

func set_new_colors_on_shader_parameters(object, new_colors) -> void:
	object.material.set_shader_param("R_MainColor1", new_colors[0])
	object.material.set_shader_param("R_MainColor2", new_colors[1])
	object.material.set_shader_param("R_MainColor3", new_colors[2])
	object.material.set_shader_param("R_MainColor4", new_colors[3])
	object.material.set_shader_param("R_MainColor5", new_colors[4])
	object.material.set_shader_param("R_MainColor6", new_colors[5])

func disable_collision():
	colliding = false
	get_node("CollisionShape2D").set_deferred("disabled", true)

func enable_collision():
	colliding = true
	get_node("CollisionShape2D").set_deferred("disabled", false)

func is_colliding() -> bool:
	return colliding

func flash():
	if has_health():
		animatedSprite.material.set_shader_param("Flash", 1)
		flash_timer = 0.01

func end_flash():
	animatedSprite.material.set_shader_param("Flash", 0)
	flash_timer = 0

func are_low_walljump_raycasts_active() -> bool:
	var b := true
	for raycast in low_jumpcasts:
		if not raycast.enabled:
			b = false
	return b

func activate_low_walljump_raycasts() -> void:
	for raycast in low_jumpcasts:
		raycast.enabled = true
	lowjumpcast.text = "on"

func deactivate_low_walljump_raycasts() -> void:
	for raycast in low_jumpcasts:
		raycast.enabled = false
	lowjumpcast.text = "off"

func set_global_position(new_position : Vector2) -> void:
	global_position = new_position

func start_dashfall() -> void:
	if not is_on_floor():
		dashfall = true

func set_x(pos) -> void:
	if can_be_moved():
		global_position.x = pos

func set_y(pos) -> void:
	if can_be_moved():
		global_position.y = pos

func move_x(difference) -> void:
	if can_be_moved():
		global_position.x += difference

func move_y(difference) -> void:
	if can_be_moved():
		global_position.y += difference

func can_be_moved() -> bool:
	return not is_executing("Ride")

func stop_forced_movement(forcer = null):
	if not is_executing("Ride"):
		emit_signal("stop_forced_movement", forcer)
		grabbed = false

# Axl-specific: store DNA for A-Trans
func store_dna(enemy_name: String) -> void:
	stored_dna_enemy = enemy_name

func get_stored_dna() -> String:
	return stored_dna_enemy

func clear_dna() -> void:
	stored_dna_enemy = ""

func has_stored_dna() -> bool:
	return stored_dna_enemy != ""
