extends Area2D

var push_direction := 1
var push_force := 150.0
var duration := 2.0
var elapsed := 0.0

func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")

func _physics_process(delta: float) -> void:
	elapsed += delta
	if elapsed >= duration:
		queue_free()
		return

	for body in get_overlapping_bodies():
		if body.is_in_group("Player"):
			if body.has_method("add_bonus_velocity"):
				body.add_bonus_velocity(Vector2(push_force * push_direction * delta, 0))
			elif "velocity" in body:
				body.velocity.x += push_force * push_direction * delta

func _on_body_entered(_body) -> void:
	pass

func _on_body_exited(_body) -> void:
	pass
