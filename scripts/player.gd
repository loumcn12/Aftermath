extends CharacterBody3D

# Player nodes
@onready var player = $"."
@onready var neck = $neck
@onready var head = $neck/Head
@onready var eyes = $neck/Head/eyes
@onready var camera_3d = $neck/Head/eyes/Camera3D
@onready var standing_collision_shape = $standing_collision_shape
@onready var crouching_collision_shape = $crouching_collision_shape
@onready var uncrouch_check = $uncrouch_check

# Speed variables
var current_speed = 5.0
@export var walking_speed = 5.0
@export var sprinting_speed = 8.0
@export var crouching_speed = 3.0


# Stamina Variables

@export var stamina = Globalscript.globalStamina
@export var WalkRecharge = 1
@export var CrouchRecharge = 2
@export var SprintDischarge = 1

# States

var walking = false
var sprinting = false
var crouching = false

# Stats

@export var Health = 100

# Head bobbing vars

const head_bobbing_sprinting_speed = 22.0
const head_bobbing_walking_speed = 14.0
const head_bobbing_crouching_speed = 10.0

var head_bobbing_sprinting_intensity = 0.2
var head_bobbing_walking_intensity = 0.1
var head_bobbing_crouching_intensity = 0.05

var head_bobbing_vector = Vector2.ZERO
var head_bobbing_index = 0.0
var head_bobbing_current_intensity = 0.0

# Dimension variables
@export var jump_velocity = 4.5
var lerp_speed = 10.0
var air_lerp_speed = 3.0
var crouching_depth = -0.5
var player_height = 1.8

# Input variables
var direction = Vector3.ZERO
@export var mouse_sens = 0.25

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	# Make the mouse cursor invisible and locked to the centre of the screen
	if OS.get_name() == "MacOS":
		OS.crash("Error 404 - User's brain not found")
	
func reset():
	get_tree().reload_current_scene()
	
func _input(event):
	# Make the camera movement match mouse movement
	if event is InputEventMouseMotion:
		
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-80), deg_to_rad(80))
	if Input.is_action_just_pressed("DamageTest"):
		_Damage(20)
	if Input.is_action_just_pressed("reset"):
		reset()

func _physics_process(delta):
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	
	# Handle crouching and sprinting
	if (Input.is_action_pressed("crouch") and is_on_floor()):
		
		# Crouching
		
		current_speed = lerp(current_speed, crouching_speed, delta * lerp_speed)
		head.position.y = lerp(head.position.y,player_height -1.8 + crouching_depth,delta*lerp_speed)
		
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false	
		
		walking = false
		sprinting = false
		crouching = true
		
	elif !uncrouch_check.is_colliding():
		
		# Standing
		
		head.position.y = lerp(head.position.y,player_height - 1.8,delta*lerp_speed)
		
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true
		
		if Input.is_action_pressed("sprint") and (stamina > 1):
			
			# Sprinting
			
			current_speed = lerp(current_speed, sprinting_speed, delta * lerp_speed)
			
			walking = false
			sprinting = true
			crouching = false
		else:
			
			# Walking
			
			current_speed = lerp(current_speed, walking_speed, delta * lerp_speed)
			
			walking = true
			sprinting = false
			crouching = false
			
	
	# Handle headbob
	if sprinting:
		head_bobbing_current_intensity = head_bobbing_sprinting_intensity
		head_bobbing_index += head_bobbing_sprinting_speed * delta
	elif walking:
		head_bobbing_current_intensity = head_bobbing_walking_intensity
		head_bobbing_index += head_bobbing_walking_speed * delta
	elif crouching:
		head_bobbing_current_intensity = head_bobbing_crouching_intensity
		head_bobbing_index += head_bobbing_crouching_speed * delta
		
		
	# Handle Stamina
	if sprinting and (stamina > 1):
		stamina = stamina - SprintDischarge
	elif walking and (stamina <= 100):
		stamina = stamina + WalkRecharge
	elif crouching and (stamina <= 100):
		stamina = stamina + CrouchRecharge
	if stamina < 1:
		stamina = 1
	elif stamina > 100:
		stamina = 100
		
	Globalscript.globalStamina = stamina
	
	if is_on_floor() && input_dir != Vector2.ZERO:
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index/2)+0.5
		
		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y*(head_bobbing_current_intensity/2.0),delta*lerp_speed)
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x*head_bobbing_current_intensity,delta*lerp_speed)
	else:
		eyes.position.y = lerp(eyes.position.y, 0.0,delta*lerp_speed)
		eyes.position.x = lerp(eyes.position.x, 0.0,delta*lerp_speed)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and (stamina > 1):
		velocity.y = jump_velocity
	

	if is_on_floor():
		direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed)
	else:
		if input_dir != Vector2.ZERO:
			direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*air_lerp_speed)
		
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	# Reset the scene if prompted or if player falls out of world
	
	

	move_and_slide()


func _Damage(Damage: float) -> void:
	Health -= Damage
	if Health <= 0:
		reset()
