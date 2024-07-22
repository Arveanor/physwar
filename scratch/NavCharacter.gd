extends CharacterBody2D

var movement_speed: float = 200.0
var movement_target_position: Vector2 = Vector2(478.0,415.0)

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
var next_path_position

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0

	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func _draw():
	if next_path_position != null:
		draw_line(Vector2(0, 0), next_path_position, Color.DARK_ORANGE)

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(movement_target_position)

func set_movement_target(movement_target: Vector2):
	movement_target_position = movement_target
	navigation_agent.target_position = movement_target
	queue_redraw()

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		return

	var current_agent_position: Vector2 = global_position
	next_path_position = navigation_agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	move_and_slide()

func _input(event):
	if event is InputEventMouseButton:
		set_movement_target(event.position)
