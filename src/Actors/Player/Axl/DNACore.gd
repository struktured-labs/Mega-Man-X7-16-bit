extends Area2D

# DNA Core pickup - dropped when enemy killed by Copy Shot
# Auto-collected on player touch, stores enemy type for A-Trans

export var float_duration := 4.0
export var float_speed := 20.0
var enemy_name := "Unknown"
var timer := 0.0
var collected := false

func _ready() -> void:
	connect("body_entered", self, "_on_body_entered")

func _physics_process(delta: float) -> void:
	if collected:
		return

	timer += delta

	# Float upward briefly then hover
	if timer < 0.5:
		position.y -= float_speed * delta
	else:
		# Bob up and down
		position.y += sin(timer * 4.0) * 0.5

	# Blink and expire
	if timer > float_duration * 0.75:
		visible = fmod(timer * 10.0, 1.0) > 0.5
	if timer > float_duration:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if not collected and body.is_in_group("Player"):
		collected = true
		visible = false
		# Store DNA in Axl
		if body.has_method("store_dna"):
			body.store_dna(enemy_name)
		elif GameManager.player.has_method("store_dna"):
			GameManager.player.store_dna(enemy_name)
		queue_free()
