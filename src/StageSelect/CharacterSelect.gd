extends Node2D

# Character Select Screen (X7 style)
# Player picks 2 of 3 characters before entering a stage.

const CHARACTERS := ["X", "Zero", "Axl"]
const CHAR_COLORS := {
	"X": Color(0.2, 0.4, 1.0),
	"Zero": Color(1.0, 0.2, 0.2),
	"Axl": Color(1.0, 0.6, 0.1)
}
const CHAR_COLORS_DIM := {
	"X": Color(0.1, 0.2, 0.5),
	"Zero": Color(0.5, 0.1, 0.1),
	"Axl": Color(0.5, 0.3, 0.05)
}
const LOCKED_COLOR := Color(0.25, 0.25, 0.25)

var cursor_index := 0
var selected := []  # array of character name strings
var locked := false  # prevents input during confirm/transition
var confirming := false

onready var title_label: Label = $UI/TitleLabel
onready var title_shadow: Label = $UI/TitleShadow
onready var hint_label: Label = $UI/HintLabel
onready var hint_shadow: Label = $UI/HintShadow
onready var count_label: Label = $UI/CountLabel
onready var count_shadow: Label = $UI/CountShadow

onready var slots := [$UI/Slots/Slot0, $UI/Slots/Slot1, $UI/Slots/Slot2]
onready var slot_bgs := [$UI/Slots/Slot0/BG, $UI/Slots/Slot1/BG, $UI/Slots/Slot2/BG]
onready var slot_names := [$UI/Slots/Slot0/NameLabel, $UI/Slots/Slot1/NameLabel, $UI/Slots/Slot2/NameLabel]
onready var slot_name_shadows := [$UI/Slots/Slot0/NameShadow, $UI/Slots/Slot1/NameShadow, $UI/Slots/Slot2/NameShadow]
onready var slot_status := [$UI/Slots/Slot0/StatusLabel, $UI/Slots/Slot1/StatusLabel, $UI/Slots/Slot2/StatusLabel]
onready var slot_borders := [$UI/Slots/Slot0/Border, $UI/Slots/Slot1/Border, $UI/Slots/Slot2/Border]
onready var slot_checks := [$UI/Slots/Slot0/CheckLabel, $UI/Slots/Slot1/CheckLabel, $UI/Slots/Slot2/CheckLabel]

onready var choice_sfx: AudioStreamPlayer = $ChoiceSFX
onready var pick_sfx: AudioStreamPlayer = $PickSFX
onready var cancel_sfx: AudioStreamPlayer = $CancelSFX
onready var fader: ColorRect = $UI/Fader

var flash_timer := 0.0
var flash_active := false


func _ready() -> void:
	GameManager.force_unpause()
	# Initialize slot visuals
	for i in range(3):
		var char_name = CHARACTERS[i]
		slot_names[i].text = char_name.to_upper()
		slot_name_shadows[i].text = char_name.to_upper()
		slot_status[i].text = ""
		slot_checks[i].text = ""
		slot_checks[i].visible = false

		if char_name == "X" and not GameManager.x_unlocked:
			slot_bgs[i].color = LOCKED_COLOR
			slot_status[i].text = "LOCKED"
			slot_status[i].modulate = Color(0.6, 0.6, 0.6)
		else:
			slot_bgs[i].color = CHAR_COLORS_DIM[char_name]

	# Default cursor to first unlocked character
	if not GameManager.x_unlocked:
		cursor_index = 1  # start on Zero if X is locked
	else:
		cursor_index = 0

	update_visuals()
	fade_in()


func _process(delta: float) -> void:
	if locked:
		return

	# Handle flash animation for cursor
	if flash_active:
		flash_timer += delta
		if flash_timer > 0.06:
			flash_timer = 0.0
			var border = slot_borders[cursor_index]
			border.visible = !border.visible

	handle_input()


func handle_input() -> void:
	if Input.is_action_just_pressed("move_right"):
		move_cursor(1)
	elif Input.is_action_just_pressed("move_left"):
		move_cursor(-1)
	elif Input.is_action_just_pressed("fire"):
		toggle_selection()
	elif Input.is_action_just_pressed("jump"):
		if selected.size() == 2:
			confirm_selection()
	elif Input.is_action_just_pressed("dash"):
		go_back()


