extends SimplePlayerProjectile

# CircleBlaze Charged - Large fire explosion from Flame Hyenard
# Travels shorter distance, bigger AoE explosion with heavy damage

export var travel_speed := 200.0
export var travel_time := 0.15
export var explosion_duration := 1.2
export var explosion_damage := 2.5

var target_list : Array
var interval := 0.064
var damage_timer := 0.0
var exploded := false
const continuous_damage := true
const bypass_shield := true

func _Setup() -> void:
	._Setup()
	set_horizontal_speed(travel_speed * get_facing_direction())
	modulate = Color(10, 10, 10, 1)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.white, 0.15)

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
	Event.emit_signal("screenshake", 2)

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
