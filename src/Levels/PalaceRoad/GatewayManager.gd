extends Node

# Manages Crimson Palace (X7 fortress) boss progression
var beaten_bosses : Array

func _ready() -> void:
	Event.connect("palace_boss_defeated",self,"on_boss_defeated")
	if GlobalVariables.exists("palace_bosses_beaten"):
		beaten_bosses = GlobalVariables.get("palace_bosses_beaten")

func on_boss_defeated(boss_name) -> void:
	if not boss_name in beaten_bosses:
		beaten_bosses.append(boss_name)
		GlobalVariables.set("palace_bosses_beaten",beaten_bosses)

func is_boss_defeated(boss_name) -> bool:
	return boss_name in beaten_bosses

func has_defeated_all_bosses() -> bool:
	return beaten_bosses.size() == 8

func has_defeated_red() -> bool:
	if GlobalVariables.exists("red_defeated"):
		return GlobalVariables.get("red_defeated")
	return false

func soft_reset() -> void:
	print("Reseting palace Bosses except Sigma...")
	GlobalVariables.erase("palace_bosses_beaten")
	beaten_bosses.clear()

func reset_bosses() -> void:
	print("Reseting palace Bosses...")
	GlobalVariables.erase("palace_bosses_beaten")
	GlobalVariables.erase("red_defeated")
	beaten_bosses.clear()
