extends "res://scripts/pawn.gd"

var is_assaulting = true

func handle_incoming_attack(attacker, baseDamage):
	health = health - baseDamage
	if(health <= 0):
		if(attacker != null):
			attacker.credit_kill(self)
		root.remove_pawn(self)
		
func search_for_target():
	var nearestPawnLocation = get_nearest_enemy()
	if nearestPawnLocation != null:
		set_movement_target(nearestPawnLocation, true)

func is_surrounded():
	var nearbyAllies = self.threat_level + self.bravery
	if is_assaulting == true:
		nearbyAllies += 6
	var danger_quantum = get_positional_danger()
	nearbyAllies = nearbyAllies - int(danger_quantum)
	var nearbyEnemies = 0
	if(local_space.has_overlapping_bodies()):
		for pawn in local_space.get_overlapping_bodies():
			if(pawn.teamId == teamId):
				nearbyAllies = nearbyAllies + (pawn.threat_level + pawn.threat_support) * self.trust_level
			else:
				nearbyEnemies = nearbyEnemies + pawn.threat_level
	var is_surrounded = nearbyEnemies > nearbyAllies
	if is_surrounded:
		is_assaulting = false
	else:
		is_assaulting = true
	return is_surrounded

func fall_back():
	set_movement_target(root.get_defensive_position(teamId, fallback_coeff), false)

func _on_animated_sprite_2d_animation_finished():
	is_attacking = false
	attack_animation.visible = false

func get_nearest_enemy():
	var pawnList = root.get_pawn_list(otherTeamId)
	var dist_to_enemy_spawn = self.global_position.distance_to(enemy_spawn_location)
	var nearestDistance = 99999999.0
	var nearestPawn
	var tempDistance = 0.0
	for pawn in pawnList:
		tempDistance = pawn.global_position.distance_to(self.global_position) + pawn.global_position.distance_to(enemy_spawn_location)
		if tempDistance < nearestDistance:
			nearestDistance = tempDistance
			nearestPawn = pawn

	if(nearestPawn != null):
		return nearestPawn.global_position
	else:
		return enemy_spawn_location

func get_positional_danger():
	return root.get_defensive_position(teamId, fallback_coeff).distance_to(self.global_position) / 70
