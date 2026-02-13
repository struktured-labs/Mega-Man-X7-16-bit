extends SimplePlayerProjectile

# CircleBlaze - Fire burst from Flame Hyenard
# Travels forward a short distance, then explodes into AoE fire damage

export var travel_speed := 280.0
export var travel_time := 0.2
export var explosion_duration := 0.8
export var explosion_damage := 1.5

var target_list : Array
var interval := 0.064
var damage_timer := 0.0
var exploded := false
const continuous_damage := true

func _Setup() -> void:
	._Setup()
	set_horizontal_speed(travel_speed * get_facing_direction())

func _Update(delta) -> void:
	._Update(delta)
	if not exploded and timer > travel_time:
		explode()
	if exploded:
		damage_timer += delta
		if damage_timer > interval:
			damage_targets_in_list()
			damage_timer = 0.0
		if timer > explosion_duration:
			destroy()

func explode() -> void:
	exploded = true
	stop()
	reset_timer()
	damage = explosion_damage
	animatedSprite.play("explode")
	$collisionShape2D.set_deferred("disabled", false)

func damage_targets_in_list() -> void:
	if target_list.size() > 0:
		for body in target_list:
			if is_instance_valid(body):
				body.damage(damage, self)

func _DamageTarget(body) -> int:
	if exploded:
		if not body in target_list:
			target_list.append(body)
		return 0
	return body.damage(damage, self)

func _OnHit(_target_remaining_HP) -> void:
	if not exploded:
		explode()

func leave(_body) -> void:
	if _body in target_list:
		target_list.erase(_body)

func set_direction(new_direction):
	facing_direction = new_direction
	if not animatedSprite:
		animatedSprite = get_node("animatedSprite")
	animatedSprite.scale.x = new_direction
