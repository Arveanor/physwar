extends "res://scripts/pawn.gd"

func _ready():
	super()
	bravery = 0

#func _physics_process(delta):
	#if is_attacking == true:
		#return
	##print("my linear vel = " + str(self.linear_velocity))
	#if (navigation_agent.get_final_position().distance_to(self.global_position) <= desired_range
			#and moving_to_enemy):
		#return
	#else:
		#var current_agent_position: Vector2 = global_position
		#var next_path_position: Vector2 = navigation_agent.get_next_path_position()
		#look_at(next_path_position)
		#if(self.linear_velocity.length() < max_linear_velocity):
			## add to normalized vec from enemy average to me
			#var curve_point = current_agent_position.direction_to(next_path_position) + root.get_average_team_position(otherTeamId).direction_to(global_position)
			#velocity = curve_point.normalized() * movement_speed
			#if velocity.length() < 200:
				#print("Why")
			#apply_central_force(velocity)

func get_nearest_enemy_to_point(point):
	var pawnList = root.get_pawn_list(otherTeamId)
	var dist_to_enemy_spawn = point.distance_to(enemy_spawn_location)
	var nearestDistance = 99999999.0
	var nearestPawn
	var tempDistance = 0.0
	for pawn in pawnList:
		tempDistance = pawn.global_position.distance_to(point)
		if tempDistance < nearestDistance:
			nearestDistance = tempDistance
			nearestPawn = pawn

	if(nearestPawn != null):
		return nearestPawn.global_position
	else:
		return enemy_spawn_location
		
func search_for_target():
	var fp = root.get_agressive_flank_position(teamId, global_position)
	var target = get_nearest_enemy_to_point(fp)
	set_movement_target(target, true)
	
func get_positional_danger():
	var flank = root.get_defensive_flank_position(teamId, global_position)
	if global_position.distance_to(ally_spawn_point.global_position) > flank.distance_to(ally_spawn_point.global_position):
		return flank.distance_to(self.global_position) / 30
	else:
		return 0

func fall_back():
	set_movement_target(root.get_defensive_flank_position(teamId, global_position), false)

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

func is_surrounded():
	var nearbyAllies = self.threat_level + self.bravery
	var danger_quantum = get_positional_danger()
	nearbyAllies = nearbyAllies - int(danger_quantum)
	var nearbyEnemies = 0
	if(local_space.has_overlapping_bodies()):
		for pawn in local_space.get_overlapping_bodies():
			if(pawn.teamId == teamId):
				nearbyAllies = nearbyAllies + (pawn.threat_level + pawn.threat_support) * self.trust_level
			else:
				nearbyEnemies = nearbyEnemies + pawn.threat_level
	return nearbyEnemies > nearbyAllies
