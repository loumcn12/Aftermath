extends CharacterBody3D

@export var patrol_points: Array[Vector3] = [Vector3(0, 0, 0), Vector3(10, 0, 0), Vector3(20, 0, -15), Vector3(0, 0, -20)]
@export var patrol_speed: float = 3.0
@export var chase_speed: float = 5.0
@export var wait_time_at_point: float = 1.0

var current_point_index := 0
var waiting := false
var wait_timer := 0.0
var chasing := false
var player: Node3D = null
var player_visible := false
var last_known_patrol_position: Vector3

@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var detection_area: Area3D = $DetectionArea
@onready var los_ray: RayCast3D = $LineOfSightRay

func _ready():
	if patrol_points.is_empty():
		push_warning("Patrol points are empty.")
		return

	agent.target_position = patrol_points[current_point_index]

	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

func _process(delta):
	if chasing and is_instance_valid(player):
		_update_line_of_sight()
		if player_visible:
			agent.target_position = player.global_transform.origin
			move_towards_target(delta, chase_speed)
			return
		else:
			# Lost line of sight, stop chasing
			chasing = false
			player = null
			agent.target_position = last_known_patrol_position

	if waiting:
		wait_timer -= delta
		if wait_timer <= 0:
			waiting = false
			advance_to_next_point()
		return

	if agent.is_navigation_finished():
		waiting = true
		wait_timer = wait_time_at_point
		velocity = Vector3.ZERO
		return

	move_towards_target(delta, patrol_speed)

func move_towards_target(_delta: float, speed: float):
	var next_pos = agent.get_next_path_position()
	var dir = (next_pos - global_transform.origin).normalized()
	velocity = dir * speed
	move_and_slide()
	look_at(next_pos, Vector3.UP)

func advance_to_next_point():
	current_point_index = (current_point_index + 1) % patrol_points.size()
	last_known_patrol_position = patrol_points[current_point_index]
	agent.target_position = last_known_patrol_position

func _on_body_entered(body: Node):
	if body.name == "Player":
		player = body
		_update_line_of_sight()
		if player_visible:
			chasing = true

func _on_body_exited(body: Node):
	if body == player:
		player = null
		chasing = false
		agent.target_position = last_known_patrol_position

func _update_line_of_sight():
	if not is_instance_valid(player):
		player_visible = false
		return

	var from_pos = global_transform.origin + Vector3.UP * 1.5  # Raise to "eyes" height
	var to_pos = player.global_transform.origin + Vector3.UP * 1.5

	los_ray.target_position = to_pos - from_pos
	los_ray.origin = from_pos
	los_ray.force_raycast_update()

	if los_ray.is_colliding():
		var collider = los_ray.get_collider()
		player_visible = collider == player
	else:
		player_visible = false
