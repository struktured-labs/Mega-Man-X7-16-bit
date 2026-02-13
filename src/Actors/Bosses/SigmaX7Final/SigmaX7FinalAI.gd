extends BossAI

# Predetermined attack order for Sigma Final, adapted from SeraphBossAI
var attack_order_preset := [0, 1, 2, 3, 0, 2, 1, 3, 2, 0, 3, 1, 0, 2, 3, 1, 2, 0, 1, 3, 0, 1, 2, 3, 0, 2]

func decide_order_of_attacks():
	Log("Using preset attack order for Sigma Final")
	order_of_attacks = attack_order_preset.duplicate()
	validate_order_of_attacks()
