extends Particles2D


func _ready() -> void:
	pass


func _on_sandstorm_detector_body_entered(body: Node) -> void:
	emitting = true
	pass # Replace with function body.


func _on_sandstorm_detector_body_exited(body: Node) -> void:
	emitting = false
	pass # Replace with function body.
