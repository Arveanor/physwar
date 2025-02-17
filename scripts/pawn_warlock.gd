extends "res://scripts/pawn.gd"

var missile_scene = preload("res://scenes/spell_effector.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	threat_support = 2
	threat_level = 0
	desired_range = 200


func do_melee_combat(delta):
	var distance
	var nearest = 999999999.0
	var direction
	var target = null
	if(attack_timer > 0):
		attack_timer = attack_timer - delta
	elif(attack_area.has_overlapping_bodies):
		for body in attack_area.get_overlapping_bodies():
			if(body.teamId == otherTeamId):
				distance = self.global_position.distance_to(body.global_position)
				if distance < nearest:
					nearest = distance
					target = body
				direction = self.global_position.direction_to(body.global_position)
				attack_timer = attack_timer_base
				break
		if target != null:
			look_at(target.global_position)
			var missile = missile_scene.instantiate()
			missile.damage = damage
			missile.global_position = self.global_position
			missile.launcher = self
			missile.set_collision_mask_value(otherTeamId + 1, true)
			missile.look_at(target.global_position)
			missile.set_collision_layer_value(teamId + 3, true)
			missile.velocity = direction * 20.0
			root.add_child(missile)

func is_surrounded():
	var nearbyEnemies = 0
	if(local_space.has_overlapping_bodies()):
		for pawn in local_space.get_overlapping_bodies():
			if(pawn.teamId == otherTeamId):
				nearbyEnemies = nearbyEnemies + 1
	return nearbyEnemies > 0
