extends Ability

# Souenbu (from Crowrang) - Boomerang blade toss
# Press select_special -> throws a blade that returns to Zero

export var projectile_scene : PackedScene
export var ammo_cost := 3.0
export var duration := 0.3

var ex_gauge_node

func _ready() -> void:
	ex_gauge_node = get_parent().get_node_or_null("EXGauge")

func _StartCondition() -> bool:
	if character.is_on_floor():
		if has_ammo():
			return true
	return false

func has_ammo() -> bool:
	if ex_gauge_node:
		return ex_gauge_node.current_ammo >= ammo_cost
	return true

func consume_ammo() -> void:
	if ex_gauge_node:
		ex_gauge_node.reduce_ammo(ammo_cost)

func _Setup() -> void:
	consume_ammo()
	fire_projectile()

func fire_projectile() -> void:
	if projectile_scene:
		var proj = projectile_scene.instance()
		get_tree().current_scene.get_node("Objects").call_deferred("add_child", proj, true)
		proj.global_position = character.global_position + Vector2(
			10 * character.get_facing_direction(), -4)
		if proj.has_method("initialize"):
			proj.call_deferred("initialize", character.get_facing_direction())
		if proj.has_method("set_creator"):
			proj.set_creator(character)
		# Pass owner reference for boomerang return
		if proj.has_method("set_return_target"):
			proj.set_return_target(character)

func _EndCondition() -> bool:
	return timer >= duration

func _Interrupt() -> void:
	pass

func play_animation_on_initialize():
	character.play_animation("slash2")
