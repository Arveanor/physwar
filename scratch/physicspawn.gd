extends RigidBody2D

@export var velocity = Vector2(10, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	apply_central_force(velocity)
	print(self.linear_velocity)
