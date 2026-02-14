extends Movement

# Suiretsusen (from Warfly) - Downward thrust attack
# Press alt_fire + down while airborne -> plunge downward with saber

export var plunge_speed := 400.0
export var hit_damage := 6.0
export var ammo_cost := 2.0
export var bounce_velocity := -200.0

var ex_gauge_node
var plunging := false

onready var hitbox: Area2D = get_node_or_null("SaberHitbox")
onready var hitbox_shape: CollisionShape2D = get_node_or_null("SaberHitbox/CollisionShape2D")

func _ready() -> void:
	ex_gauge_node = get_parent().get_node_or_null("EXGauge")
	if hitbox_shape:
		hitbox_shape.set_deferred("disabled", true)
	if hitbox:
		hitbox.connect("body_entered", self, "_on_hitbox_body_entered")

func _StartCondition() -> bool:
	if not character.is_on_floor():
		if Input.is_action_pressed("move_down"):
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
	plunging = true
	character.set_vertical_speed(plunge_speed)
	character.set_horizontal_speed(0)
	enable_hitbox()

func enable_hitbox() -> void:
	if hitbox_shape:
		if hitbox_shape.shape is RectangleShape2D:
			hitbox_shape.shape.extents = Vector2(6, 14)
		hitbox_shape.position = Vector2(4, 8)
		hitbox_shape.set_deferred("disabled", false)
	if hitbox:
		hitbox.scale.x = character.get_facing_direction()

func disable_hitbox() -> void:
	if hitbox_shape:
		hitbox_shape.set_deferred("disabled", true)

func _Update(_delta: float) -> void:
	if plunging:
		character.set_vertical_speed(plunge_speed)
		character.set_horizontal_speed(0)
		if hitbox:
			hitbox.scale.x = character.get_facing_direction()

func _EndCondition() -> bool:
	if plunging and character.is_on_floor():
		return true
	return false

func _Interrupt() -> void:
	plunging = false
	disable_hitbox()
	character.set_horizontal_speed(0)

func _on_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("Enemy") and body.has_method("damage"):
		body.damage(hit_damage, character)
		character.emit_signal("melee_hit", body)
		# Bounce off enemy on hit
		character.set_vertical_speed(bounce_velocity)

func play_animation_on_initialize():
	character.play_animation("slash_air")
