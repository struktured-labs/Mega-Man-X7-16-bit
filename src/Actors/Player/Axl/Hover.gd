extends Movement

# Axl's Hover ability - replaces AirDash
# Hold jump while airborne and falling to hover
# Significantly reduces gravity for 1.5 seconds max
# Fuel system: drains while hovering, refills on ground

export var max_hover_time := 1.5
export var hover_gravity_factor := 0.1
export var fuel_refill_rate := 1.0
var hover_fuel := 1.5
var is_hovering := false

func _ready() -> void:
	hover_fuel = max_hover_time
	character.listen("land", self, "on_land")

func on_land() -> void:
	is_hovering = false

func _physics_process(delta: float) -> void:
	# Refill fuel when on ground
	if character.is_on_floor() and not executing:
		hover_fuel = min(hover_fuel + fuel_refill_rate * delta, max_hover_time)

func _StartCondition() -> bool:
	if not character.is_on_floor():
		if character.get_vertical_speed() > 0: # falling
			if hover_fuel > 0:
				if not character.is_colliding_with_wall():
					return true
	return false

func should_execute_on_hold() -> bool:
	return true

func _Setup() -> void:
	is_hovering = true
	character.set_vertical_speed(0)

func _Update(_delta: float) -> void:
	# Drain fuel
	hover_fuel -= _delta
	if hover_fuel <= 0:
		hover_fuel = 0
		EndAbility()
		return

	# Reduced gravity hover
	var hover_grav = default_gravity * hover_gravity_factor
	character.add_vertical_speed(hover_grav * _delta)
	if character.get_vertical_speed() > 60:
		character.set_vertical_speed(60) # cap descent speed while hovering

	# Allow horizontal movement while hovering
	set_movement_and_direction(horizontal_velocity, _delta)

func _EndCondition() -> bool:
	if character.is_on_floor():
		return true
	if hover_fuel <= 0:
		return true
	if not Is_Input_Happening():
		return true
	# End if player grabs a wall
	if character.is_colliding_with_wall() != 0:
		if character.get_pressed_axis() == character.is_colliding_with_wall():
			return true
	return false

func _Interrupt() -> void:
	is_hovering = false
	character.set_horizontal_speed(0)

func Has_time_ran_out() -> bool:
	return timer > max_hover_time

func play_animation_on_initialize():
	character.play_animation("fall")
