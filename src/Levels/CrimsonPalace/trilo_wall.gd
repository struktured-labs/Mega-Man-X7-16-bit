extends StaticBody2D

onready var collision: CollisionShape2D = $collisionShape2D

func _ready() -> void:
	Event.connect("trilobyte_desperation",self,"activate")
	Event.connect("trilobyte_desperation_end",self,"deactivate")

func activate():
	collision.set_deferred("disabled",false)

func deactivate():
	collision.set_deferred("disabled",true)
