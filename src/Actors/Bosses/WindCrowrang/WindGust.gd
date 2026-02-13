extends AttackAbility

export var feather_projectile: PackedScene
export var wind_zone_scene: PackedScene
var wind_active := false
var feathers_thrown := 0
onready var gust_sfx: AudioStreamPlayer2D = $gust_sfx

func _Setup() -> void:
	._Setup()
	wind_active = false
	feathers_thrown = 0

func _Update(delta) -> void:
	if attack_stage == 0 and has_finished_last_animation():
		play_animation_once("flap_wings")
		gust_sfx.play()
		next_attack_stage_on_next_frame()

	elif attack_stage == 1 and has_finished_last_animation():
		create_wind_zone()
		wind_active = true
		next_attack_stage_on_next_frame()

	elif attack_stage == 2:
		if wind_active and feathers_thrown < 2 and timer > 0.4:
			throw_feather()
			feathers_thrown += 1
		if timer > 2.0:
			wind_active = false
			next_attack_stage_on_next_frame()

	elif attack_stage == 3 and timer > 0.3:
		play_animation_once("idle")
		EndAbility()

func create_wind_zone() -> void:
	var zone = instantiate(wind_zone_scene)
	zone.global_position = character.global_position + Vector2(80 * character.get_facing_direction(), 0)
	zone.push_direction = character.get_facing_direction()
	zone.duration = 2.0

func throw_feather() -> void:
	var p = instantiate_projectile(feather_projectile)
	p.set_horizontal_speed(200 * character.get_facing_direction())
	p.set_vertical_speed(-50 + feathers_thrown * 30)

func _Interrupt() -> void:
	wind_active = false
	._Interrupt()
