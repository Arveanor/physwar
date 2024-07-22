extends StaticBody2D

var pawnScene = preload("res://scenes/pawn.tscn")
var pawnArcherScene = preload("res://scenes/pawn_archer.tscn")
var pawn_flanker_scene = preload("res://scenes/pawn_flanker.tscn")
var spawn_values_script = preload("res://scripts/spawn_values.gd")
var ai_manager_script = preload("res://scripts/ai_manager.gd")

var ai_manager

var warrior_values
var archer_values
var flanker_values

var teams_overlay

@onready var baseSpawnCooldown = 20.0
@onready var spawnCooldown = 1.0
var archer_spawn_count = 2
var melee_spawn_count = 4
var flanker_spawn_count = 2
var spawn_location
var spawn_location_melee
var spawn_forward_vec
@onready var root = get_tree().root.get_child(0)

var spawn_bucks = 0
var team_gold = 0
var health = 10000

var teamId
var otherTeamId
var threat_level = 0
var threat_support = 0

var charger_damage_mod = 5
var charger_health_mod = 20
var charger_weight_mod = 8.0
var charger_threat_level_mod = 1
var charger_movement_speed_mod = 1260.0
var charger_max_velocity_mod = 140.0

var shock_infantry_damage_mod = 1
var shock_infantry_health_mod = 5
var shock_infantry_weight_mod = 1.0
var shock_infantry_movement_speed_mod = 70.0
var shock_infantry_threat_level_mod = 0
var shock_infantry_bravery_mod = 0

var pawns_spawned = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_location = self.global_position

	ai_manager = ai_manager_script.new()
	warrior_values = spawn_values_script.new()
	archer_values = spawn_values_script.new()
	flanker_values = spawn_values_script.new()
	
	warrior_values.spawn_cost = 0.2
	warrior_values.damage = 1
	warrior_values.health = 30
	warrior_values.mass = 5.0
	warrior_values.movement_speed = 480.0
	warrior_values.threat_level = 1
	
	archer_values.spawn_cost = 0.6
	archer_values.damage = 1
	archer_values.health = 3
	archer_values.mass = 5.0
	archer_values.movement_speed = 480.0
	archer_values.threat_level = 0
	archer_values.fallback_coeff = 0.9

	flanker_values.spawn_cost = 0.45
	flanker_values.damage = 1
	flanker_values.health = 30
	flanker_values.mass = 5.0
	flanker_values.movement_speed = 550.0
	flanker_values.max_velocity = 100.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(spawnCooldown <= 0):
		#if teamId == 1:
		choose_upgrades()
		sling_pawn_group()
		spawnCooldown = baseSpawnCooldown
	else:
		spawnCooldown = spawnCooldown - delta

func evolve_unit(unit_type):
	if unit_type == "warrior":
		pawnScene = load("res://scenes/pawn_spear.tscn")
		warrior_values.damage += shock_infantry_damage_mod
		warrior_values.health += shock_infantry_health_mod
		warrior_values.mass += shock_infantry_weight_mod
		warrior_values.movement_speed += shock_infantry_movement_speed_mod
		warrior_values.threat_level += shock_infantry_threat_level_mod
	elif unit_type == "flanker":
		pawn_flanker_scene = load("res://scenes/pawn_charger.tscn")
		flanker_values.damage += charger_damage_mod
		flanker_values.health += charger_health_mod
		flanker_values.mass += charger_weight_mod
		flanker_values.movement_speed += charger_movement_speed_mod
		flanker_values.max_velocity += charger_max_velocity_mod

func choose_upgrades(): #only meant for ai opponents
	var lowest_cost
	var selection
	var upgrade_choice
	
	while(true):
		if warrior_values.upgrade_cost_base < archer_values.upgrade_cost_base:
			lowest_cost = warrior_values.upgrade_cost_base
			selection = warrior_values
		else:
			lowest_cost = archer_values.upgrade_cost_base
			selection = archer_values
		if lowest_cost < flanker_values.upgrade_cost_base:
			lowest_cost = flanker_values.upgrade_cost_base
			selection = flanker_values
		
		if lowest_cost >= team_gold:
			return
		
		if selection == warrior_values:
			upgrade_choice = ai_manager.choose_next_warrior_upgrade()
		elif selection == archer_values:
			upgrade_choice = ai_manager.choose_next_archer_upgrade()
		elif selection == flanker_values:
			upgrade_choice = ai_manager.choose_next_flanker_upgrade()

		if upgrade_choice == 0:
			selection.upgrade_health(self)
		elif upgrade_choice == 1:
			selection.upgrade_damage(self)

