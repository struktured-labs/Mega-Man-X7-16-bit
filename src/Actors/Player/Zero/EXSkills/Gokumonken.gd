extends Ability

# Gokumonken (from Stonekong) - Defensive counter stance
# Hold select_special -> enters counter stance for up to 1s
# If hit during stance, auto-counterattacks for big damage

export var counter_damage := 12.0
export var stance_duration := 1.0
export var counter_slash_duration := 0.3
export var ammo_cost := 4.0

var ex_gauge_node
var in_stance := false
var countering := false
var ammo_consumed := false

onready var hitbox: Area2D = get_node_or_null("SaberHitbox")
onready var hitbox_shape: CollisionShape2D = get_node_or_null("SaberHitbox/CollisionShape2D")

func _ready() -> void:
	ex_gauge_node = get_parent().get_node_or_null("EXGauge")
	if hitbox_shape:
		hitbox_shape.set_deferred("disabled", true)
	if hitbox:
		hitbox.connect("body_entered", self, "_on_hitbox_body_entered")
	# Listen for damage to trigger counter
	character.listen("damage", self, "_on_character_damaged")

func _StartCondition() -> bool:
	if character.is_on_floor() and not character.is_executing("Dash"):
		if has_ammo():
			return true
	return false

func has_ammo() -> bool:
	if ex_gauge_node:
		return ex_gauge_node.current_ammo >= ammo_cost
	return true

func consume_ammo() -> void:
	if ex_gauge_node and not ammo_consumed:
		ex_gauge_node.reduce_ammo(ammo_cost)
		ammo_consumed = true

func _Setup() -> void:
	in_stance = true
	countering = false
	ammo_consumed = false
	consume_ammo()
	# Grant invulnerability during stance
	character.add_invulnerability("Gokumonken")

func _Update(_delta: float) -> void:
	if countering:
		if hitbox:
			hitbox.scale.x = character.get_facing_direction()
		if timer >= counter_slash_duration:
			disable_hitbox()
			EndAbility()
	elif in_stance:
		character.set_horizontal_speed(0)
		if timer >= stance_duration:
			# Stance expired without being hit
			end_stance()
			EndAbility()

func _EndCondition() -> bool:
	if in_stance and not countering:
		# Allow ending early by releasing button
		if not get_action_pressed(actions[0]):
			return true
	return false

func _Interrupt() -> void:
	end_stance()
	disable_hitbox()
	countering = false

func end_stance() -> void:
	in_stance = false
	character.remove_invulnerability("Gokumonken")

func trigger_counter() -> void:
	if in_stance and not countering:
		end_stance()
		countering = true
		timer = 0
		enable_hitbox()
		play_animation("slash3")
		play_sound(sound)

func enable_hitbox() -> void:
	if hitbox_shape:
		if hitbox_shape.shape is RectangleShape2D:
			hitbox_shape.shape.extents = Vector2(16, 16)
		hitbox_shape.position = Vector2(10, -4)
		hitbox_shape.set_deferred("disabled", false)
	if hitbox:
		hitbox.scale.x = character.get_facing_direction()

func disable_hitbox() -> void:
	if hitbox_shape:
		hitbox_shape.set_deferred("disabled", true)

func _on_character_damaged(_value, _inflicter) -> void:
	if executing and in_stance:
		# Cancel the damage (we were invulnerable) and counter
		trigger_counter()

func _on_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("Enemy") and body.has_method("damage"):
		body.damage(counter_damage, character)
		character.emit_signal("melee_hit", body)

func play_animation_on_initialize():
	character.play_animation("idle")  # Stance pose

func should_execute_on_hold() -> bool:
	return true
