extends Ability

# TagSwitch - X7 Tag-Team character switch ability
# Allows swapping between two characters mid-stage
# Bound to the "tag" input action

const SWITCH_COOLDOWN := 0.5

var last_switch_time := 0.0

func _ready() -> void:
	actions = ["tag"]
	conflicting_moves = ["Death", "Damage", "Ride", "Intro", "Finish", "Forced"]

func _StartCondition() -> bool:
	# Must be on ground
	if not character.is_on_floor():
		return false

	# Must have an inactive partner to swap with
	if not is_instance_valid(GameManager.inactive_player):
		return false

	# Must not be dead
	if not GameManager.inactive_player.has_health():
		return false

	# Cooldown check
	if OS.get_ticks_msec() - last_switch_time < SWITCH_COOLDOWN * 1000:
		return false

	# Don't switch during cutscenes or special states
	if GameManager.get_state() != "Normal":
		return false

	return true

func _Setup() -> void:
	last_switch_time = OS.get_ticks_msec()

	# Flash the active character white before swap
	if character.has_method("flash"):
		character.flash()

	# End this ability immediately before swapping
	# (because after swap, this character will be deactivated
	# and _EndCondition will never be checked)
	call_deferred("end_and_switch")

func end_and_switch() -> void:
	# End the ability on the current (soon-to-be-inactive) character
	EndAbility()

	# Perform the actual tag switch
	GameManager.perform_tag_switch()

	# Emit the tag_switch signal
	Event.emit_signal("tag_switch")

func _Update(_delta: float) -> void:
	pass

func _EndCondition() -> bool:
	# Handled via call_deferred in _Setup
	return false
