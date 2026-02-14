extends Ability

# Zero's Saber Charge - hold fire to charge, release for powerful slash
# Simpler than X's 4-level system: just one charge level

export var charge_time := 1.5
export var charged_slash_damage := 10.0
export var charged_duration := 0.35
export var charge_color := Color(0.2, 0.9, 0.2, 1)  # Green glow

var charged_time := 0.0
var charging := false
var fully_charged := false
var released := false

onready var hitbox: Area2D = get_node_or_null("SaberHitbox")
onready var hitbox_shape: CollisionShape2D = get_node_or_null("SaberHitbox/CollisionShape2D")

onready var charging_particle = character.get_node("animatedSprite").get_node_or_null("ChargingParticle")
onready var charged_particle = character.get_node("animatedSprite").get_node_or_null("ChargedParticle")

signal stop

func _ready() -> void:
	audio = get_node_or_null("audioStreamPlayer")
	Event.listen("pause_menu_opened", self, "on_pause")
	Event.listen("pause_menu_closed", self, "on_unpause")
	if hitbox_shape:
		hitbox_shape.set_deferred("disabled", true)
	if hitbox:
		hitbox.connect("body_entered", self, "_on_hitbox_body_entered")

func on_pause():
	if executing and audio:
		audio.set_stream_paused(true)

func on_unpause():
	if executing and audio:
		audio.set_stream_paused(false)

func _StartCondition() -> bool:
	if not character.is_executing("Ride") and not character.block_charging:
		if get_charge_pressed():
			return true
	return false

func _Setup():
	charged_time = 0.0
	charging = false
	fully_charged = false
	released = false

func _Update(delta: float) -> void:
	if released:
		# Performing charged slash
		if hitbox:
			hitbox.scale.x = character.get_facing_direction()
		if timer >= charged_duration:
			disable_hitbox()
			EndAbility()
		return

	if get_charge_released() and character.listening_to_inputs:
		if charged_time >= charge_time:
			perform_charged_slash()
		else:
			EndAbility()
	elif get_charge_pressed():
		charge(delta)
	else:
		if character.listening_to_inputs:
			EndAbility()

func charge(delta: float) -> void:
	charged_time += delta
	if charged_time >= charge_time * 0.3 and not charging:
		start_vfx()
	if charged_time >= charge_time and not fully_charged:
		fully_charged = true
		if charged_particle:
			if charging_particle:
				charging_particle.visible = false
			charged_particle.visible = true

func perform_charged_slash() -> void:
	released = true
	timer = 0
	stop_vfx()
	play_animation("charged_slash")
	play_sound(sound)
	enable_hitbox(Vector2(28, 22), Vector2(14, -2))

func enable_hitbox(extents: Vector2, offset: Vector2) -> void:
	if hitbox_shape:
		if hitbox_shape.shape is RectangleShape2D:
			hitbox_shape.shape.extents = extents / 2.0
		hitbox_shape.position = offset
		hitbox_shape.set_deferred("disabled", false)
	if hitbox:
		hitbox.scale.x = character.get_facing_direction()

func disable_hitbox() -> void:
	if hitbox_shape:
		hitbox_shape.set_deferred("disabled", true)

func start_vfx():
	charging = true
	if sound and audio:
		play_sound(sound, false)
	enable_charge_shader()
	if charging_particle:
		charging_particle.visible = true

func stop_vfx():
	if audio:
		stop_sound()
	disable_charge_shader()
	charging = false
	fully_charged = false
	if charging_particle:
		charging_particle.visible = false
	if charged_particle:
		charged_particle.visible = false

func enable_charge_shader():
	character.animatedSprite.material.set_shader_param("Charge", 1)
	character.animatedSprite.material.set_shader_param("Color", charge_color)

func disable_charge_shader():
	character.get_node("animatedSprite").material.set_shader_param("Charge", 0)

func _EndCondition() -> bool:
	if charged_time == 0 and timer > 0.1:
		return true
	if charged_time < charge_time * 0.3 and not get_charge_pressed():
		return true
	if character.is_executing("Ride"):
		return true
	return false

func _Interrupt():
	charged_time = 0
	released = false
	stop_vfx()
	disable_hitbox()
	emit_signal("stop")

func _on_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("Enemy") and body.has_method("damage"):
		body.damage(charged_slash_damage, character)
		character.emit_signal("melee_hit", body)

func get_charge_pressed() -> bool:
	return get_action_pressed(actions[0])

func get_charge_released() -> bool:
	return not get_action_pressed(actions[0])

func play_sound_on_initialize() -> void:
	pass

func should_execute_on_hold() -> bool:
	return true

func should_always_listen_to_inputs() -> bool:
	return true

func _process(_delta: float) -> void:
	if audio:
		if audio.playing and not executing:
			stop_vfx()
