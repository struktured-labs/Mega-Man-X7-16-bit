extends Particles2D

onready var bg_particles: Particles2D = $bg_particles
onready var bg: ParallaxLayer = $"../../Scenery/parallaxBackground/farthest"
onready var tween := TweenController.new(self,false)
onready var map: Node2D = $"../../Scenery/GatewayTiled"
onready var expl: AudioStreamPlayer2D = $explosion
onready var expl2: AudioStreamPlayer2D = $explosion2

func _ready() -> void:
	Event.connect("boss_death_screen_flash",self,"stop_all")

func activate() -> void:
	if not emitting:
		emitting = true
		bg_particles.emitting = true
		screenshake()
		explosion()

func deactivate() -> void:
	emitting = false
	var t = create_tween().set_parallel(true)
	t.tween_property(expl,"volume_db",-14,.5)
	t.tween_property(expl2,"volume_db",-14,.5)

var fall_velocity := 5.0
var stopped := false

func screenshake() -> void:
	if stopped:
		return
	Event.emit_signal("screenshake",0.8)
	tween.reset()
	tween.attribute("motion_offset:y",bg.motion_offset.y - fall_velocity,1.6,bg)
	tween.attribute("modulate",Color.lightpink,.8,map)
	tween.add_attribute("modulate",Color.lightgray,.8,map)
	fall_velocity = clamp(fall_velocity + 0.5,5.0,32.0)
	Tools.timer(1.6,"screenshake",self)

func explosion():
	if not stopped:
		expl.play_rp()
		Tools.timer(rand_range(0.2,0.5),"explosion2",self)
	
func explosion2():
	if not stopped:
		expl2.play_rp()
		Tools.timer(rand_range(0.2,0.5),"explosion",self)

func stop_all():
	tween.reset()
	tween.create(Tween.EASE_OUT,Tween.TRANS_SINE)
	tween.add_attribute("motion_offset:y",bg.motion_offset.y - fall_velocity,4,bg)
	bg_particles.emitting = false
	map.modulate = Color.lightgray
	stopped = true
