extends CanvasLayer

@onready var player: CharacterBody3D = $".."
@onready var HealthBar: ProgressBar = $Control/VBoxContainer/HealthBar
@onready var crosshair = $Control/Crosshair
@onready var StaminaBar = $Control/VBoxContainer/StaminaBar

func _crosshair():
	if Globalscript.crosshair:
		crosshair.visible = true
	else:
		crosshair.visible = false

func _ready() -> void:
	_crosshair()
		

func _process(_delta: float) -> void:
	HealthBar.value = player.Health
	StaminaBar.value = Globalscript.globalStamina
