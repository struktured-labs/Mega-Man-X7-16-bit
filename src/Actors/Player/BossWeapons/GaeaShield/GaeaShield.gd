extends Node2D

# GaeaShield - Rock shield from Soldier Stonekong
# Orbits player, blocks up to 3 projectiles before breaking

export var duration := 12.0
export var max_hits := 3
export var orbit_speed := 4.0
export var orbit_radius := 24.0

var active := false
var creator
var timer := 0.0
var hits := 0
var orbit_angle := 0.0
onready var front_shield: AnimatedSprite = $front_shield
onready var back_shield: AnimatedSprite = $back_shield

func _ready() -> void:
	global_position = GameManager.get_player_position()
	Event.connect("player_death", self, "queue_free")
	Event.connect("stage_teleport", self, "expire")
	Event.connect("stage_rotate", self, "expire")

func initialize(_facing_direction) -> void:
	active = true
	var tween = create_tween()
	front_shield.modulate = Color(12, 12, 12, 1)
	back_shield.modulate = Color(12, 12, 12, 1)
	tween.set_parallel()
	tween.tween_property(front_shield, "modulate", Color(1, 1, 1, 1), 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(back_shield, "modulate", Color(1, 1, 1, 1), 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func set_creator(_creator : Node) -> void:
	creator = _creator
	_creator.connect("damage", self, "on_player_hit")

func _physics_process(delta: float) -> void:
	if not active:
		return
	# Orbit around player
	orbit_angle += orbit_speed * delta
	var player_pos = GameManager.get_player_position()
	global_position = player_pos + Vector2(cos(orbit_angle) * orbit_radius, sin(orbit_angle) * orbit_radius * 0.5)
	timer += delta
	if timer > duration:
		expire()

func on_player_hit(_d = null, _d2 = null) -> void:
	# Shield absorbs hit
	pass

func _on_area2D_body_entered(body: Node) -> void:
	if active and body.active:
		react(body)

func react(body: Node) -> void:
	deflect_projectile(body)
	hits += 1
	blink()
	if hits >= max_hits:
		shatter()

func blink() -> void:
	front_shield.modulate = Color(10, 10, 10, 1)
	var tween = create_tween()
	tween.tween_property(front_shield, "modulate", Color(1, 1, 1, 1), 0.15)

func deflect_projectile(body):
	if body.is_in_group("Enemy Projectile"):
		if "deflect" in body:
			body.deflect()
		else:
			body.destroy()

func shatter() -> void:
	if active:
		active = false
		var tween = create_tween()
		tween.set_parallel()
		tween.tween_property(front_shield, "modulate", Color(0.6, 0.3, 0, 0), 0.3)
		tween.tween_property(back_shield, "modulate", Color(0.6, 0.3, 0, 0), 0.3)
		Tools.timer(0.35, "destroy", self)

func expire(_discard = null, _discard2 = null) -> void:
	if active:
		active = false
		var tween = create_tween()
		tween.set_parallel()
		tween.tween_property(front_shield, "modulate", Color(0.6, 0.3, 0, 0), 0.25)
		tween.tween_property(back_shield, "modulate", Color(0.6, 0.3, 0, 0), 0.25)
		Tools.timer(0.35, "destroy", self)

func destroy() -> void:
	queue_free()
