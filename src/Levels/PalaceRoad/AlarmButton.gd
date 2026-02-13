extends AnimatedSprite

var active := false
onready var blockage: Node2D = $"../../Scenery/GatewayTiled/Blockage"

onready var collider: CollisionShape2D = $"../../Scenery/GatewayTiled/Blockage/staticBody2D/collisionShape2D"

func _ready() -> void:
	if GatewayManager.has_defeated_red():
		activate()

func activate():
	active = true
	visible = true

func set_alarm_off():
	active = false
	play("down")
	Event.emit_signal("palace_final_section")
	blockage.visible = true
	collider.set_deferred("disabled",false)


func _on_area2D_body_entered(body: Node) -> void:
	if active:
		set_alarm_off()