func move_cursor(direction: int) -> void:
	var new_index = cursor_index + direction
	if new_index < 0:
		new_index = 2
	elif new_index > 2:
		new_index = 0
	cursor_index = new_index
	choice_sfx.play()
	update_visuals()


func toggle_selection() -> void:
	var char_name = CHARACTERS[cursor_index]

	# Check if X is locked
	if char_name == "X" and not GameManager.x_unlocked:
		cancel_sfx.play()
		return

	if char_name in selected:
		# Deselect
		selected.erase(char_name)
		choice_sfx.play()
	elif selected.size() < 2:
		# Select
		selected.append(char_name)

		# Auto-confirm when 2nd character is picked
		if selected.size() == 2:
			confirm_selection()
			return
		else:
			choice_sfx.play()
	else:
		# Already have 2 selected, can't add more
		cancel_sfx.play()
		return

	update_visuals()


func confirm_selection() -> void:
	if selected.size() != 2:
		return
	if confirming:
		return

	confirming = true
	locked = true
	pick_sfx.play()

	# Flash effect
	flash_confirm()

	# Setup tag team in GameManager
	GameManager.setup_tag_team(selected[0], selected[1])

	# Proceed after brief delay
	Tools.timer(0.8, "proceed_to_stage", self)


func flash_confirm() -> void:
	# Quick white flash then fade to black
	fader.color = Color(1, 1, 1, 0.8)
	fader.visible = true
	Tools.tween(fader, "color", Color.black, 0.6)


func proceed_to_stage() -> void:
	var stage = GameManager.pending_stage_info
	if stage and stage.should_play_stage_intro():
		GameManager.go_to_stage_intro(stage)
	elif stage:
		GameManager.start_level(stage.get_load_name())
	else:
		# Fallback - should not happen
		push_warning("CharacterSelect: No pending_stage_info found!")
		GameManager.go_to_stage_select()


func go_back() -> void:
	cancel_sfx.play()
	locked = true
	fade_out()
	Tools.timer(0.5, "return_to_stage_select", self)


func return_to_stage_select() -> void:
	GameManager.go_to_stage_select()


func update_visuals() -> void:
	for i in range(3):
		var char_name = CHARACTERS[i]
		var is_locked = (char_name == "X" and not GameManager.x_unlocked)
		var is_selected = char_name in selected
		var is_focused = (i == cursor_index)

		# Border (cursor highlight)
		slot_borders[i].visible = is_focused
		if is_focused:
			flash_active = true
			flash_timer = 0.0
			slot_borders[i].visible = true

		# Background color
		if is_locked:
			slot_bgs[i].color = LOCKED_COLOR
		elif is_selected:
			slot_bgs[i].color = CHAR_COLORS[char_name]
		elif is_focused:
			slot_bgs[i].color = CHAR_COLORS[char_name].linear_interpolate(CHAR_COLORS_DIM[char_name], 0.3)
		else:
			slot_bgs[i].color = CHAR_COLORS_DIM[char_name]

		# Check mark for selected characters
		if is_selected:
			slot_checks[i].visible = true
			var sel_index = selected.find(char_name)
			if sel_index == 0:
				slot_checks[i].text = "P1"
			else:
				slot_checks[i].text = "P2"
		else:
			slot_checks[i].visible = false
			slot_checks[i].text = ""

		# Status text
		if is_locked:
			slot_status[i].text = "LOCKED"
			slot_status[i].modulate = Color(0.6, 0.6, 0.6)
		elif is_selected:
			slot_status[i].text = ""
		else:
			slot_status[i].text = ""

	# Update count label
	count_label.text = str(selected.size()) + "/2 SELECTED"
	count_shadow.text = count_label.text

	# Update hint text
	if selected.size() < 2:
		hint_label.text = "FIRE:SELECT  DASH:BACK"
		hint_shadow.text = hint_label.text
	else:
		hint_label.text = "JUMP:CONFIRM  DASH:BACK"
		hint_shadow.text = hint_label.text


func fade_in() -> void:
	fader.color = Color.black
	fader.visible = true
	Tools.tween(fader, "color", Color(0, 0, 0, 0), 0.5)


func fade_out() -> void:
	fader.color = Color(0, 0, 0, 0)
	fader.visible = true
	Tools.tween(fader, "color", Color.black, 0.4)
