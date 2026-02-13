extends Control

onready var tween := TweenController.new(self,false)
onready var progress: TextureProgress = $textureProgress

var state := "none"

func _ready() -> void:
	visible = false

func fill(timer) -> void:
	progress.value = timer*50

func fadeout() -> void:
	if state != "fadeout":
		state = "fadeout"
		tween.reset()
		tween.attribute("modulate:a",0,.1)
	
func fadein() -> void:
	if state != "fadein":
		visible = true
		state = "fadein"
		tween.reset()
		tween.attribute("modulate:a",1,.1)
