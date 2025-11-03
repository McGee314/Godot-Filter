class_name CulturalPlayerController
extends CharacterBody3D
@export_group("Movement")
@export var max_speed : float = 4.0
@export var acceleration : float = 20.0
@export var braking : float = 20.0
@export var air_acceleration : float = 4.0
@export var jump_force : float = 5.0
@export var gravity_modifier : float = 1.5
@export var max_run_speed : float = 6.0
var is_running : bool = false

@export_group("Camera")
@export var look_sensitivity : float = 0.02  # Increased further for trackpad
var camera_look_input : Vector2

@onready var camera : Camera3D = get_node("Camera3D")
@onready var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_modifier

func _ready():
	# Lock the mouse
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	print("=== INPUT TEST MODE ===")
	print("Player controller ready - Testing all inputs")
	
	# Clear any stuck input
	Input.flush_buffered_events()
	print("Input system cleared")
	
	# Force initial velocity to zero
	velocity = Vector3.ZERO
	print("Initial velocity set to zero")
	
	# Debug: Check input actions
	print("=== INPUT ACTIONS CHECK ===")
	print("move_forward: ", InputMap.has_action("move_forward"))
	print("move_back: ", InputMap.has_action("move_back"))
	print("move_left: ", InputMap.has_action("move_left"))
	print("move_right: ", InputMap.has_action("move_right"))
	print("jump: ", InputMap.has_action("jump"))
	print("sprint: ", InputMap.has_action("sprint"))
	print("ui_cancel: ", InputMap.has_action("ui_cancel"))
	print("=== END INPUT ACTIONS CHECK ===")

func _physics_process(delta):
	# Apply gravity for vertical movement
	if not is_on_floor():
		velocity.y -= gravity * delta
		print("Not on floor - applying gravity")
	else:
		print("On floor")
	
	# Jumping with debug - Check both action and direct key
	# Modified to work with manual movement system
	var is_on_ground = position.y <= 1.1  # Manual ground detection

	if Input.is_action_pressed("jump") and is_on_ground:
		velocity.y = jump_force
		print("*** JUMP ACTION! ***")
	
	# Horizontal movement - Direct position manipulation (proven to work)
	var move_input = Vector2.ZERO
	
	# Check individual keys with debug
	if Input.is_action_pressed("move_forward"):
		move_input.y -= 1
		print("W ACTION pressed")
		
	if Input.is_action_pressed("move_back"):
		move_input.y += 1
		print("S ACTION pressed")
		
	if Input.is_action_pressed("move_left"):
		move_input.x -= 1
		print("A ACTION pressed")
		
	if Input.is_action_pressed("move_right"):
		move_input.x += 1
		print("D ACTION pressed")
	
	# Apply horizontal movement directly
	if move_input != Vector2.ZERO:
		print("Move input: ", move_input)
		# Normalize input for consistent speed
		move_input = move_input.normalized()
		
		# Determine movement speed
		var current_speed = max_speed
		if Input.is_action_pressed("sprint"):
			current_speed = max_run_speed
			print("*** SPRINT! ***")
		
		# Calculate movement based on camera direction
		var camera_forward = -camera.global_transform.basis.z
		var camera_right = camera.global_transform.basis.x
		
		# Remove Y component to keep movement horizontal
		camera_forward.y = 0
		camera_right.y = 0
		camera_forward = camera_forward.normalized()
		camera_right = camera_right.normalized()
		
		# Calculate movement direction
		var move_direction = Vector3.ZERO
		move_direction += camera_forward * -move_input.y  # Forward/backward
		move_direction += camera_right * move_input.x     # Left/right
		
		# Apply horizontal movement directly
		var move_speed = current_speed * delta
		position.x += move_direction.x * move_speed
		position.z += move_direction.z * move_speed
		print("Position: ", position)
	
	# Apply vertical movement with ground collision
	if velocity.y != 0:
		position.y += velocity.y * delta
		
		# Simple ground collision - prevent going below Y=1.0 (adjust as needed)
		if position.y < 1.0:
			position.y = 1.0
			velocity.y = 0
	
	# Camera Look with debug
	if camera_look_input != Vector2.ZERO:
		print("Camera input: ", camera_look_input)
	
	rotate_y(-camera_look_input.x * look_sensitivity)	
	camera.rotate_x(-camera_look_input.y * look_sensitivity)
	camera.rotation.x = clamp(camera.rotation.x, -1.5, 1.5)
	camera_look_input = Vector2.ZERO
	
	# Mouse
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			print("Mouse captured")
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			print("Mouse visible")

func _unhandled_input(event):
		
	if event is InputEventMouseMotion:
		camera_look_input = event.relative
		print("Mouse motion detected: ", event.relative)
	elif event is InputEventKey:
		if event.pressed:
			print("Key pressed - Keycode: ", event.keycode, " | Physical: ", event.physical_keycode)
			if event.keycode == KEY_SPACE:
				print("*** SPACEBAR DETECTED ***")
			elif event.keycode == KEY_SHIFT:
				print("*** SHIFT DETECTED ***")
			elif event.keycode == KEY_ESCAPE:
				print("*** ESCAPE DETECTED ***")
			elif event.keycode == KEY_W:
				print("*** W KEY DETECTED ***")
			elif event.keycode == KEY_A:
				print("*** A KEY DETECTED ***")
			elif event.keycode == KEY_S:
				print("*** S KEY DETECTED ***")
			elif event.keycode == KEY_D:
				print("*** D KEY DETECTED ***")
