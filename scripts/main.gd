extends Node3D

@onready var pause_menu = $PauseMenu
var paused = false

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		pauseMenu()
		
func pauseMenu():
	if paused:
		pause_menu.hide()
		get_tree().paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		pause_menu.show()
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	await get_tree().create_timer(0.1).timeout 
	paused = !paused
	
