extends Object

enum pawn_name{WARRIOR, ASSAULT_WARRIOR, FLANKER, ARCHER}

var unit_type
var upgrade_cost

var spawn_budget = 0.0
var spawn_cost = 0.2
var upgrade_cost_base = 1
var damage = 1
var health = 30
var mass = 5.0
var movement_speed = 480.0
var threat_level = 1
var threat_support = 0
var bravery = 1
# the point was to have a defensive point that its scary to get too far ahead of, which makes sense and works correctly
# however, in the early game we are a bit too scared to fight, and theoretically on a larger map, we don't want to make it
# nearly impossible to advance without massive forces, so we need some way to keep the current system, but in the
# right circumstances be able to say, actually, we don't care how far from spawn we are
var fallback_coeff = 100 # this used to be a 0-1 scalar for average team position - spawnpoint
var max_velocity = 85.0

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
var shock_infantry_threat_level_mod = 1
var shock_infantry_bravery_mod = 2

func _init(_pawn_name):
	match(_pawn_name):
		pawn_name.WARRIOR:
			spawn_cost = 0.2
			damage = 1
			health = 42
			mass = 5.0
			movement_speed = 380.0
			threat_level = 1
			fallback_coeff = 150
			threat_support = 0.1
			bravery = -1
		pawn_name.ASSAULT_WARRIOR:
			spawn_cost = 0.2
			damage = 3
			health = 21
			mass = 5.0
			movement_speed = 380.0
			threat_level = 1.1
			bravery = 4
		pawn_name.FLANKER:
			spawn_cost = 0.45
			damage = 1
			health = 30
			mass = 5.0
			movement_speed = 550.0
			max_velocity = 100.0
			threat_level = 1
		pawn_name.ARCHER:
			spawn_cost = 0.6
			damage = 1
			health = 3
			mass = 5.0
			movement_speed = 480.0
			threat_level = 0
			fallback_coeff = 350


func upgrade_health(spawner):
	if spawner.team_gold >= upgrade_cost_base:
		health += 1
		spawner.receive_gold(upgrade_cost_base * -1)
		upgrade_cost_base += 1
		
func upgrade_damage(spawner):
	if spawner.team_gold >= upgrade_cost_base:
		damage += 1
		spawner.receive_gold(upgrade_cost_base * -1)
		upgrade_cost_base += 1
		
func upgrade_weight(spawner):
	if spawner.team_gold >= upgrade_cost_base:
		mass += .5
		movement_speed += 45
		spawner.receive_gold(upgrade_cost_base * -1)
		upgrade_cost_base += 1
