extends Area2D

var curse = preload("res://scenes/curse.tscn")

var launcher
var velocity
var damage

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position += velocity

func _on_body_entered(body):
	body.handle_incoming_attack(launcher, damage)
	var curse_instance = curse.instantiate()
	if body.has_method("add_debuff"):
		body.add_debuff(curse_instance)
	self.queue_free()
