extends Node

# Shared EX gauge for Zero's EX skills
# Similar to weapon energy but shared across all 8 techniques

export var max_ammo := 28.0
var current_ammo := 28.0

func _ready() -> void:
	current_ammo = max_ammo

func has_ammo() -> bool:
	return current_ammo > 0

func get_ammo() -> float:
	return current_ammo

func reduce_ammo(amount: float) -> void:
	current_ammo -= amount
	current_ammo = clamp(current_ammo, 0.0, max_ammo)

func increase_ammo(amount: float) -> float:
	var excess := 0.0
	current_ammo += amount
	if current_ammo > max_ammo:
		excess = current_ammo - max_ammo
		current_ammo = max_ammo
	return excess

func recharge_full() -> void:
	current_ammo = max_ammo
