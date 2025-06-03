extends Label

var time_accumulator := 0.0
const UPDATE_INTERVAL := 0.5

func _ready() -> void:
	_update_visibility()

func _process(delta: float) -> void:
	# Check if visibility changed during gameplay
	_update_visibility()
	
	if !Globalscript.showFPS:
		return
		
	time_accumulator += delta
	if time_accumulator >= UPDATE_INTERVAL:
		text = "FPS: " + str(int(Engine.get_frames_per_second()))
		time_accumulator = 0.0

func _update_visibility() -> void:
	visible = Globalscript.showFPS
	set_process(visible)
