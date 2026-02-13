extends AttackAbility

export (PackedScene) var clone_scene
var clones := []

func _Setup() -> void:
	._Setup()
	clones.clear()

func _Update(_delta) -> void:
	process_gravity(_delta)

	if attack_stage == 0:
		# Animation prepare
		play_animation_once("idle")
		next_attack_stage()

	elif attack_stage == 1 and timer > 0.5:
		# Spawn 2 clones at left/right positions
		spawn_clones()
		next_attack_stage()

	elif attack_stage == 2:
		# Wait for clones to finish their attack and disappear
		if timer > 3.0 or all_clones_gone():
			cleanup_clones()
			play_animation_once("idle")
			next_attack_stage()

	elif attack_stage == 3 and timer > 0.3:
		EndAbility()

func spawn_clones() -> void:
	var left_pos = character.global_position + Vector2(-80, 0)
	var right_pos = character.global_position + Vector2(80, 0)

	var clone1 = clone_scene.instance()
	get_tree().current_scene.add_child(clone1, true)
	clone1.global_position = left_pos
	clones.append(clone1)
	character.listen("zero_health", clone1, "auto_destruct")

	var clone2 = clone_scene.instance()
	get_tree().current_scene.add_child(clone2, true)
	clone2.global_position = right_pos
	clones.append(clone2)
	character.listen("zero_health", clone2, "auto_destruct")

func all_clones_gone() -> bool:
	for clone in clones:
		if is_instance_valid(clone):
			return false
	return true

func cleanup_clones() -> void:
	for clone in clones:
		if is_instance_valid(clone):
			clone.queue_free()
	clones.clear()

func _Interrupt() -> void:
	._Interrupt()
	cleanup_clones()
	kill_tweens(tween_list)
