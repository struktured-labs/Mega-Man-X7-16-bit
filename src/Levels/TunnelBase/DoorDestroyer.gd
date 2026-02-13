extends Area2D

onready var reward_door: StaticBody2D = $"../RewardDoor"
onready var reward_door_2: StaticBody2D = $"../RewardDoor2"
onready var troia_particles: Particles2D = $troia_particles
onready var troia_particles_2: Particles2D = $troia_particles2

func _ready() -> void:
	get_parent().connect("open_doors",self,"queue_free")

func _on_DoorDestroyer_body_entered(body: Node) -> void:
	if "ThunderDancerCharged" in body.name and is_instance_valid(reward_door):
		monitoring = false
		reward_door.queue_free()
		reward_door_2.queue_free()
		Tools.timer(0.5,"deactivate_particles",self)

func deactivate_particles():
	troia_particles.emitting = false
	troia_particles_2.emitting = false
	
