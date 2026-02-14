extends Node

const path := "user://savegame.save"
const save_version := 0.4
var game_data = {}

signal loaded
signal saved

func save() -> void:
	print("Save: Saving...")
	set_all_data()
	write_to_file()
	emit_signal("saved")

func set_all_data() -> void:
	game_data["version"] = save_version
	game_data["collectibles"] = GameManager.collectibles
	game_data["variables"] = GlobalVariables.variables
	game_data["configs"] = Configurations.variables
	game_data["keys"] = InputManager.modified_keys
	game_data["achievements"] = Achievements.export_unlocked_list()
	game_data["rescued_reploids"] = GameManager.rescued_reploids
	game_data["x_unlocked"] = GameManager.x_unlocked

func write_to_file() -> void:
	var file = File.new()
	file.open(path, file.WRITE)
	file.store_var(game_data)
	file.close() 

func load_from_file() -> void:
	var file = File.new()
	if not file.file_exists(path):
		print("Save: No savefile detected")
		clear_save()
	file.open(path, File.READ)
	game_data = file.get_var()
	file.close()

func load_save():
	print("Save: Loading...")
	load_from_file()
	apply_data()
	emit_signal("loaded")

func clear_save():
	print("Save: Creating new savefile")
	game_data = {
		"version": save_version,
		"collectibles" : [],
		"variables" : {},
		"configs" : {},
		"keys" : {},
		"achievements" : {},
		"rescued_reploids" : {},
		"x_unlocked" : false
	}
	InputMap.load_from_globals()
	write_to_file()

func clear_game_data() -> void:
	print("Save: clearing game data")
	set_all_data()
	game_data["collectibles"] = []
	game_data["variables"] = {}
	game_data["rescued_reploids"] = {}
	game_data["x_unlocked"] = false
	apply_data()
	GatewayManager.reset_bosses()
	IGT.reset()
	write_to_file()

func clear_keybinds() -> void:
	print("Save: clearing keybinds")
	set_all_data()
	game_data["keys"] = {}
	InputMap.load_from_globals()
	apply_data()
	write_to_file()

func clear_options() -> void:
	print("Save: clearing configs")
	set_all_data()
	game_data["configs"] = {}
	apply_data()
	write_to_file()

func apply_data():
	if game_data.has("version") and game_data["version"] == save_version:
		GameManager.collectibles = game_data["collectibles"]
		GlobalVariables.load_variables(game_data["variables"])
		Configurations.load_variables(game_data["configs"])
		Achievements.load_achievements(game_data["achievements"])
		InputManager.load_modified_keys(game_data["keys"])
		if game_data.has("rescued_reploids"):
			GameManager.rescued_reploids = game_data["rescued_reploids"]
		if game_data.has("x_unlocked"):
			GameManager.x_unlocked = game_data["x_unlocked"]
		call_deferred("emit_signal","loaded")
		print("Save: Finished applying and emitted signal")
	else:
		print("Old or corrupt savedata. Creating new one...")
		clear_save()
		load_save()
		