func sling_pawn_group():
	var current_spawn_location = spawn_location
	var count = 0
	
	#archer_values.spawn_budget += 1.0
	#while archer_values.spawn_budget >= archer_values.spawn_cost:
		#var pawn_archer = pawnArcherScene.instantiate()
		#pawn_archer.global_position = spawn_location
		#pawn_archer.teamId = self.teamId
		#pawn_archer.otherTeamId = self.otherTeamId
		#pawn_archer.initialize_values(archer_values)
		#root.add_pawn(pawn_archer)
		#archer_values.spawn_budget -= archer_values.spawn_cost
#
	#flanker_values.spawn_budget += 1.0
	#while flanker_values.spawn_budget >= flanker_values.spawn_cost:
		#var pawn_flanker = pawn_flanker_scene.instantiate()
		#if count % 2 == 0:
			#pawn_flanker.global_position = self.global_position + Vector2(0, 180 + (count / 2) * 180)
		#else:
			#pawn_flanker.global_position = self.global_position - Vector2(0, 180 + (count / 2) * 180)
		#pawn_flanker.teamId = self.teamId
		#pawn_flanker.otherTeamId = self.otherTeamId
		#pawn_flanker.initialize_values(flanker_values)
		#root.add_pawn(pawn_flanker)
		#count += 1
		#flanker_values.spawn_budget -= flanker_values.spawn_cost
	
	warrior_values.spawn_budget += 1.0
	while warrior_values.spawn_budget >= warrior_values.spawn_cost:
		var pawn = pawnScene.instantiate()
		pawn.global_position = spawn_location_melee
		pawn.teamId = self.teamId
		pawn.otherTeamId = self.otherTeamId
		pawn.initialize_values(warrior_values)
		root.add_pawn(pawn)
		warrior_values.spawn_budget -= warrior_values.spawn_cost
		
func handle_incoming_attack(attacker, baseDamage):
	health = health - baseDamage
	if(health <= 0):
		root.victory(otherTeamId)

func receive_gold(amount):
	if(teams_overlay == null):
		teams_overlay = root.get_node("CanvasLayer/Teamsoverlay")
	team_gold = team_gold + amount
	if teamId == 0:
		teams_overlay.update_label(team_gold)

func set_team_id(_teamId, _otherTeamId):
	teamId = _teamId
	otherTeamId = _otherTeamId
	if teamId == 0:
		spawn_location = spawn_location - Vector2(20, 0)
		spawn_location_melee = spawn_location - Vector2(20, 0)
	else:
		spawn_location = spawn_location + Vector2(20, 0)
		spawn_location_melee = spawn_location + Vector2(20, 0)
	set_collision_layer_value(teamId + 1, true)
	set_collision_mask_value(otherTeamId + 1, true)

#func sling_pawn():
	#var pawn
	#var spawn_roll = randi() % (archer_spawn_weight + melee_spawn_weight + flanker_spawn_weight)
	##if(pawns_spawned < 12):
		##spawn_roll = randi() % (archer_spawn_weight + melee_spawn_weight)
	#if spawn_roll < archer_spawn_weight:
		#pawn = pawnArcherScene.instantiate()
		#pawn.damage = archer_damage
		#pawn.max_health = archer_health
		#pawn.health = archer_health
		#pawn.movement_speed = archer_movement_speed
		#pawn.mass = archer_weight
		#pawn.fallback_coeff = archer_fallback_coeff
	#elif spawn_roll < archer_spawn_weight + melee_spawn_weight:
		#pawn = pawnScene.instantiate()
		#pawn.damage = warrior_damage
		#pawn.max_health = warrior_health
		#pawn.health = warrior_health
		#pawn.movement_speed = warrior_movement_speed
		#pawn.mass = warrior_weight
	#elif spawn_roll < archer_spawn_weight + melee_spawn_weight + flanker_spawn_weight:
		#pawn = pawn_flanker_scene.instantiate()
		#pawn.damage = flanker_damage
		#pawn.max_health = flanker_health
		#pawn.health = flanker_health
		#pawn.movement_speed = flanker_movement_speed
		#pawn.mass = flanker_weight
		#pawn.max_linear_velocity = flanker_max_velocity
	#pawn.global_position = spawn_location
	#pawn.teamId = self.teamId
	#pawn.otherTeamId = self.otherTeamId		
	#root.add_pawn(pawn)
	#pawns_spawned = pawns_spawned + 1
