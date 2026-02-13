extends SimplePlayerProjectile

# Explosion - Slow large blast from Vanishing Gungaroo
# Big projectile, slow travel, high damage

const speed := 120.0
export var lifetime := 1.5
const bypass_shield := true

func _Setup() -> void:
	._Setup()
	set_horizontal_speed(speed * get_facing_direction())

func _Update(delta) -> void:
	._Update(delta)
	if timer > lifetime and not ending:
		end()

func end() -> void:
	animatedSprite.play("end")
	disable_damage()
	stop()
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 0, 0), 0.4)
	tween.tween_callback(self, "destroy")

func _OnHit(_target_remaining_HP) -> void:
	end()

func set_direction(new_direction):
	facing_direction = new_direction
	if not animatedSprite:
		animatedSprite = get_node("animatedSprite")
	animatedSprite.scale.x = new_direction
