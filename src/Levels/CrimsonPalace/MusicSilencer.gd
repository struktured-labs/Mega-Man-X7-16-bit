extends Area2D
onready var music: AudioStreamPlayer = $"../../Music Player"

var started = false

func _on_body_entered(body: Node) -> void:
	if not started:
		started = true
		music.start_slow_fade_out()
