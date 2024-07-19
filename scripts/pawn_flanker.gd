extends "res://scripts/pawn.gd"

var has_engaged = false

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	self.bravery = 2
	self.trust_level = 0.1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super(delta)

#func is_surrounded():
	#return false

func get_lowest_threat_enemy():
	var pawnList = root.get_pawn_list(otherTeamId)
	var lowest_threat = 9999
	var target = null
	for pawn in pawnList:
		if pawn.threat_level < lowest_threat:
			lowest_threat = pawn.threat_level
			target = pawn
	if target == null:
		return root.get_spawn(otherTeamId).global_position
	return target.global_position

func do_melee_combat(delta):
	var lowest_health = 9999
	var target = null
	if(attack_timer > 0):
		attack_timer = attack_timer - delta
	elif(attack_area.has_overlapping_bodies):
		for body in attack_area.get_overlapping_bodies():
			if(body.teamId == otherTeamId):
				if body.health < lowest_health:
					lowest_health = body.health
					target = body
		if target != null:
			look_at(target.global_position)
			target.handle_incoming_attack(self, damage)
			attack_timer = attack_timer_base

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
	return target

#func search_for_target():
	#var target = get_lowest_threat_enemy()
	#var attack_dir = self.global_position.direction_to(target)
	#var retreat_dir
	#var move_to = target
	## move towards that target using whiteboard avoidance algorithm
	#if local_space.has_overlapping_bodies():
		#var bodies = local_space.get_overlapping_bodies()
		#var nearest_dist = 9999
		#var distance
		#var avoidance_target
		#for body in bodies:
			#distance = body.global_position.distance_to(self.global_position) 
			#if distance < nearest_dist:
				#nearest_dist = distance 
				#avoidance_target = body
		#if avoidance_target != null:
			#retreat_dir = self.global_position.direction_to(avoidance_target.global_position)
			#var vec_between = retreat_dir + attack_dir
			#if vec_between.length() == 0:
				#move_to = retreat_dir.orthogonal() * max_linear_velocity * 2 + self.global_position
			#else:
				#move_to = vec_between * max_linear_velocity + self.global_position
	#
	#set_movement_target(move_to, true)
	#else:
		#var fp = root.get_agressive_flank_position(teamId, self.global_position)
		#if self.global_position.distance_to(fp) < 25.0:
			#has_engaged = true
		#set_movement_target(fp, false)

func fall_back():
	set_movement_target(root.get_defensive_flank_position(teamId, self.global_position), false)

func get_positional_danger():
	return 0
