extends Node2D

var pawnScene = preload("res://scenes/physicspawn.tscn")
@export var spawnCooldown = .5
@export var teamAcceleration = Vector2(1.0, 0.0)
@onready var root = get_tree().root.get_child(0)

var teamId
var otherTeamId

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(spawnCooldown <= 0):
		sling_pawn()
		spawnCooldown = .25
	else:
		spawnCooldown = spawnCooldown - delta

func sling_pawn():
	var pawn = pawnScene.instantiate()
	pawn.global_position = self.global_position
	pawn.acceleration = teamAcceleration
	root.add_child(pawn)
