extends Control

@onready var root = get_tree().root.get_child(0)
@onready var tab_bar = $TabBar
var upgrade_panel_scene = preload("res://scenes/upgradepanel.tscn")
var melee_upgrade_panel
var archer_upgrade_panel
var flanker_upgrade_panel
var current_panel

var spawn_point

# Called when the node enters the scene tree for the first time.
func _ready():
	actor_setup()

func actor_setup():
	await root.ready
	
	spawn_point = root.get_spawn(0)
	melee_upgrade_panel = upgrade_panel_scene.instantiate()
	melee_upgrade_panel.set_label_text("Powerful Warriors")
	melee_upgrade_panel.unit_type = spawn_point.warrior_values
	archer_upgrade_panel = upgrade_panel_scene.instantiate()
	archer_upgrade_panel.unit_type = spawn_point.archer_values
	archer_upgrade_panel.set_label_text("Legendary Archers")
	flanker_upgrade_panel = upgrade_panel_scene.instantiate()
	flanker_upgrade_panel.unit_type = spawn_point.flanker_values
	flanker_upgrade_panel.set_label_text("Devastating Specialists")
	self.add_child(melee_upgrade_panel)
	current_panel = melee_upgrade_panel
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_tab_bar_tab_changed(tab):
	self.remove_child(current_panel)
	if tab == 1:
		self.add_child(archer_upgrade_panel)
		current_panel = archer_upgrade_panel
	elif tab == 0:
		self.add_child(melee_upgrade_panel)
		current_panel = melee_upgrade_panel
	elif tab == 2:
		self.add_child(flanker_upgrade_panel)
		current_panel = flanker_upgrade_panel
