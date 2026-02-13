extends Sprite

onready var tween := TweenController.new(self,false)

export var speed := 80

func _ready() -> void:
	descent()

func descent():
	tween.reset()
	tween.attribute("region_rect:position:y",region_rect.position.y +speed,1.0)
	Tools.timer(1.0,"descent",self)
	
