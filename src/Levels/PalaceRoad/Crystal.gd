extends Node2D

export var boss := "rooster"
export var color : Color
onready var animation: AnimatedSprite = $animatedSprite
onready var particles: Particles2D = $particles2D
onready var sfx: AudioStreamPlayer2D = $get
onready var light: Sprite = $light

onready var tween := TweenController.new(self,false)

func _ready() -> void:
	animation.play(boss)
	light.modulate = color

var timer := 0.0
func _physics_process(delta: float) -> void:
	timer += delta * 2
	position.y = sin(timer) * 3

func activate() -> void:
	tween.create()
	tween.set_parallel()
	tween.add_attribute("self_modulate",Color(5,5,5,1),.025,animation)
	tween.add_attribute("modulate:a",0.0,.2,animation)
	tween.add_attribute("scale",Vector2(.1,14),.2,animation)
	tween.add_attribute("self_modulate",Color(5,5,5,1),.1,light)
	tween.add_attribute("modulate:a",0.0,.2,light)
	tween.add_attribute("scale",Vector2(4,4),.2,light)
	particles.emitting = false
	sfx.play()
	Tools.timer(2,"reset",self,self,true)
	Event.emit_signal("palace_crystal_get",boss)

func reset():
	animation.scale = Vector2.ONE
	particles.emitting = true
	animation.modulate = Color.white
	animation.self_modulate = Color.white
	particles.modulate = Color.white
	light.self_modulate = Color.white
	light.modulate = color
	light.scale = Vector2.ONE
