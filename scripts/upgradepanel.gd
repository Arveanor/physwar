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
	if unit_type == "warrior":
		if spawn_point.team_gold >= 1:
			spawn_point.warrior_damage = spawn_point.warrior_damage + 1
			spawn_point.team_gold -= 1
	elif unit_type == "archer":
		if spawn_point.team_gold >= 1:
			spawn_point.archer_damage = spawn_point.archer_damage + 1
			spawn_point.team_gold -= 1


func _on_hp_up_button_pressed():
	if unit_type == "warrior":
		if spawn_point.team_gold >= 1:
			spawn_point.warrior_health = spawn_point.warrior_health + 1
			spawn_point.team_gold -= 1
	elif unit_type == "archer":
		if spawn_point.team_gold >= 1:
			spawn_point.archer_health = spawn_point.archer_health + 1
			spawn_point.team_gold -= 1


func _on_mass_up_button_pressed():
	if unit_type == "warrior":
		spawn_point.upgrade_warrior_weight()
	elif unit_type == "archer":
		spawn_point.upgrade_archer_weight()


func _on_evolve_button_pressed():
	spawn_point.evolve_unit(unit_type)
