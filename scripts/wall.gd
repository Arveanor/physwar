extends StaticBody2D

@onready var sprite = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.material.set_shader_parameter("length_scale", int(self.scale.y))
