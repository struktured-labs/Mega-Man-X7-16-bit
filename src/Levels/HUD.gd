extends CanvasLayer
var timer := 0.0
export var checked_inputs : Array
export var show_boss_bar := true
onready var x_info = $"X Debug Info"
onready var i_info = $"Input Info"
onready var b_info = $"Boss and Weapon Info"
onready var chronometer: RichTextLabel = $Chronometer
onready var boss_bar = $"Boss Bar"
onready var boss_hp: TextureProgress = $"Boss Bar/textureProgress"


onready var player_bar = $"X Bar"
onready var player_hp: TextureProgress = $"X Bar/textureProgress"
onready var player_healable: TextureProgress = $"X Bar/textureProgress2"


onready var ride_bar: NinePatchRect = $"Ride Bar"
onready var ride_hp: TextureProgress = $"Ride Bar/textureProgress"


onready var rec_info: RichTextLabel = $"Rec Info"
onready var reploid_counter: Label = $"ReploidCounter"

onready var black_screen = $BlackScreen
onready var white_screen = $WhiteScreen
var boss_hp_filled := false
var boss_filling_hp := 0
var boss
var action_debug := false
var action_debug2 := false
var frame_skip := 1
var black_screen_alpha := 1.4
var fade_out := false

var playerbar_blinking := false
var blink_timer := 0.0
var debugging_character 
var chronometering := true
var chronotimer := 0.0

var last_message

var ride_hp_tween : SceneTreeTween

# Tag-team partner health indicator
var partner_bar_label : Label
var partner_bar_created := false

func show_rng():
	rec_info.text = "BossRNG: " + str(BossRNG.seed_rng)

func show_boss_attack(boss_name,attack_order):
	show_rng()
	rec_info.text += " " + boss_name + ": " + attack_order

func _ready() -> void:
	Tools.timer(0.1,"show_rng",self)
	black_screen.visible = true
	white_screen.visible = false
	boss_hp_filled = false
	if show_boss_bar:
		Event.listen("boss_health_appear",self,"setup_boss_health")
		Event.listen("boss_health_hide",self,"hide_boss_hp")
	Event.listen("healable_amount",self,"on_healable_amount")
	Event.listen("disabled_lifesteal",self,"hide_healable_amount")
	Event.listen("rescue_reploid",self,"update_reploid_counter")
	Event.listen("fade_out",self,"start_fade_out")
	Event.listen("final_fade_out",self,"start_final_fade_out")
	Event.listen("new_camera_focus",self,"change_camera_focus")
	Event.connect("final_fade_out",self,"stop_chronometer")
	#Event.listen("player_death",self,"stop_chronometer")
	#Event.listen("enemy_kill",self,"try_stop_chronometer")
	BossRNG.connect("updated_rng",self,"show_rng")
	BossRNG.connect("decided_boss_order",self,"show_boss_attack")
	Event.listen("tag_switch",self,"on_tag_switch")
	call_deferred("connect_debug")
	call_deferred("on_showdebug","ShowDebug")
	call_deferred("update_reploid_counter")
	call_deferred("setup_partner_bar")

func connect_debug():
	Configurations.listen("value_changed",self,"on_showdebug")

func on_showdebug(key) -> void:
	if key == "ShowDebug":
		if Configurations.get(key):
			show_debug()
		else:
			show_debug(false)

func show_debug(show = true) -> void:
	x_info.visible = show
	i_info.visible = show
	b_info.visible = show
	rec_info.visible = show
	chronometer.visible = show
#	v_box_container.visible = show

func stop_chronometer() -> void:
	chronometering = false

func try_stop_chronometer(_boss) -> void:
	if _boss is String and _boss == "boss":
		stop_chronometer()

func change_camera_focus(new_focus):
	debugging_character = new_focus
	if new_focus == GameManager.player:
		tween_focus_on_bar(player_bar,ride_bar,-14,Color.white)
	else:
		tween_focus_on_bar(ride_bar,player_bar,13,Color.gray)
		pass

