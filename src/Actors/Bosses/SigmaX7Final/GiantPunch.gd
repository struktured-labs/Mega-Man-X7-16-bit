extends AttackAbility

# Giant fist slam - adapted from Lumine ParadiseDive
export var shockwave : PackedScene
onready var punch_sfx: AudioStreamPlayer2D = $punch_sfx
onready var land_sfx: AudioStreamPlayer2D = $land_sfx
onready var tween := TweenController.new(self, false)

func _Setup() -> void:
	turn_and_face_player()
	play_animation("punch_prepare")

func _Update(_delta) -> void:
	if attack_stage == 0 and has_finished_last_animation():
		play_animation("punch_prepare_loop")
		next_attack_stage()

	elif attack_stage == 1 and timer > 0.6:
		play_animation("punch")
		punch_sfx.play_rp()
		set_vertical_speed(900)
		pursue_player_x(0.1)
		next_attack_stage()

	elif attack_stage == 2:
		if character.is_on_floor() or timer > 3:
			play_animation("punch_land")
			land_sfx.play_rp()
			screenshake(2.0)
			set_vertical_speed(0)
			force_movement(0)
			spawn_shockwave()
			next_attack_stage()

	elif attack_stage == 3 and has_finished_last_animation():
		play_animation("punch_rise")
		next_attack_stage()

	elif attack_stage == 4 and has_finished_last_animation():
		EndAbility()

func pursue_player_x(lerp_amount : float) -> void:
	var target_x = GameManager.get_player_position().x
	var diff = target_x - character.global_position.x
	force_movement(diff * lerp_amount * 60)

func spawn_shockwave() -> void:
	if shockwave:
		var wave_l = instantiate(shockwave)
		wave_l.set_creator(self)
		wave_l.initialize(-1)
		wave_l.set_horizontal_speed(-250)

		var wave_r = instantiate(shockwave)
		wave_r.set_creator(self)
		wave_r.initialize(1)
		wave_r.set_horizontal_speed(250)

func _Interrupt():
	._Interrupt()
	tween.reset()
