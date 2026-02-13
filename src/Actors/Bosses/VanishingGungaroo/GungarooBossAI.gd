extends "res://src/Actors/Bosses/BossAI.gd"

var phase := 1
var ride_armor_active := false
var phase1_attacks := []
var phase2_attacks := []

onready var kangaroo_kick = null
onready var gun_fire = null
onready var quick_vanish = null
onready var power_punch = null
onready var ground_pound = null

func update_moveset():
	for child in get_parent().get_children():
		if child is AttackAbility:
			if child.active:
				if not child.desperation_attack and not is_ability_exception(child.name):
					attack_moveset.append(child)
				elif child.desperation_attack:
					desperation_attack = child

				child.connect("ability_end", self, "attack_ended")
				child.connect("deactivated", self, "_on_attack_deactivated", [child])

	categorize_attacks()
	decide_order_of_attacks()

func categorize_attacks() -> void:
	for attack in attack_moveset:
		match attack.name:
			"KangarooKick", "GunFire", "QuickVanish":
				phase1_attacks.append(attack)
			"PowerPunch", "GroundPound":
				phase2_attacks.append(attack)

func _physics_process(delta: float) -> void:
	check_phase_transition()
	process_next_attack(delta)

func check_phase_transition() -> void:
	if not active:
		return

	var hp_ratio = float(character.current_health) / float(character.max_health)

	if phase == 1 and hp_ratio <= 0.75:
		enter_phase2()
	elif phase == 2 and hp_ratio <= 0.5:
		pass

func enter_phase2() -> void:
	phase = 2
	ride_armor_active = true
	swap_to_phase2_moveset()
	Log("Entering Phase 2 - Ride Armor active")

func swap_to_phase2_moveset() -> void:
	attack_moveset.clear()
	for attack in phase2_attacks:
		attack_moveset.append(attack)
	attacks_used = 0
	decide_order_of_attacks()

func restore_phase1_enhanced() -> void:
	attack_moveset.clear()
	for attack in phase1_attacks:
		attack_moveset.append(attack)
	attacks_used = 0
	decide_order_of_attacks()
