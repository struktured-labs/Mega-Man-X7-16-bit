extends SimplePlayerProjectile

# VoltTornado Charged - Electric field around player from Tornado Tonion
# Creates electric field centered on player position, damages nearby enemies

export var duration := 2.0

var target_list : Array
var interval := 0.08
var damage_timer := 0.0
const continuous_damage := true
const bypass_shield := true

func _Setup() -> void:
	animatedSprite.playing = true
	animatedSprite.frame = 0
	modulate = Color(10, 10, 10, 1)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.white, 0.2)

func _Update(delta) -> void:
	# Follow player position
	global_position = GameManager.get_player_position()
	damage_timer += delta
	if damage_timer > interval:
		damage_targets_in_list()
		damage_timer = 0.0
	if timer > duration:
		end()

func end() -> void:
	disable_damage()
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(0, 1, 1, 0), 0.3)
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

func set_direction(_new_direction):
	pass
