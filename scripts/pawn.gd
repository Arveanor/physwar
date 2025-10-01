extends RigidBody2D

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var attack_area = $AttackArea
@onready var local_space = $LocalSpace
@onready var sprite = $Sprite2D
@onready var attack_animation = $AnimatedSprite2D
@onready var health_bar = $Node2D/HealthBar
@onready var health_bar_holder = $Node2D
@onready var root = get_tree().root.get_child(-1)

var debuff_list = []

# not necessarily max, but the max we will still accelerate too
var max_linear_velocity = 85.0 
var damage = 1
var max_health = 1
var health = 35
var threat_level = 1
var trust_level = 1.0
var bravery = 0
var pawn_type = "unassigned"

# allies are emboldened by support, enemies are not deterred by it
# initially intended to let melee pawns stop retreating all the way
# to their own archer pool
var threat_support = 0 
var fallback_coeff: float = 0.5
@onready var desired_range = 10

var positional_danger = 0

var ally_spawn_point
var enemy_spawn_location

var attack_timer_base: float = 1.4 #time between attacks in seconds
var attack_timer = attack_timer_base

var moving_to_enemy = false
var velocity: Vector2
var is_attacking: bool = false

var movement_speed: float = 480.0
@export var movement_target_position: Vector2 = Vector2(478.0,415.0)

var teamId
var otherTeamId

func _ready():
	enemy_spawn_location = root.get_spawn(otherTeamId).global_position
	ally_spawn_point = root.get_spawn(teamId)
	
	set_collision_layer_value(teamId + 1, true)
	set_collision_mask_value(otherTeamId + 3, true) # this lets us be hit by enemy arrows
	set_collision_mask_value(32, true)
	attack_area.set_collision_mask_value(otherTeamId + 1, true)
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0

	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(movement_target_position, false)

func initialize_values(values):
	damage = values.damage
	max_health = values.health
	health = values.health
	movement_speed = values.movement_speed
	mass = values.mass
	fallback_coeff = values.fallback_coeff
	max_linear_velocity = values.max_velocity
	threat_level = values.threat_level
	threat_support = values.threat_support
	bravery = values.bravery

func set_movement_target(movement_target: Vector2, isEnemy):
	moving_to_enemy = isEnemy
	navigation_agent.target_position = movement_target

func _physics_process(delta):
	if is_attacking == true:
		return
	#print("my linear vel = " + str(self.linear_velocity))
	if (navigation_agent.get_final_position().distance_to(self.global_position) <= desired_range
			and moving_to_enemy):
		target_reached()
		return
	else:
		var current_agent_position: Vector2 = global_position
		var next_path_position: Vector2 = navigation_agent.get_next_path_position()
		look_at(next_path_position)
		if(self.linear_velocity.length() < max_linear_velocity):
			velocity = current_agent_position.direction_to(next_path_position) * movement_speed
			apply_central_force(velocity)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	health_bar_holder.set_rotation(0 - self.rotation)
	if is_attacking == true:
		return
	do_melee_combat(delta)
	decision_tree(delta)

func _slow_process():
	for debuff in debuff_list:
		debuff.countdown()

func do_melee_combat(delta):
	if(attack_timer > 0):
		attack_timer = attack_timer - delta
	elif(attack_area.has_overlapping_bodies):
		for body in attack_area.get_overlapping_bodies():
			if(body.teamId == otherTeamId):
				look_at(body.global_position)
				body.handle_incoming_attack(self, damage)
				attack_timer = attack_timer_base
				attack_animation.visible = true
				attack_animation.play("attack")
				is_attacking = true
				break
		#get targets in range
		#apply damage to first target

func handle_incoming_attack(attacker, baseDamage):
	health = health - baseDamage
	health_bar.set_value_no_signal((float(health) / float(max_health)) * 100.0)
	if(health <= 0):
		if(attacker != null):
			attacker.credit_kill(self)
		root.remove_pawn(self)

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
	
func get_positional_danger():
	positional_danger = root.get_defensive_position(teamId, fallback_coeff).distance_to(self.global_position)
	return positional_danger / 50

func fall_back():
	set_movement_target(root.get_defensive_position(teamId, fallback_coeff), false)

func decision_tree(delta):
	#move towards enemy or move towards team defensive position
	if is_surrounded():
		fall_back()
	else:
		search_for_target()

func get_nearest_enemy():
	var pawnList = root.get_pawn_list(otherTeamId)
	var dist_to_enemy_spawn = self.global_position.distance_to(enemy_spawn_location)
	var nearestDistance = 99999999.0
	var nearestPawn
	var tempDistance = 0.0
	if teamId == 1:
		for pawn in pawnList:
			tempDistance = pawn.global_position.distance_to(self.global_position)# - (pawn.positional_danger / 2)
			if tempDistance < nearestDistance:
				nearestDistance = tempDistance
				nearestPawn = pawn
	else:
		for pawn in pawnList:
			tempDistance = pawn.global_position.distance_to(self.global_position)
			if tempDistance < nearestDistance:
				nearestDistance = tempDistance
				nearestPawn = pawn		
				if nearestDistance <= 25.0:
					break

	if(nearestPawn != null):
		return nearestPawn.global_position
	else:
		return enemy_spawn_location

func search_for_target():
	var nearestPawnLocation = get_nearest_enemy()
	if nearestPawnLocation != null:
		set_movement_target(nearestPawnLocation, true)

func credit_kill(enemy):
	ally_spawn_point.receive_gold(1)

func get_braking_vector(_linear_velocity):
	var magnitude = _linear_velocity.length()
	if(magnitude < 1.0):
		return Vector2(0, 0)
	var braking_direction = _linear_velocity.normalized() * -1

	
	var capped_force = minf(movement_speed, magnitude)
	
	if teamId == 0:
		print("magnitude = " + str(magnitude))
		print("capped_force = " + str(capped_force))
		print("braking_direction = " + str(braking_direction))
	
	return capped_force * braking_direction

func target_reached():
	pass

func _on_animated_sprite_2d_animation_finished():
	is_attacking = false
	attack_animation.visible = false

func add_debuff(debuff):
	debuff_list.push_back(debuff)
	self.add_child(debuff)
	debuff.target = self
	debuff.apply_debuff()
	
func remove_debuff(debuff):
	debuff_list.erase(debuff)