func tween_focus_on_bar(focus_bar,other_bar,x_pos,color) -> void: #TODO: move to Bars ControlNode
		if ride_hp_tween:
			ride_hp_tween.kill()
		ride_hp_tween = create_tween()
		ride_hp_tween.set_parallel() # warning-ignore:return_value_discarded
		ride_hp_tween.tween_property(focus_bar,"rect_position:x",8,0.2) # warning-ignore:return_value_discarded
		ride_hp_tween.tween_property(other_bar,"rect_position:x",x_pos,0.2) # warning-ignore:return_value_discarded
		ride_hp_tween.tween_property(player_bar,"modulate:r",color.r,0.2) # warning-ignore:return_value_discarded
		ride_hp_tween.tween_property(player_bar,"modulate:g",color.g,0.2) # warning-ignore:return_value_discarded
		ride_hp_tween.tween_property(player_bar,"modulate:b",color.b,0.2) # warning-ignore:return_value_discarded

func setup_boss_health(_boss):
	boss = _boss
	boss.get_node("Damage").connect("took_damage",boss_bar,"blink")

func show_debug_text() -> void:
	if is_instance_valid(debugging_character):
		x_info.text = debugging_character.send_debug_info()
	elif is_instance_valid(GameManager.player):
		debugging_character = GameManager.player
	else:
		x_info.text = "No Character to debug"

func start_fade_out() -> void:
	fade_out = true
	
var fade_out_to_white := false

func start_final_fade_out() -> void:
	fade_out = true
	fade_out_to_white = true

func process_fade(delta):
	if fade_out and black_screen_alpha < 1:
		if GameManager.player.is_executing("Death"):
			white_screen.visible = true
		black_screen.visible = true
		black_screen_alpha += delta * 2
		fade()
	elif fade_out and black_screen_alpha >= 1:
		GameManager.finished_fade_out()
	elif not fade_out and black_screen_alpha > 0:
		black_screen_alpha -= delta * 2
		call_deferred("fade")

func _process(delta: float) -> void:
	process_fade(delta)
	process_player_bar_size()
	process_blink(delta)
	update_partner_bar()

	i_info.text = "Inputs:" + show_input_info()
	b_info.text = "FPS: " + str(Engine.get_frames_per_second())
	b_info.text += "\n" + show_boss_health_and_weapon(delta)

	timer += delta
	if chronometering:
		chronotimer += delta
		chronometer.text = Tools.get_readable_time(chronotimer)
	show_debug_text()

func process_player_bar_size():
	if is_instance_valid(GameManager.player):
		var health_rect_pos = 56 - (GameManager.player.max_health - 16) * 2
		var health_rect_size = 52 + (GameManager.player.max_health - 16) * 2
		if player_bar.rect_position.y != health_rect_pos:
			blink_player_bar()
			player_bar.rect_position.y = health_rect_pos
			player_bar.rect_size.y = health_rect_size
		
func process_blink(delta):
	if playerbar_blinking:
		blink_timer += delta
		if blink_timer > 0.04:
			stop_blink_player_bar()

func hide_boss_hp():
	boss_bar.visible = false
	boss_hp_filled = false
	boss_filling_hp = 0
	boss = null

func stop_blink_player_bar():
	playerbar_blinking = false
	player_bar.material.set_shader_param("Flash",0)
	blink_timer = 0

func blink_player_bar():
	playerbar_blinking = true
	player_bar.material.set_shader_param("Flash",1)

func fade():
	if fade_out_to_white:
		black_screen.color = Color(1,1,1,black_screen_alpha)
	else:
		black_screen.color = Color(0,0,0,black_screen_alpha)

func on_healable_amount(param):
	call_deferred("show_healable_amount",param)

func show_healable_amount(healable_amount):
	player_healable.value = GameManager.player.current_health + healable_amount

func hide_healable_amount() -> void:
	player_healable.value = 0

