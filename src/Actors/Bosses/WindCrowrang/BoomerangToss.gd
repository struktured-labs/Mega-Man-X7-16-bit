extends AttackAbility

export var boomerang_projectile: PackedScene
onready var throw_sfx: AudioStreamPlayer2D = $throw_sfx

func _Setup() -> void:
	._Setup()

func _Update(delta) -> void:
	if attack_stage == 0 and has_finished_last_animation():
		play_animation_once("throw_prepare")
		next_attack_stage_on_next_frame()

	elif attack_stage == 1 and has_finished_last_animation():
		throw_sfx.play()
		play_animation_once("throw")
		create_boomerang()
		next_attack_stage_on_next_frame()

	elif attack_stage == 2 and timer > 0.8:
		play_animation_once("throw_catch")
		next_attack_stage_on_next_frame()

	elif attack_stage == 3 and has_finished_last_animation():
		play_animation_once("idle")
		EndAbility()

func create_boomerang() -> void:
	var p = instantiate_projectile(boomerang_projectile)
	p.set_horizontal_speed(300 * character.get_facing_direction())
	p.set_vertical_speed(-80)
	p.boss_ref = character
