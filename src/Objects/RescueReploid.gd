extends Area2D

export var reploid_id := "reploid_0"
export var reward_type := "none" # "none", "life_up", "extra_life"

var rescued := false
var dead := false
var bob_offset := 0.0
var base_y := 0.0
var flash_timer := 0.0
var flash_count := 0

const LIFE_UP_SCENE = preload("res://src/Objects/LifeUp.tscn")
const EXTRA_LIFE_SCENE = preload("res://src/Objects/Pickups/ExtraLife.tscn")

func _ready() -> void:
	base_y = position.y
	if GameManager.is_reploid_rescued(reploid_id):
		queue_free()
		return
	$AnimatedSprite.play("default")

func _physics_process(delta: float) -> void:
	if rescued or dead:
		return
	bob_offset += delta * 3.0
	position.y = base_y + sin(bob_offset) * 2.0

func _on_PlayerDetector_body_entered(body: Node) -> void:
	if rescued or dead:
		return
	if body.is_in_group("Player"):
		rescue()

func _on_EnemyDetector_body_entered(body: Node) -> void:
	if rescued or dead:
		return
	if body.is_in_group("Enemy"):
		die()

func rescue() -> void:
	rescued = true
	$AnimatedSprite.modulate = Color(1, 1, 1, 1)
	GameManager.rescue_reploid(reploid_id)
	Event.emit_signal("rescue_reploid")
	spawn_reward()
	$RescueSound.play()
	flash_and_free()

func die() -> void:
	dead = true
	$AnimatedSprite.modulate = Color(1, 0.3, 0.3, 1)
	flash_and_free()

func flash_and_free() -> void:
	var tween = create_tween()
	tween.tween_property($AnimatedSprite, "modulate:a", 0.0, 0.5)
	tween.tween_callback(self, "queue_free")

func spawn_reward() -> void:
	match reward_type:
		"life_up":
			var life_up = LIFE_UP_SCENE.instance()
			life_up.collectible_name = "reploid_life_up_" + reploid_id
			life_up.global_position = global_position + Vector2(0, -8)
			get_parent().add_child(life_up)
		"extra_life":
			var extra = EXTRA_LIFE_SCENE.instance()
			extra.global_position = global_position + Vector2(0, -8)
			get_parent().add_child(extra)
