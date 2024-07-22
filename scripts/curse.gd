extends Sprite2D

var magnitude = 1.0
var duration = 6
var target

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func countdown():
	duration -= 1
	if duration <= 0:
		remove_debuff()

func apply_debuff():
	target.attack_timer_base += magnitude

func remove_debuff():
	target.attack_timer_base -= magnitude
	target.remove_debuff(self)
	self.queue_free()
