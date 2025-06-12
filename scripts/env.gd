extends Node3D

@export var cycle_duration: float = 20.0
@export var day_pause: float = 10.0
@export var night_pause: float = 1.0
@export var pause_threshold: float = 0.001

@onready var sun: DirectionalLight3D = $DirectionalLight3D
@onready var world_env_node: WorldEnvironment = $WorldEnvironment
var env: Environment

var time: float = 0.0
var pause_timer: float = 0.0
var is_paused: bool = false
var current_pause_duration: float = 0.0

var paused_at_day: bool = false
var paused_at_night: bool = false
var can_pause: bool = true  # Only pause if true, reset when moved away from pause points

func _ready() -> void:
	env = world_env_node.environment
	time = cycle_duration * 0.25  # Start at daytime peak

func _process(delta: float) -> void:
	var cycle_progress = fmod(time, cycle_duration) / cycle_duration

	if is_paused:
		pause_timer += delta
		if pause_timer >= current_pause_duration:
			is_paused = false
			pause_timer = 0.0
			can_pause = false  # Prevent immediate re-pausing
	else:
		# Check if we are outside all pause zones to re-enable pausing
		if abs(cycle_progress - 0.25) > pause_threshold and abs(cycle_progress - 0.75) > pause_threshold:
			can_pause = true

		if can_pause:
			if abs(cycle_progress - 0.25) < pause_threshold and not paused_at_day:
				start_pause(day_pause)
				paused_at_day = true
				paused_at_night = false
			elif abs(cycle_progress - 0.75) < pause_threshold and not paused_at_night:
				start_pause(night_pause)
				paused_at_night = true
				paused_at_day = false
			else:
				time += delta
		else:
			time += delta

	update_day_night(cycle_progress)

func start_pause(duration: float) -> void:
	is_paused = true
	pause_timer = 0.0
	current_pause_duration = duration

func update_day_night(progress: float) -> void:
	var shifted_progress = fmod(progress - 0.25 + 1.0, 1.0) # shift so midday = 0
	var sun_angle = -90.0 * cos(shifted_progress * PI * 2.0)  # invert angle so sun points up at midday
	sun.rotation_degrees = Vector3(sun_angle, 0.0, 0.0)

	var light_factor = clamp(sin(progress * PI * 2.0), 0.0, 1.0)
	sun.light_energy = lerp(0.1, 2.0, light_factor)
	env.ambient_light_energy = lerp(0.1, 1.0, light_factor)
	env.tonemap_exposure = lerp(0.01, 1.0, light_factor)
	env.tonemap_white = lerp(50.0, 1.0, light_factor)
