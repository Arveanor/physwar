extends Node2D

var battle_summary_scene = preload("res://scenes/battlesummary.tscn")

@onready var nextTeamId = 0
@onready var Spawnpoint1 = $Spawnpoint1
@onready var Spawnpoint2 = $Spawnpoint2

@onready var debug0 = $debugdefensepoint0
@onready var debug1 = $debugdefensepoint1

@onready var camera = $Camera2D
var camera_speed = 30.0

var team0pawns = []
var team1pawns = []

# Called when the node enters the scene tree for the first time.
func _ready():
	camera_setup()
	get_tree().paused = false
	randomize()
	Spawnpoint1.set_team_id(0, 1)
	Spawnpoint2.set_team_id(1, 0)
	
	Spawnpoint1.spawn_forward_vec = Vector2(-20, 0.0)
	Spawnpoint2.spawn_forward_vec = Vector2(20, 0.0)
	
	#Spawnpoint1.evolve_unit("flanker")
	#Spawnpoint2.evolve_unit("flanker")
	
	Spawnpoint1.archer_spawn_count = 1
	Spawnpoint1.melee_spawn_count = 0
	Spawnpoint1.flanker_spawn_count = 1
	Spawnpoint2.archer_spawn_count = 1
	Spawnpoint2.melee_spawn_count = 5
	Spawnpoint2.flanker_spawn_count = 0
	
func camera_setup():
	camera.zoom = Vector2(.75, .75)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("camera_up"):
		camera.global_position.y -= camera_speed
	elif Input.is_action_pressed("camera_right"):
		camera.global_position.x += camera_speed
	elif Input.is_action_pressed("camera_down"):
		camera.global_position.y += camera_speed
	elif Input.is_action_pressed("camera_left"):
		camera.global_position.x -= camera_speed
		
func get_spawn(teamId):
	if teamId == 0:
		return Spawnpoint1
	else:
		return Spawnpoint2

func kill_green():
	var pawn
	while(team0pawns.size() > 0):
		pawn = team0pawns.pop_back()
		pawn.queue_free()

func add_pawn(pawn):
	if pawn.teamId == 0:
		team0pawns.push_back(pawn)
		pawn.get_node("Sprite2D").material.set_shader_parameter("teamId", 0.0)
	else:
		pawn.get_node("Sprite2D").material.set_shader_parameter("teamId", 1.0)
		team1pawns.push_back(pawn)

	self.add_child(pawn)

func get_new_team():
	var teamId = nextTeamId
	nextTeamId += 1
	return teamId

func get_pawn_list(teamId):
	if(teamId == 0):
		return team0pawns
	else:
		return team1pawns

func victory(teamId):
	var bss = battle_summary_scene.instantiate()
	self.add_child(bss)
	get_tree().paused = true

func remove_pawn(pawn):
	if(pawn.teamId == 0):
		team0pawns.erase(pawn)
	else:
		team1pawns.erase(pawn)
	pawn.queue_free()
	
func get_average_team_position(teamId):
	var teamlist		
	var positionSum = Vector2(0.0, 0.0)
	if(teamId == 0):
		teamlist = team0pawns
	else:
		teamlist = team1pawns
	for pawn in teamlist:
		positionSum = positionSum + pawn.global_position
	
	if teamlist.size() == 0:
		return get_spawn(teamId).global_position
	return positionSum / teamlist.size()

func get_defensive_position(teamId, fallback_coeff: float):
	var spawnposition
	if(teamId == 0):
		spawnposition = Spawnpoint1
	else:
		spawnposition = Spawnpoint2
	var team_average_pos = get_average_team_position(teamId)
	var defensive_position = team_average_pos + (spawnposition.global_position - team_average_pos) * fallback_coeff
	
	return defensive_position
	
func get_agressive_flank_position(teamId, flanker_location):
	# ally average position - enemy average position 
	var enemy_team_pos
	var vec_from_enemy_orth
	var location_a
	var location_b
	
	if teamId == 0:
		enemy_team_pos = get_average_team_position(1)
		vec_from_enemy_orth = (get_average_team_position(teamId) - enemy_team_pos).orthogonal()
	else:
		enemy_team_pos = get_average_team_position(0)
		vec_from_enemy_orth = (get_average_team_position(teamId) - enemy_team_pos).orthogonal()

	location_a = enemy_team_pos + vec_from_enemy_orth
	location_b = enemy_team_pos - vec_from_enemy_orth
	debug0.global_position = location_a
	debug1.global_position = location_b
	if flanker_location.distance_to(location_b) < flanker_location.distance_to(location_a):
		return location_b
	else:
		return location_a
		
func get_defensive_flank_position(teamId, flanker_location):
	var ally_team_pos = get_average_team_position(teamId)
	var vec_to_base_ortho = (get_spawn(teamId).global_position - ally_team_pos).orthogonal() * .5
	var location_a = ally_team_pos + vec_to_base_ortho
	var location_b = ally_team_pos - vec_to_base_ortho
	
	debug0.global_position = location_a
	debug1.global_position = location_b
	if flanker_location.distance_to(location_b) < flanker_location.distance_to(location_a):
		return location_b
	else:
		return location_a
		
func get_defensive_flank_vector(teamId, flanker_location):
	var ally_team_pos = get_average_team_position(teamId)
	var vec_to_base_ortho = (get_spawn(teamId).global_position - ally_team_pos).orthogonal()
	var location_a = ally_team_pos + vec_to_base_ortho
	var location_b = ally_team_pos - vec_to_base_ortho
	
	debug0.global_position = location_a
	debug1.global_position = location_b
	if flanker_location.distance_to(location_b) < flanker_location.distance_to(location_a):
		return location_b
	else:
		return location_a
