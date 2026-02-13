extends Node2D
onready var sublight: Light2D = $Spotlight1/pathFollow2D/spotLight/sublight
onready var path: PathFollow2D = $Spotlight1/pathFollow2D
onready var spotlight: Light2D = $Spotlight1/pathFollow2D/spotLight

export var debug := false
export var path_speed := 50.0
export var inverse_speed := false

var timer := 0.0
var activated := true
var dissipated:= false
var restoring := false

var current_tween

export var _wall_enemies : Array
var wall_enemies : Array

signal alarm_activated

func _ready() -> void:
	Event.listen("alarm",self,"deactivate")
	
	for nodepath in _wall_enemies:
		wall_enemies.append(get_node(nodepath))

func _physics_process(delta: float) -> void:
	timer += delta
	if activated:
		move_and_flicker(delta)
			
func activate_doors():
	for wallenemy in wall_enemies:
		if is_instance_valid(wallenemy) and wallenemy.has_health():
			wallenemy._on_SearchLight_alarm_activated()
	

func move_and_flicker(delta) -> void:
	var speed = path_speed
	if inverse_speed:
		speed = path_speed * -1
	
	path.offset += delta * speed
	spotlight.energy = lerp(0.85, 1, sin(timer * 120))
	sublight.energy = 0.5
	sublight.scale.x = lerp(2, 2.1, sin(timer * 120))


func activate() -> void:
	debug_print("Activating")
	activated = true
	restoring = false
	timer = 0

func deactivate() -> void:
	debug_print("Deactivating due to Event alarm signal")
	activated = false
	timer = 0
	sublight.energy = 0
	spotlight.energy = 0
	Tools.timer(16,"restore_shape",self)
	Tools.timer(17,"activate",self)


func _on_playerDetector_body_entered(_body: Node) -> void:
	if activated:
		debug_print("Player collided, sending signals and starting")
		emit_signal("alarm_activated")
		Event.emit_signal("alarm")
		expand_shape()
		activate_doors()
	else:
		debug_print("Player collided, but not activated")

func expand_shape() -> void:
	spotlight.energy = 1
	debug_print("Expanding shape")
	var tween = get_tree().create_tween()
	current_tween = tween
	tween.tween_property(spotlight, "scale", Vector2(12,12), 0.25).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(spotlight, "energy", 0.0, 0.5)
	Tools.timer(16,"restore_shape",self)
	Tools.timer(17,"activate",self)

func restore_shape() -> void:
	restoring = true
	debug_print("Restoring original shape")
	var tween = get_tree().create_tween()
	current_tween = tween
	spotlight.scale = Vector2 (4,4)
	tween.tween_property(spotlight, "energy", 0.5, 0.95).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(spotlight, "scale", Vector2(1,1), 0.95).set_trans(Tween.TRANS_QUAD)
	#tween.tween_callback(self,"activate")

func debug_print(message) -> void:
	if debug:
		print(name +": " +str(message))