func show_boss_health_and_weapon(delta) -> String:
	var text := ""
	if is_instance_valid(GameManager.player):
		var health = GameManager.player.current_health
		if health > GameManager.player.max_health:
			player_hp.modulate = Color.deepskyblue
		else:
			player_hp.modulate = Color.white
		player_hp.value = clamp(health,0,GameManager.player.max_health)
		if health <= 0:
			hide_healable_amount()
	if is_instance_valid(GameManager.player) and is_instance_valid(GameManager.player.ride):
		var health = GameManager.player.ride.current_health
		ride_hp.value = ceil(health/2)
		
	if is_instance_valid(boss):
		boss_bar.visible = true
		if not boss_hp_filled:
			fill_boss_hp(delta)
		else:
			boss_hp.value = ceil((boss.current_health * 32)/ boss.max_health)
			if boss_hp.value <= 1 and boss.current_health > 1:
				boss_hp.value = 2
	return text

func fill_boss_hp(_delta):
	boss_hp.value = boss_filling_hp
	if timer > 0.033:
		boss_filling_hp += 1
		$audioStreamPlayer.volume_db = -18
		$audioStreamPlayer.play()
		timer = 0
	
	if boss_filling_hp >= 32:
		boss_hp_filled = true
	

func show_input_info() -> String:
	var text := ""
	for action in checked_inputs:
		if Input.is_action_pressed(action):
			if action == "move_left":
				text += "<"
			elif action == "move_right":
				text += ">"
			elif action == "weapon_select_left":
				text += "L"
			elif action == "weapon_select_right":
				text += "R"
			else:
				text += action.left(1)
		else:
			text += "."
	
	
		#if Input.is_action_just_released("jump"):
		#	Log("jump_rls")
	return text

func update_reploid_counter() -> void:
	var count = GameManager.get_rescued_count()
	reploid_counter.text = "R:" + str(count).pad_zeros(2) + "/64"
	reploid_counter.visible = count > 0

# --- Tag-Team Partner Bar ---

func setup_partner_bar() -> void:
	if partner_bar_created:
		return
	# Create a small label to show partner name + health
	partner_bar_label = Label.new()
	partner_bar_label.name = "PartnerBar"
	partner_bar_label.rect_position = Vector2(8, 112)
	partner_bar_label.rect_size = Vector2(60, 14)
	partner_bar_label.visible = false
	# Use the same font as other HUD elements if available
	var font = reploid_counter.get("custom_fonts/font")
	if font:
		partner_bar_label.set("custom_fonts/font", font)
	partner_bar_label.set("custom_colors/font_color", Color(0.7, 0.85, 1.0, 1.0))
	add_child(partner_bar_label)
	partner_bar_created = true

func on_tag_switch() -> void:
	# Update the ride bar to show partner health instead when tag-team is active
	pass

func update_partner_bar() -> void:
	if not partner_bar_created or not is_instance_valid(partner_bar_label):
		return

	if not GameManager.is_tag_team_active():
		partner_bar_label.visible = false
		return

	var partner = GameManager.get_inactive_player()
	if not is_instance_valid(partner):
		partner_bar_label.visible = false
		return

	partner_bar_label.visible = true
	var health_pct = partner.current_health / partner.max_health
	var bar_length := 8
	var filled = int(health_pct * bar_length)
	var empty_count = bar_length - filled
	var bar_text = ""
	for _i in range(filled):
		bar_text += "|"
	for _i in range(empty_count):
		bar_text += "."

	# Show partner name abbreviation + health bar
	var partner_name = partner.name.left(1)
	partner_bar_label.text = partner_name + "[" + bar_text + "]"

	# Color based on health
	if health_pct > 0.5:
		partner_bar_label.set("custom_colors/font_color", Color(0.7, 0.85, 1.0, 1.0))
	elif health_pct > 0.25:
		partner_bar_label.set("custom_colors/font_color", Color(1.0, 0.85, 0.3, 1.0))
	else:
		partner_bar_label.set("custom_colors/font_color", Color(1.0, 0.3, 0.3, 1.0))

	# Also show partner health on the Ride Bar when no ride armor is active
	if GameManager.is_tag_team_active():
		if not is_instance_valid(GameManager.player) or not is_instance_valid(GameManager.player.ride):
			ride_bar.visible = true
			ride_hp.value = ceil((partner.current_health / partner.max_health) * 32)

# --- End Tag-Team Partner Bar ---

func Log(message):
	if last_message != message:
		print_debug(message)
		last_message = message


