extends SimplePlayerProjectile

# GaeaShield Charged - Rock projectile from Soldier Stonekong
# Launches forward, splits into fragments on hit or at max range

const speed := 280.0
const split_distance := 140.0
const fragment_speed := 200.0
const num_fragments := 4
var start_x := 0.0
var has_split := false

func _Setup() -> void:
	._Setup()
	start_x = global_position.x
	set_horizontal_speed(speed * get_facing_direction())

func _Update(delta) -> void:
	._Update(delta)
	if not ending and not has_split:
		var distance = abs(global_position.x - start_x)
		if distance >= split_distance:
			split()

func split() -> void:
	if has_split:
		return
	has_split = true
	# Create fragment projectiles in spread pattern
	var angles = [-0.6, -0.2, 0.2, 0.6]
	for angle in angles:
		var fragment = duplicate()
		get_parent().add_child(fragment)
		fragment.global_position = global_position
		fragment.has_split = true
		fragment.set_horizontal_speed(fragment_speed * cos(angle) * get_facing_direction())
		fragment.set_vertical_speed(fragment_speed * sin(angle))
		fragment.damage = damage * 0.5
		# Auto-destroy fragments after time
		Tools.timer(0.8, "destroy", fragment)
	disable_visuals()

func _OnHit(_target_remaining_HP) -> void:
	if not has_split:
		split()
	else:
		disable_visuals()

func set_direction(new_direction):
	facing_direction = new_direction
	if not animatedSprite:
		animatedSprite = get_node("animatedSprite")
	animatedSprite.scale.x = new_direction
