extends Control

@onready var label1 = $VBoxContainer/Label
@onready var label2 = $VBoxContainer/Label2
@onready var label3 = $VBoxContainer/Label3
@onready var label4 = $VBoxContainer/Label4
@onready var gold_label = $GoldLabel
@onready var root = get_tree().root.get_child(0)

@onready var upgrade_menu = $Upgradesmenu

# Called when the node enters the scene tree for the first time.
func _ready():
	label1.label_settings.font_color = Color(1.0, 1.0, 0.0, 1.0)
	label2.label_settings.font_color = Color(1.0, 1.0, 0.0, 1.0)
	label3.label_settings.font_color = Color(0.0, 0.0, 1.0, 1.0)
	label4.label_settings.font_color = Color(0.0, 0.0, 1.0, 1.0)
	update_label(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	label1.text = str(root.team0pawns.size())
	label2.text = str(root.team0archers)
	label3.text = str(root.team1pawns.size())
	label4.text = str(root.team1archers)
	

func update_label(amount):
	gold_label.text = "gold + " + str(amount)

func _on_button_pressed():
	get_tree().reload_current_scene()


func _on_button_2_pressed():
	root.kill_green()


func _on_button_3_pressed():
	upgrade_menu.visible = !upgrade_menu.visible

	
