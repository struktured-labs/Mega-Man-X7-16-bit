extends Enemy

# Fire wall that rises from the ground - adapted from BurnRooster's RisingLava
onready var damage_on_touch: Node2D = $DamageOnTouch

func _ready() -> void:
	pass

func on_boss_death():
	damage_on_touch.deactivate()
	modulate = Color(1, 1, 1, 0.01)
	animatedSprite.playing = false
	Tools.timer(4, "end", self)

func end():
	queue_free()

func auto_destruct():
	queue_free()
