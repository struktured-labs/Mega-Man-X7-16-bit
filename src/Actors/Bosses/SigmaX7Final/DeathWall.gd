extends Node2D

# Death wall for Apocalypse desperation attack - adapted from Lumine DeathWall
onready var damage: Node2D = $DamageOnTouch
onready var animation: AnimatedSprite = $animatedSprite
onready var tween := TweenController.new(self, false)
var active := false

func _ready() -> void:
	visible = false
	if damage:
		damage.deactivate()

func activate():
	visible = true
	active = true
	if damage:
		damage.activate()
	animation.play("idle")
	# Move toward center over time
	var target_x = position.x - (180 * scale.x)
	tween.create(Tween.EASE_IN, Tween.TRANS_LINEAR)
	tween.add_attribute("position:x", target_x, 36.0)

func deactivate():
	active = false
	if damage:
		damage.deactivate()
	tween.reset()
	# Move back out
	var out_x = position.x + (180 * scale.x)
	tween.create(Tween.EASE_OUT, Tween.TRANS_QUAD)
	tween.add_attribute("position:x", out_x, 1.5)
	Tools.timer_p(2.0, "queue_free", self)
