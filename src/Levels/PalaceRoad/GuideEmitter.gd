extends Node

var emitting := false

signal reached_door
const guide_particle = preload("res://src/Levels/PalaceRoad/GuidePaticle.tscn")
onready var door: StaticBody2D = $"../../Door"

func _ready() -> void:
	Event.connect("palace_capsule_teleport",self,"_on_Door_open")


func _on_BossWatcher_ready_for_battle() -> void:
	emitting = true
	Tools.timer(1.5,"emit",self)

func emit() -> void:
	if emitting:
		var particle = guide_particle.instance()
		particle._destination = door
		particle.global_position = GameManager.get_player_position()
		particle.global_position.x += 16
		connect("reached_door",particle,"end")
		get_tree().current_scene.call_deferred("add_child",particle)
		
		Tools.timer(2,"emit",self)


func _on_Door_open() -> void:
	emitting = false
	emit_signal("reached_door")
