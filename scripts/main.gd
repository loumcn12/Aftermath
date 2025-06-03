extends Node3D

@onready var pause_menu = $PauseMenu
@onready var hud = $player/PlayerHud
@onready var player = $player
var paused = false

func _ready() -> void:
	pause_menu.hide()
	get_tree().paused = false
	hud.visible = true
	paused = false

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		pauseMenu()
	
	if player.position.y < -5:
		player._Damage(player.position.y * -0.008)
		
func pauseMenu():

	if paused:
		pause_menu.hide()
		get_tree().paused = false
		hud.visible = true
	else:
		pause_menu.show()
		get_tree().paused = true
		Input.set_mouse_mode(Globalscript.mousemode)
		hud.visible = false
	await get_tree().create_timer(0.1).timeout 
	paused = !paused
	
