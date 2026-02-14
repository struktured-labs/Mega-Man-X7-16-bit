extends Ability

# Axl's Copy Shot - fires a special bullet that captures enemy DNA
# Input: alt_fire action
# Slower bullet, same damage, 1 second cooldown
# On kill: enemy drops DNACore pickup

export var copy_bullet_scene : PackedScene
export var cooldown_time := 1.0
var cooldown_timer := 0.0
var can_fire := true

func _physics_process(delta: float) -> void:
	if cooldown_timer > 0:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			cooldown_timer = 0
			can_fire = true

func _StartCondition() -> bool:
	if can_fire:
		if character.has_control():
			return true
	return false

func _Setup() -> void:
	fire_copy_bullet()
	can_fire = false
	cooldown_timer = cooldown_time

func fire_copy_bullet() -> void:
	if not copy_bullet_scene:
		return
	var bullet = copy_bullet_scene.instance()
	get_tree().current_scene.add_child(bullet, true)
	bullet.global_position = character.global_position
	var dir = character.get_facing_direction()
	bullet.projectile_setup(dir, character.shot_position.position)

func _Update(_delta: float) -> void:
	pass

func _EndCondition() -> bool:
	return true

func play_animation_on_initialize():
	pass
