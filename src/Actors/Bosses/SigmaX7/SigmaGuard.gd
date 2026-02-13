extends AttackAbility

# DESPERATION - Guard stance + reflect projectiles + counter burst
onready var shield: Node2D = $shield
onready var burst_hitbox: Node2D = $burst_hitbox
onready var guard_sfx: AudioStreamPlayer2D = $guard_sfx
onready var burst_sfx: AudioStreamPlayer2D = $burst_sfx
onready var stun: Node2D = $"../BossStun"
var deflections := 0
const max_deflections := 3
const guard_duration := 2.0

signal ready_for_stun

func _Setup() -> void:
	character.emit_signal("damage_reduction", 0.5)
	turn_and_face_player()
	stun.deactivate()
	deflections = 0

func _Update(_delta) -> void:
	process_gravity(_delta)

	if attack_stage == 0:
		play_animation("guard_prepare")
		guard_sfx.play_rp()
		next_attack_stage()

	elif attack_stage == 1 and has_finished_last_animation():
		play_animation("guard_loop")
		shield.activate()
		next_attack_stage()

	elif attack_stage == 2: # Guard window
		if deflections >= max_deflections or timer > guard_duration:
			shield.deactivate()
			go_to_attack_stage(3) # Counter burst
		# deflections tracked via shield signal

	elif attack_stage == 3:
		play_animation("cannon_start")
		burst_hitbox.activate()
		burst_sfx.play_rp()
		screenshake()
		emit_signal("ready_for_stun")
		next_attack_stage()

	elif attack_stage == 4 and has_finished_last_animation():
		play_animation("cannon_end")
		next_attack_stage()

	elif attack_stage == 5 and has_finished_last_animation():
		EndAbility()

func _Interrupt():
	._Interrupt()
	shield.deactivate()
	stun.activate()
	character.emit_signal("damage_reduction", 1)

func on_shield_deflect() -> void:
	deflections += 1
