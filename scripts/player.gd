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
@onready var ray = $neck/Head/eyes/Camera3D/Interactioncast
@onready var pickup_notifier = $PlayerHud/Control/pickup_notifier
@onready var punch_notifier = $PlayerHud/Control/punch_notifier

# Speed variables
var current_speed = 5.0
const walking_speed = 5.0
const sprinting_speed = 10.0
const crouching_speed = 3.0


# Stamina Variables

var stamina = Globalscript.globalStamina
const WalkRecharge = 10
const CrouchRecharge = 30
const SprintDischarge = 50
const BaseRecharge = 20

# States

var walking = false
var sprinting = false
var crouching = false

# Stats

var Health = 100
var was_on_floor_last_frame = true
var max_fall_speed = 0.0
const FALL_DAMAGE_THRESHOLD = 12.0
const FALL_DAMAGE_MULTIPLIER = 15
var healthpacks = 0

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
var jump_velocity = 4.5
var lerp_speed = 10.0
var air_lerp_speed = 3.0
var crouching_depth = -0.5
var player_height = 1.8

# Input variables
var direction = Vector3.ZERO
const mouse_sens = 0.25

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	# Make the mouse cursor invisible and locked to the centre of the screen
	if OS.get_name() == "MacOS":
		OS.crash("Error 404 - User's brain not found")

func reset():
	Globalscript.globalStamina = 100
	get_tree().reload_current_scene()

func death():
	Globalscript.globalStamina = 100
	get_tree().change_scene_to_file("res://scenes/death_screen.tscn")

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
	if healthpacks < 3:
		$PlayerHud/Control/Items.text = "Current Objective: Collect Medpacks (" + str(healthpacks) + "/3)"
	else:
		$PlayerHud/Control/Items.text = "Current Objective: Return to Bunker"
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	
	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider:
			
			if collider.is_in_group("health"):
				pickup_notifier.visible = true
				
				if Input.is_action_just_pressed("interact"):
					heal(collider.healthpoints)
					collider.queue_free()
					healthpacks = healthpacks + 1
			elif !collider.is_in_group("health"):
				pickup_notifier.visible = false
					
			if collider.is_in_group("enemy"):
				punch_notifier.visible = true
				
				if Input.is_action_just_pressed("mouse1"):
					collider._damage(10)
			elif !collider.is_in_group("enemy"):
				punch_notifier.visible = false
	else:
		pickup_notifier.visible = false
		punch_notifier.visible = false
	
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
	if input_dir != Vector2.ZERO:
		if sprinting and (stamina > 1):
			stamina = stamina - (SprintDischarge * 0.01)
			
	if (walking or (sprinting and input_dir == Vector2.ZERO)) and (stamina <= 100) and !Input.is_action_pressed("sprint") and is_on_floor():
		stamina = stamina + (WalkRecharge * 0.01)
	
	elif crouching and (stamina <= 100) and !Input.is_action_pressed("sprint") and is_on_floor():
		stamina = stamina + (CrouchRecharge * 0.01)
	
	if input_dir == Vector2.ZERO and stamina <= 100 and !Input.is_action_pressed("sprint") and is_on_floor():
		stamina = stamina + (BaseRecharge * 0.01)
	
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
	if Input.is_action_just_pressed("jump") and is_on_floor() and (stamina > 5):
		velocity.y = jump_velocity
		if stamina > 5:
			stamina = stamina - 5
		else:
			stamina = 1
	

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
		
	# Track the maximum fall speed
	if !is_on_floor():
		# Track how fast the player is falling
		if velocity.y < max_fall_speed:
			max_fall_speed = velocity.y
	else:
		if !was_on_floor_last_frame:
			# Just landed this frame
			var fall_speed = abs(max_fall_speed)
			if fall_speed > FALL_DAMAGE_THRESHOLD:
				var damage = (fall_speed - FALL_DAMAGE_THRESHOLD) * FALL_DAMAGE_MULTIPLIER
				_Damage(damage)
			max_fall_speed = 0.0  # Reset fall speed on landing

	# Update the previous floor state
	was_on_floor_last_frame = is_on_floor()

	move_and_slide()

func _Damage(Damage: float) -> void:
	Health -= Damage
	if Health <= 0:
		death()
		
func heal(healthpoints: float) -> void:
	if Health < (100 - healthpoints):
		Health += healthpoints
	else:
		Health = 100
	
