extends "res://scripts/pawn.gd"

func do_melee_combat(delta):
	if(attack_timer > 0):
		attack_timer = attack_timer - delta
	elif(attack_area.has_overlapping_bodies):
		for body in attack_area.get_overlapping_bodies():
			if(body.teamId == otherTeamId):
				look_at(body.global_position)
				body.handle_incoming_attack(self, damage)
				body.apply_impulse(self.global_position.direction_to(body.global_position) * 600.0)
				attack_timer = attack_timer_base
				break
