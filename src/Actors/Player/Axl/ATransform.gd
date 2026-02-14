extends Ability

# Axl's A-Trans (transformation) system
# Collecting DNA Core enables transformation into that enemy
# While transformed: looks like enemy, has 1 special ability
# Ends on: damage, press transform again, or 15 seconds

export var max_transform_time := 15.0
var is_transformed := false
var transform_enemy := ""
var original_sprite_visible := true

func _StartCondition() -> bool:
	if is_transformed:
		# Press again to cancel transform
		return true
	if character.has_method("has_stored_dna"):
		if character.has_stored_dna():
			return true
	return false

func _Setup() -> void:
	if is_transformed:
		# Cancel transform
		end_transform()
		EndAbility()
		return
	# Start transform
	start_transform()

func start_transform() -> void:
	is_transformed = true
	if character.has_method("get_stored_dna"):
		transform_enemy = character.get_stored_dna()
	if character.has_method("clear_dna"):
		character.clear_dna()

	# Visual: apply enemy overlay tint
	character.animatedSprite.modulate = Color(0.6, 0.8, 0.6, 1.0)
	character.is_transformed = true

func end_transform() -> void:
	is_transformed = false
	transform_enemy = ""
	character.animatedSprite.modulate = Color(1, 1, 1, 1)
	character.is_transformed = false

func _Update(_delta: float) -> void:
	# End after max time
	if timer > max_transform_time:
		end_transform()
		EndAbility()
		return

func _EndCondition() -> bool:
	if not is_transformed:
		return true
	return false

func _Interrupt() -> void:
	if is_transformed:
		end_transform()

func play_animation_on_initialize():
	pass

# Called externally when Axl takes damage while transformed
func on_damage_while_transformed() -> void:
	if is_transformed and executing:
		end_transform()
		EndAbility()
