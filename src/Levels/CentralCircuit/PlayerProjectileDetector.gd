extends Area2D
export var active := true

export var projectile_name := "FireDash"
signal projectile_detected

func _on_area2D_body_entered(body: Node) -> void:
	if active:
		if projectile_name in body.name:
			emit_signal("projectile_detected")
