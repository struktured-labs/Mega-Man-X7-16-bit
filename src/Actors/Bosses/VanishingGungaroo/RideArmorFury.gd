extends AttackAbility

var kick_count := 0
var max_kicks := 3
var bullets_fired := 0
var max_bullets := 8
export var bullet_projectile: PackedScene
onready var roar_sfx: AudioStreamPlayer2D = $roar_sfx
onready var kick_sfx: AudioStreamPlayer2D = $kick_sfx
onready var shot_sfx: AudioStreamPlayer2D = $shot_sfx
onready var explosion_sfx: AudioStreamPlayer2D = $explosion_sfx
onready var land_sfx: AudioStreamPlayer2D = $land_sfx
onready var boss_ai = get_parent().get_node("BossAI")

func _Setup() -> void:
	._Setup()
	kick_count = 0
	bullets_fired = 0
	character.emit_signal("damage_reduction", 0.5)

func _Update(delta) -> void:
	if attack_stage == 0:
		process_gravity(delta)
		if has_finished_last_animation():
			roar_sfx.play()
			explosion_sfx.play()
			screenshake(3.0)
			play_animation_once("ride_explode")
			next_attack_stage_on_next_frame()

	elif attack_stage == 1 and timer > 0.6:
		play_animation_once("desperation_roar")
		if boss_ai.has_method("restore_phase1_enhanced"):
			boss_ai.restore_phase1_enhanced()
		next_attack_stage_on_next_frame()

	elif attack_stage == 2 and timer > 0.5:
		if kick_count < max_kicks:
			start_kick()
			next_attack_stage_on_next_frame()
		else:
			go_to_attack_stage_on_next_frame(6)

	elif attack_stage == 3:
		process_gravity(delta)
		if character.get_vertical_speed() > 0:
			kick_sfx.play()
			play_animation_once("kick")
			next_attack_stage_on_next_frame()

	elif attack_stage == 4:
		process_gravity(delta)
		if character.is_on_floor():
			land_sfx.play()
			screenshake()
			play_animation_once("land")
			kick_count += 1
			next_attack_stage_on_next_frame()

	elif attack_stage == 5 and timer > 0.15:
		turn_and_face_player()
		go_to_attack_stage(2)

	elif attack_stage == 6:
		play_animation_once("shoot_rapid")
		next_attack_stage_on_next_frame()

	elif attack_stage == 7:
		if timer > 0.1 and bullets_fired < max_bullets:
			fire_rapid_bullet()
			bullets_fired += 1
			timer = 0
		if bullets_fired >= max_bullets:
			next_attack_stage_on_next_frame()

	elif attack_stage == 8 and timer > 0.5:
		play_animation_once("idle")
		EndAbility()

func start_kick() -> void:
	turn_and_face_player()
	play_animation_once("jump")
	set_vertical_speed(-get_jump_velocity() * 1.2)
	force_movement(get_horizontal_velocity() * 1.5 * get_player_direction_relative())

func fire_rapid_bullet() -> void:
	shot_sfx.play()
	var p = instantiate_projectile(bullet_projectile)
	var spread = -0.4 + bullets_fired * 0.1
	p.set_horizontal_speed(250 * character.get_facing_direction())
	p.set_vertical_speed(spread * 200)

func _Interrupt() -> void:
	character.emit_signal("damage_reduction", 1)
	._Interrupt()
