extends AttackAbility

# Counter stance - if hit during window, counter slash
const counter_window := 1.5
const counter_damage := 15.0
onready var counter_hitbox: Node2D = $counter_hitbox
onready var slash_sfx: AudioStreamPlayer2D = $slash_sfx
onready var guard_sfx: AudioStreamPlayer2D = $guard_sfx
onready var damage_module: Node2D = $"../Damage"
var was_hit := false

func _Setup() -> void:
	turn_and_face_player()
	was_hit = false
	damage_module.connect("took_damage", self, "_on_took_damage")

func _on_took_damage() -> void:
	if executing and attack_stage == 1:
		was_hit = true

func _Update(_delta) -> void:
	process_gravity(_delta)

	if attack_stage == 0:
		play_animation("guard_prepare")
		guard_sfx.play_rp()
		next_attack_stage()

	elif attack_stage == 1: # Counter window
		if has_finished_last_animation():
			play_animation_once("guard_loop")

		if was_hit:
			go_to_attack_stage(3) # Trigger counter
		elif timer > counter_window:
			go_to_attack_stage(5) # Window expired

	elif attack_stage == 3: # Counter slash
		play_animation("dash_slash_1")
		counter_hitbox.activate()
		slash_sfx.play_rp(0.03)
		screenshake()
		tween_speed(350, 0, 0.3)
		next_attack_stage()

	elif attack_stage == 4 and has_finished_last_animation():
		play_animation("dash_slash_1_end")
		next_attack_stage()

	elif attack_stage == 5 and has_finished_last_animation():
		play_animation("guard_end")
		next_attack_stage()

	elif attack_stage == 6 and has_finished_last_animation():
		EndAbility()

func _Interrupt() -> void:
	._Interrupt()
	was_hit = false
	if damage_module.is_connected("took_damage", self, "_on_took_damage"):
		damage_module.disconnect("took_damage", self, "_on_took_damage")

func turn_and_face_player():
	.turn_and_face_player()
	counter_hitbox.handle_direction()
