extends Ability

# Zero's 3-hit saber combo system
# Ground: slash1 -> slash2 -> slash3 (progressive presses)
# Air: single air slash
# Dash: dash slash (wider, faster)

export var combo_window := 0.4
export var slash1_damage := 4.0
export var slash2_damage := 4.0
export var slash3_damage := 6.0
export var air_slash_damage := 5.0
export var dash_slash_damage := 5.0

export var slash1_duration := 0.2
export var slash2_duration := 0.2
export var slash3_duration := 0.28
export var air_slash_duration := 0.25
export var dash_slash_duration := 0.18

var combo_stage := 0  # 0=slash1, 1=slash2, 2=slash3
var combo_timer := 0.0
var combo_active := false
var waiting_for_next := false
var current_slash_duration := 0.0
var is_air_slash := false
var is_dash_slash := false

onready var hitbox: Area2D = $SaberHitbox
onready var hitbox_shape: CollisionShape2D = $SaberHitbox/CollisionShape2D

func _ready() -> void:
	if hitbox_shape:
		hitbox_shape.set_deferred("disabled", true)
	if hitbox:
		hitbox.connect("body_entered", self, "_on_hitbox_body_entered")

func _StartCondition() -> bool:
	return character.has_health()

func _Setup() -> void:
	is_air_slash = not character.is_on_floor() and not character.is_executing("Dash")
	is_dash_slash = character.is_executing("Dash")

	if is_air_slash:
		start_air_slash()
	elif is_dash_slash:
		start_dash_slash()
	elif waiting_for_next and combo_stage < 3:
		continue_combo()
	else:
		start_combo()

func start_combo() -> void:
	combo_stage = 0
	combo_active = true
	waiting_for_next = false
	activate_slash(0)

func continue_combo() -> void:
	waiting_for_next = false
	activate_slash(combo_stage)

func start_air_slash() -> void:
	combo_stage = 0
	combo_active = false
	waiting_for_next = false
	current_slash_duration = air_slash_duration
	set_hitbox_damage(air_slash_damage)
	enable_hitbox(Vector2(20, 16), Vector2(12, 0))
	play_slash_animation("slash_air")
	play_sound(sound)

func start_dash_slash() -> void:
	combo_stage = 0
	combo_active = false
	waiting_for_next = false
	current_slash_duration = dash_slash_duration
	set_hitbox_damage(dash_slash_damage)
	enable_hitbox(Vector2(24, 14), Vector2(14, 0))
	play_slash_animation("slash_dash")
	play_sound(sound)

func activate_slash(stage: int) -> void:
	match stage:
		0:
			current_slash_duration = slash1_duration
			set_hitbox_damage(slash1_damage)
			enable_hitbox(Vector2(18, 14), Vector2(12, -2))
			play_slash_animation("slash1")
		1:
			current_slash_duration = slash2_duration
			set_hitbox_damage(slash2_damage)
			enable_hitbox(Vector2(20, 16), Vector2(12, -2))
			play_slash_animation("slash2")
		2:
			current_slash_duration = slash3_duration
			set_hitbox_damage(slash3_damage)
			enable_hitbox(Vector2(22, 18), Vector2(14, -2))
			play_slash_animation("slash3")
	play_sound(sound)

func set_hitbox_damage(dmg: float) -> void:
	if has_node("SaberHitbox/DamageOnTouch"):
		$SaberHitbox/DamageOnTouch.damage = dmg

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

func _Update(delta: float) -> void:
	# Update hitbox direction
	if hitbox:
		hitbox.scale.x = character.get_facing_direction()

	if timer >= current_slash_duration:
		disable_hitbox()
		if not waiting_for_next and combo_active and combo_stage < 2:
			# Transition to waiting for next combo input
			waiting_for_next = true
			combo_stage += 1
			combo_timer = 0.0
			return

		if waiting_for_next:
			combo_timer += delta
			if _is_action_just_pressed():
				# Continue combo
				timer = 0
				continue_combo()
				return
			if combo_timer >= combo_window:
				# Combo expired
				reset_combo()
				EndAbility()
				return
		else:
			# Single slash (air/dash) or combo stage 3 finished
			reset_combo()
			EndAbility()
			return

func _EndCondition() -> bool:
	return false  # Managed in _Update

func _Interrupt() -> void:
	disable_hitbox()
	reset_combo()

func reset_combo() -> void:
	combo_stage = 0
	combo_active = false
	waiting_for_next = false
	combo_timer = 0.0
	is_air_slash = false
	is_dash_slash = false

func _is_action_just_pressed() -> bool:
	for input in actions:
		if character.get_action_just_pressed(input):
			return true
	return false

func play_slash_animation(anim: String):
	character.play_animation(anim)

func _on_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("Enemy") and body.has_method("damage"):
		var dmg = slash1_damage
		match combo_stage:
			1: dmg = slash2_damage
			2: dmg = slash3_damage
		if is_air_slash:
			dmg = air_slash_damage
		if is_dash_slash:
			dmg = dash_slash_damage
		body.damage(dmg, character)
		character.emit_signal("melee_hit", body)

func play_animation_on_initialize():
	pass  # Animation handled in _Setup per slash type

func play_sound_on_initialize():
	pass  # Sound handled in _Setup per slash type

func should_execute_on_hold() -> bool:
	return false
