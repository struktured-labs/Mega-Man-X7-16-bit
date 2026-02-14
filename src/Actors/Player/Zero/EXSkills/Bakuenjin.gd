extends Ability

# Bakuenjin (from Hyenard) - Ground punch + flame explosion
# Press alt_fire while standing (when Hadangeki not available) -> fire burst around Zero

export var explosion_damage := 5.0
export var explosion_radius := 32.0
export var duration := 0.45
export var ammo_cost := 3.0

var ex_gauge_node

onready var hitbox: Area2D = get_node_or_null("ExplosionHitbox")
onready var hitbox_shape: CollisionShape2D = get_node_or_null("ExplosionHitbox/CollisionShape2D")

func _ready() -> void:
	ex_gauge_node = get_parent().get_node_or_null("EXGauge")
	if hitbox_shape:
		hitbox_shape.set_deferred("disabled", true)
	if hitbox:
		hitbox.connect("body_entered", self, "_on_hitbox_body_entered")

func _StartCondition() -> bool:
	if character.is_on_floor() and not character.is_executing("Dash"):
		if not character.is_executing("Walk"):
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
	enable_hitbox()

func enable_hitbox() -> void:
	if hitbox_shape:
		if hitbox_shape.shape is CircleShape2D:
			hitbox_shape.shape.radius = explosion_radius
		elif hitbox_shape.shape is RectangleShape2D:
			hitbox_shape.shape.extents = Vector2(explosion_radius, explosion_radius)
		hitbox_shape.set_deferred("disabled", false)

func disable_hitbox() -> void:
	if hitbox_shape:
		hitbox_shape.set_deferred("disabled", true)

func _Update(_delta: float) -> void:
	character.set_horizontal_speed(0)

func _EndCondition() -> bool:
	return timer >= duration

func _Interrupt() -> void:
	disable_hitbox()

func _on_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("Enemy") and body.has_method("damage"):
		body.damage(explosion_damage, character)

func play_animation_on_initialize():
	character.play_animation("slash3")
