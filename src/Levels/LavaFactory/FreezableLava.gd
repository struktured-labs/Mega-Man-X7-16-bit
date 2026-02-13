extends InstantDeathArea
signal freeze
signal small_ice(projectile)

export var detect_charged := true

func _on_area2D_body_entered(body: Node) -> void:
	if active:
		if body.is_in_group("Player"):
			bodies.append(body.get_parent())
			set_physics_process(true)
		else:
			if detect_charged and "DriftDiamondCharged" in body.name:
				emit_signal("freeze")
				body.deflect(self)
			elif "DriftDiamond" in body.name and not "DriftDiamondCharged" in body.name:
				emit_signal("small_ice",body)
				body.deflect(self)
