extends "res://scripts/pawn.gd"

var arrowScene = preload("res://scenes/missile.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	#only need to do things here specific to archer
	super()
	threat_support = 1
	threat_level = 0
	desired_range = 250

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
			direction += (direction.orthogonal() * (randf() / 2.0 - 0.25))
			direction = direction.normalized()
			look_at(target.global_position)
			var arrow = arrowScene.instantiate()
			arrow.damage = damage
			arrow.global_position = self.global_position
			arrow.launcher = self
			arrow.set_collision_mask_value(otherTeamId + 1, true)
			arrow.look_at(target.global_position)
			arrow.set_collision_layer_value(teamId + 3, true)
			root.add_child(arrow)
			arrow.do_impulse(direction * 950.0)

func is_surrounded():
	var nearbyEnemies = 0
	if(local_space.has_overlapping_bodies()):
		for pawn in local_space.get_overlapping_bodies():
			if(pawn.teamId == otherTeamId):
				nearbyEnemies = nearbyEnemies + 1
	return nearbyEnemies > 0

func handle_incoming_attack(attacker, baseDamage):
	super(attacker, baseDamage)
	if health <= 0:
		if teamId == 0:
			root.team0archers -= 1
		else:
			root.team1archers -= 1
