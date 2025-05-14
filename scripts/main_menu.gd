extends Control
@onready var quitbutton = $VBoxContainer/quitbutton

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	if (OS.get_name() != "Windows") and (OS.get_name() != "Linux"):
		quitbutton.visible = false
		
func _on_startbutton_pressed() -> void:
	pass # Replace with function body.


func _on_optionsbutton_pressed() -> void:
	pass # Replace with function body.


func _on_quitbutton_pressed() -> void:
	
	get_tree().quit()
