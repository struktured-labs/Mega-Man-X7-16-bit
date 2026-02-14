extends Movement

# Raijinshou (from Tonion) - Electric rising uppercut
# Press alt_fire while dashing -> electric rising attack

export var rise_velocity := 340.0
export var rise_duration := 0.35
export var hit_damage := 6.0
export var ammo_cost := 3.0

var ex_gauge_node
var rising := false

onready var hitbox: Area2D = get_node_or_null("SaberHitbox")
onready var hitbox_shape: CollisionShape2D = get_node_or_null("SaberHitbox/CollisionShape2D")

func _ready() -> void:
	ex_gauge_node = get_parent().get_node_or_null("EXGauge")
	if hitbox_shape:
		hitbox_shape.set_deferred("disabled", true)
	if hitbox:
		hitbox.connect("body_entered", self, "_on_hitbox_body_entered")

func _StartCondition() -> bool:
	if character.is_executing("Dash") or character.is_executing("DashJump"):
		if has_ammo():
			return true
	return false

func has_ammo() -> bool:
	if ex_gauge_node:
		return ex_gauge_node.current_ammo >= ammo_cost
	return true

func consume_ammo() -> void:
	if ex_gauge_node:
		ex_gauge_node.reduce_ammo(ammo_cost)

func _Setup() -> void:
	consume_ammo()
	rising = true
	character.set_vertical_speed(-rise_velocity)
	enable_hitbox()

func enable_hitbox() -> void:
	if hitbox_shape:
		if hitbox_shape.shape is RectangleShape2D:
			hitbox_shape.shape.extents = Vector2(10, 14)
		hitbox_shape.position = Vector2(6, -8)
		hitbox_shape.set_deferred("disabled", false)
	if hitbox:
		hitbox.scale.x = character.get_facing_direction()

func disable_hitbox() -> void:
	if hitbox_shape:
		hitbox_shape.set_deferred("disabled", true)

func _Update(delta: float) -> void:
	if hitbox:
		hitbox.scale.x = character.get_facing_direction()

	if rising:
		force_movement(horizontal_velocity * 0.3)
		if timer >= rise_duration:
			rising = false
			character.set_vertical_speed(0)
			disable_hitbox()
	else:
		process_gravity(delta)
		force_movement(horizontal_velocity * 0.2)

func _EndCondition() -> bool:
	if not rising and character.is_on_floor() and timer > rise_duration + 0.1:
		return true
	return false

func _Interrupt() -> void:
	rising = false
	disable_hitbox()
	character.set_horizontal_speed(0)

func _on_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("Enemy") and body.has_method("damage"):
		body.damage(hit_damage, character)
		character.emit_signal("melee_hit", body)

func play_animation_on_initialize():
	character.play_animation("slash2")
