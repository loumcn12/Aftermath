extends Control
@onready var quitbutton = $VBoxContainer/quitbutton

func _ready():
	Input.set_mouse_mode(Globalscript.mousemode)
	if (OS.get_name() != "Windows") and (OS.get_name() != "Linux"):
		quitbutton.visible = false
		
func _on_startbutton_pressed() -> void:
	
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_optionsbutton_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main menu/options_menu.tscn")


func _on_quitbutton_pressed() -> void:
	
	get_tree().quit()
