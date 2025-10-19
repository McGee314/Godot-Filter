extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var camera: Camera3D = $Player/Camera3D

# Simple movement settings (from working simple version)
var MOVE_SPEED: float = 8.0
var JUMP_SPEED: float = 3.0
var gravity: float = 35.0
var jump_cooldown: float = 0.0
var jump_delay: float = 0.3

# Input action variables
var move_input: Vector2 = Vector2.ZERO
var is_running: bool = false

func _ready():
	print("Input Actions Test initialized")
	print("Testing: Simple physics + Simple camera + Input actions")
	print("Controls: WASD = Move, SPACE = Jump, ESC = Exit")
	print("Note: Requires input actions in project.godot")

func _physics_process(delta: float):
	# Get input using input actions (from PlayerControllerRefactored.gd)
	move_input = get_input_actions()
	
	# Simple movement like working version
	handle_simple_movement(delta)
	handle_simple_jumping(delta)
	apply_simple_gravity(delta)
	
	# Move player
	player.move_and_slide()
	
	# Debug output
	if move_input != Vector2.ZERO:
		print("INPUT ACTIONS! Input: ", move_input, " Velocity: ", player.velocity, " Position: ", player.global_position)

func get_input_actions() -> Vector2:
	var input = Vector2.ZERO
	
	# Check if input actions exist (fallback to direct key input)
	if InputMap.has_action("move_forward"):
		if Input.is_action_pressed("move_forward"):
			input.y -= 1
		if Input.is_action_pressed("move_back"):
			input.y += 1
		if Input.is_action_pressed("move_left"):
			input.x -= 1
		if Input.is_action_pressed("move_right"):
			input.x += 1
	else:
		# Fallback to direct key input
		print("Input actions not found - using direct keys")
		if Input.is_key_pressed(KEY_W):
			input.y -= 1
		if Input.is_key_pressed(KEY_S):
			input.y += 1
		if Input.is_key_pressed(KEY_A):
			input.x -= 1
		if Input.is_key_pressed(KEY_D):
			input.x += 1
	
	return input

func handle_simple_movement(delta: float):
	if move_input != Vector2.ZERO:
		# Get camera relative direction (simple version)
		var direction: Vector3 = get_camera_relative_direction()
		var h_veloc: Vector2 = Vector2(direction.x, direction.z).normalized() * MOVE_SPEED
		
		# Set velocity
		player.velocity.x = h_veloc.x
		player.velocity.z = h_veloc.y

func get_camera_relative_direction() -> Vector3:
	var input_dir: Vector3 = Vector3.ZERO
	
	# Convert input to camera-relative direction
	var camera_forward = -camera.global_transform.basis.z
	var camera_right = camera.global_transform.basis.x
	
	# Remove Y component
	camera_forward.y = 0
	camera_right.y = 0
	camera_forward = camera_forward.normalized()
	camera_right = camera_right.normalized()
	
	# Apply input
	input_dir += camera_forward * -move_input.y
	input_dir += camera_right * move_input.x
	
	return input_dir

func handle_simple_jumping(delta: float):
	# Check for jump input (try action first, fallback to key)
	var jump_pressed = false
	if InputMap.has_action("jump"):
		jump_pressed = Input.is_action_pressed("jump")
	else:
		jump_pressed = Input.is_key_pressed(KEY_SPACE)
	
	if jump_pressed and player.is_on_floor() and jump_cooldown <= 0.0:
		player.velocity.y = JUMP_SPEED
		jump_cooldown = jump_delay
		print("INPUT ACTION JUMP! Velocity: ", player.velocity)
	
	# Update jump cooldown
	if jump_cooldown > 0.0:
		jump_cooldown -= delta

func apply_simple_gravity(delta: float):
	# Apply gravity
	player.velocity.y -= gravity * delta

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			print("ESC pressed - exiting input actions test")
			get_tree().quit()
		elif event.keycode == KEY_1:
			print("Available input actions:")
			var actions = InputMap.get_actions()
			for action in actions:
				print("  - ", action)
		elif event.keycode == KEY_2:
			print("Testing specific actions:")
			print("  move_forward exists: ", InputMap.has_action("move_forward"))
			print("  move_back exists: ", InputMap.has_action("move_back"))
			print("  move_left exists: ", InputMap.has_action("move_left"))
			print("  move_right exists: ", InputMap.has_action("move_right"))
			print("  jump exists: ", InputMap.has_action("jump"))
			print("  sprint exists: ", InputMap.has_action("sprint"))
