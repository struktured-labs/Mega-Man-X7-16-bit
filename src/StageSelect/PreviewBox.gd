extends AnimatedSprite

onready var level_preview: Sprite = $level_preview
onready var tween := TweenController.new(self,false)
onready var final_position := position
export var buttons : NodePath
export var map : NodePath
onready var o_map_position = get_node(map).global_position
var exceptions := ["PalaceRoad","CrimsonPalace"]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("alt_fire"):
		increase()

func connect_with_buttons():
	for child in get_node(buttons).get_children():
		if child.has_signal("stage_selected"):
			child.connect("stage_selected",self,"on_stage_selected")
		else:
			child.connect("focus_entered",self,"hide")

func on_stage_selected(info:StageInfo):
	if info.get_load_name() in exceptions:
		hide()
	else:
		level_preview.texture = info.preview
		increase(info.pointer_position + o_map_position)
	pass

func hide():
	visible = false

func _ready() -> void:
	hide()
	connect_with_buttons()

func increase(initial_position := Vector2(200,118)):
	visible = true
	#blinking = false
	level_preview.visible = false
	position = initial_position
	tween.reset()
	tween.attribute("position",final_position,.65)
	tween.add_callback("show_preview")
	tween.add_callback("start_blink")
	frame = 0

func show_preview():
	level_preview.visible = true

var blinking := false

func start_blink():
	if not blinking:
		blinking = true
		blink()

func blink():
	if blinking:
		if modulate.a == 0.75:
			modulate.a = 0.6
		else:
			modulate.a = 0.75
		Tools.timer(0.032,"blink",self)
	else:
		modulate.a = 1.0
