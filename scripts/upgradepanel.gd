extends HBoxContainer
@onready var root = get_tree().root.get_child(0)
@onready var label = $Label
var unit_type
var label_text = ""
var spawn_point

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = label_text
	call_deferred("setup")

func setup():
	await get_tree().process_frame

	spawn_point = root.get_spawn(0)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_label_text(text):
	label_text = text


func _on_dmg_up_button_pressed():
	unit_type.upgrade_damage(spawn_point)

func _on_hp_up_button_pressed():
	unit_type.upgrade_health(spawn_point)

func _on_mass_up_button_pressed():
	unit_type.upgrade_mass(spawn_point)

func _on_evolve_button_pressed():
	spawn_point.evolve_unit(unit_type.unit_type)
