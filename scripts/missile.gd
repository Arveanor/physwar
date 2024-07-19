extends RigidBody2D

@onready var ttl: float = 3.0
# can we deal damage after our first physics collision
@onready var targetLimit = 1
@onready var targetsHit = 0
var damage = 1
var impulse = null
var launcher

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	ttl = ttl - delta
	if(ttl <= 0.0):
		self.queue_free()

func _physics_process(delta):
	if impulse != null:
		apply_central_impulse(impulse)
		impulse = null

func do_impulse(_impulse):
	impulse = _impulse


func _on_body_entered(body):
	if(targetsHit < targetLimit):
		body.handle_incoming_attack(launcher, damage)
	targetsHit = targetsHit + 1
