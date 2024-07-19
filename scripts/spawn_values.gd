extends Object

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
var fallback_coeff = 0.9
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
