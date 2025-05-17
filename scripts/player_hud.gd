extends CanvasLayer

@onready var player: CharacterBody3D = $".."
@onready var HealthBar: ProgressBar = $Control/ProgressBar
@onready var crosshair = $Control/Crosshair

func _ready() -> void:
	if Globalscript.crosshair:
		crosshair.visible = true
	else:
		crosshair.visible = false
		

func _process(_delta: float) -> void:
	HealthBar.value = player.Health
	
