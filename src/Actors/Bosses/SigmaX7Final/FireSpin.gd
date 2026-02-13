extends AttackAbility

# Spinning fire projectiles - adapted from Lumine RotatingCrystals concept
export var fire_orb : PackedScene
onready var fire_sfx: AudioStreamPlayer2D = $fire_sfx
var orbs := []
var spin_timer := 0.0
const num_orbs := 4
const orbit_speed := 3.0
const expand_speed := 40.0

func _Setup() -> void:
	turn_and_face_player()
	play_animation("fire_prepare")
	orbs.clear()
	spin_timer = 0.0

func _Update(_delta) -> void:
	if attack_stage == 0 and has_finished_last_animation():
		play_animation("fire_loop")
		spawn_orbs()
		fire_sfx.play_rp()
		screenshake()
		next_attack_stage()

	elif attack_stage == 1: # Orbs rotating around boss
		spin_timer += _delta
		update_orb_positions(_delta)
		if spin_timer > 2.5:
			next_attack_stage()

	elif attack_stage == 2: # Fire orbs off in current directions
		play_animation("fire_end")
		release_orbs()
		next_attack_stage()

	elif attack_stage == 3 and has_finished_last_animation():
		EndAbility()

func spawn_orbs() -> void:
	for i in range(num_orbs):
		var orb = instantiate(fire_orb)
		orb.set_creator(self)
		orb.initialize(1)
		var angle = (TAU / num_orbs) * i
		orb.global_position = character.global_position + Vector2(cos(angle), sin(angle)) * 30
		orb.set_horizontal_speed(0)
		orb.set_vertical_speed(0)
		orbs.append({"node": orb, "angle": angle, "radius": 30.0})

func update_orb_positions(_delta : float) -> void:
	for orb_data in orbs:
		if is_instance_valid(orb_data.node):
			orb_data.angle += orbit_speed * _delta
			orb_data.radius += expand_speed * _delta
			var offset = Vector2(cos(orb_data.angle), sin(orb_data.angle)) * orb_data.radius
			orb_data.node.global_position = character.global_position + offset
			orb_data.node.set_horizontal_speed(0)
			orb_data.node.set_vertical_speed(0)

func release_orbs() -> void:
	for orb_data in orbs:
		if is_instance_valid(orb_data.node):
			var dir = Vector2(cos(orb_data.angle), sin(orb_data.angle))
			orb_data.node.set_horizontal_speed(dir.x * 200)
			orb_data.node.set_vertical_speed(dir.y * 200)
	orbs.clear()

func _Interrupt():
	._Interrupt()
	for orb_data in orbs:
		if is_instance_valid(orb_data.node):
			orb_data.node.queue_free()
	orbs.clear()
