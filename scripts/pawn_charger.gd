extends "res://scripts/pawn.gd"

var is_charging = false
var has_charged = false

func search_for_target():
	if is_charging == false && has_charged == false:
		set_movement_target(root.get_average_team_position(otherTeamId), true)
		is_charging = true
	else:
		super()

func do_melee_combat(delta):
	if(attack_timer > 0):
		attack_timer = attack_timer - delta
	elif(attack_area.has_overlapping_bodies):
		for body in attack_area.get_overlapping_bodies():
			if(body.teamId == otherTeamId):
				look_at(body.global_position)
				body.handle_incoming_attack(self, damage)
				attack_timer = attack_timer_base
				break

func target_reached():
	is_charging = false
	has_charged = true

func is_surrounded():
	if is_charging:
		return false

	var nearbyAllies = self.threat_level + self.bravery
	var nearbyEnemies = 0
	if(local_space.has_overlapping_bodies()):
		for pawn in local_space.get_overlapping_bodies():
			if(pawn.teamId == teamId):
				nearbyAllies = nearbyAllies + (pawn.threat_level + pawn.threat_support) * self.trust_level
			else:
				nearbyEnemies = nearbyEnemies + pawn.threat_level
	return nearbyEnemies > nearbyAllies
