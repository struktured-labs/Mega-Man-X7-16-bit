extends AttackAbility

# Rotating eye laser - adapted from OpticSunflower ShiningRay
export var laser_projectile : PackedScene
onready var eye_sfx: AudioStreamPlayer2D = $eye_sfx
onready var charge_sfx: AudioStreamPlayer2D = $charge_sfx
onready var tween := TweenController.new(self, false)
var laser_instance = null

func _Setup() -> void:
	turn_and_face_player()
	play_animation("eye_prepare")
	charge_sfx.play()

func _Update(_delta) -> void:
	if attack_stage == 0 and has_finished_last_animation():
		play_animation("eye_loop")
		next_attack_stage()

	elif attack_stage == 1 and timer > 0.8:
		play_animation("eye_fire")
		eye_sfx.play()
		screenshake(0.75)
		spawn_laser()
		next_attack_stage()

	elif attack_stage == 2 and timer > 3.0:
		play_animation("eye_end")
		destroy_laser()
		charge_sfx.stop()
		next_attack_stage()

	elif attack_stage == 3 and has_finished_last_animation():
		EndAbility()

func spawn_laser() -> void:
	if laser_projectile:
		laser_instance = instantiate(laser_projectile)
		laser_instance.set_creator(self)
		laser_instance.initialize(character.get_facing_direction())
		laser_instance.global_position = character.global_position
		# Rotate the laser from one side to the other
		var start_angle = deg2rad(90) * character.get_facing_direction()
		var end_angle = deg2rad(450) * character.get_facing_direction()
		tween.create(Tween.EASE_IN_OUT, Tween.TRANS_LINEAR)
		tween.add_attribute("rotation", end_angle, 2.5, laser_instance)

func destroy_laser() -> void:
	if laser_instance and is_instance_valid(laser_instance):
		laser_instance.queue_free()
		laser_instance = null

func _Interrupt():
	._Interrupt()
	destroy_laser()
	tween.reset()
