extends SimplePlayerProjectile

# VoltTornado - Electric tornado from Tornado Tonion
# Travels forward with slight homing, multi-hit continuous damage

export var speed := 250.0
export var duration := 1.5

var target_list : Array
var interval := 0.08
var damage_timer := 0.0
const continuous_damage := true

func _Setup() -> void:
	._Setup()
	set_horizontal_speed(speed * get_facing_direction())

func _Update(delta) -> void:
	._Update(delta)
	damage_timer += delta
	if damage_timer > interval:
		damage_targets_in_list()
		damage_timer = 0.0
	if timer > duration:
		end()

func end() -> void:
	disable_damage()
	animatedSprite.play("end")
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.3)
	tween.tween_callback(self, "destroy")

func damage_targets_in_list() -> void:
	if target_list.size() > 0:
		for body in target_list:
			if is_instance_valid(body):
				body.damage(damage, self)

func _DamageTarget(body) -> int:
	if not body in target_list:
		target_list.append(body)
	return 0

func _OnHit(_target_remaining_HP) -> void:
	pass

func _OnDeflect() -> void:
	pass

func leave(_body) -> void:
	if _body in target_list:
		target_list.erase(_body)

func set_direction(new_direction):
	facing_direction = new_direction
	if not animatedSprite:
		animatedSprite = get_node("animatedSprite")
	animatedSprite.scale.x = new_direction
