class_name CulturalPlayerControllerFixed
extends CharacterBody3D

# Player state
var current_region: String = ""
var is_interacting: bool = false
@export var debug_mode: bool = false  # Disabled to reduce console clutter

# Movement parameters
@export var max_speed: float = 4.0
@export var acceleration: float = 20.0
@export var braking: float = 20.0
@export var air_acceleration: float = 4.0
@export var jump_force: float = 5.0
@export var gravity_modifier: float = 1.5
@export var max_run_speed: float = 6.0

# Camera parameters
@export var look_sensitivity: float = 0.02
@export var min_pitch: float = -1.5
@export var max_pitch: float = 1.5

# Movement state
var player_velocity: Vector3 = Vector3.ZERO
var is_running: bool = false
var is_on_ground: bool = true

# Input state
var move_input: Vector2 = Vector2.ZERO
var camera_input: Vector2 = Vector2.ZERO
var jump_pressed: bool = false
var sprint_pressed: bool = false

# Command Manager
var command_manager: CulturalCommandManager

# References
@onready var camera: Camera3D = $Camera3D
@onready var interaction_controller: Node = $InteractionController
@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_modifier

func _ready():
	_setup_initial_state()
	_connect_signals()
	_setup_command_manager()

func _setup_initial_state():
	# Set initial mouse mode
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Set initial region
	current_region = "Indonesia Timur"  # Updated for Papua scene
	
	if debug_mode:
		print("Player initialized - Region: ", current_region)
		print("Mouse mode: ", Input.get_mouse_mode())
		print("Player position: ", position)

func _connect_signals():
	# Connect interaction signals if available
	if interaction_controller and interaction_controller.has_signal("interaction_started"):
		interaction_controller.interaction_started.connect(_on_interaction_started)
	if interaction_controller and interaction_controller.has_signal("interaction_ended"):
		interaction_controller.interaction_ended.connect(_on_interaction_ended)

func _setup_command_manager():
	# Initialize command manager
	command_manager = CulturalCommandManager.new()
	add_child(command_manager)
	
	# Connect command manager signals
	command_manager.command_executed.connect(_on_command_executed)
	command_manager.command_undone.connect(_on_command_undone)
	command_manager.command_redone.connect(_on_command_redone)
	
	if debug_mode:
		print("Command Manager initialized")

func _input(event):
	_handle_input(event)

func _physics_process(delta):
	_handle_movement(delta)
	_handle_camera(delta)

func _handle_input(event):
	# Mouse look
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		camera_input = event.relative
		if debug_mode:
			GameLogger.debug("Camera input: " + str(camera_input))
	
	# Mouse mode toggle
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			if debug_mode:
				GameLogger.debug("Mouse captured")
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			if debug_mode:
				GameLogger.debug("Mouse visible")
	
	# Movement input debug
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_W or event.keycode == KEY_S or event.keycode == KEY_A or event.keycode == KEY_D:
			if debug_mode:
				GameLogger.debug("Movement key pressed: " + str(event.keycode))
	
	# Undo/Redo commands
	if Input.is_action_just_pressed("undo"):
		_handle_undo()
	
	if Input.is_action_just_pressed("redo"):
		_handle_redo()

func _handle_undo():
	if command_manager and command_manager.can_undo():
		command_manager.undo_command()
		if debug_mode:
			GameLogger.debug("Undo executed")

func _handle_redo():
	if command_manager and command_manager.can_redo():
		command_manager.redo_command()
		if debug_mode:
			GameLogger.debug("Redo executed")

func _handle_movement(delta):
	# Get input
	move_input = Vector2.ZERO
	if Input.is_action_pressed("move_forward"):
		move_input.y -= 1
	if Input.is_action_pressed("move_back"):
		move_input.y += 1
	if Input.is_action_pressed("move_left"):
		move_input.x -= 1
	if Input.is_action_pressed("move_right"):
		move_input.x += 1
	
	# Jump input
	jump_pressed = Input.is_action_pressed("jump")
	
	# Sprint input
	sprint_pressed = Input.is_action_pressed("sprint")
	
	# Update ground state
	is_on_ground = is_on_floor() or position.y <= 1.1
	
	# Apply gravity
	if not is_on_ground:
		player_velocity.y -= gravity * delta
	
	# Handle jumping
	if jump_pressed and is_on_ground:
		player_velocity.y = jump_force
		if debug_mode:
			GameLogger.debug("Player jumped")
	
	# Handle horizontal movement
	if move_input != Vector2.ZERO:
		# Normalize input
		move_input = move_input.normalized()
		
		# Determine speed
		var current_speed = max_speed
		if sprint_pressed:
			current_speed = max_run_speed
			is_running = true
		else:
			is_running = false
		
		# Calculate movement direction based on camera
		var camera_forward = -camera.global_transform.basis.z
		var camera_right = camera.global_transform.basis.x
		
		# Remove Y component
		camera_forward.y = 0
		camera_right.y = 0
		camera_forward = camera_forward.normalized()
		camera_right = camera_right.normalized()
		
		# Calculate movement direction
		var move_direction = Vector3.ZERO
		move_direction += camera_forward * -move_input.y
		move_direction += camera_right * move_input.x
		
		# Apply acceleration
		var target_velocity = move_direction * current_speed
		var acceleration_rate = acceleration if is_on_ground else air_acceleration
		
		player_velocity.x = lerp(player_velocity.x, target_velocity.x, acceleration_rate * delta)
		player_velocity.z = lerp(player_velocity.z, target_velocity.z, acceleration_rate * delta)
		
		if debug_mode and move_input != Vector2.ZERO:
			GameLogger.debug("Move input: " + str(move_input) + " Speed: " + str(current_speed) + " Target velocity: " + str(target_velocity) + " Current velocity: " + str(player_velocity))
	else:
		# Apply braking
		var braking_rate = braking if is_on_ground else air_acceleration
		player_velocity.x = lerp(player_velocity.x, 0.0, braking_rate * delta)
		player_velocity.z = lerp(player_velocity.z, 0.0, braking_rate * delta)
		is_running = false
	
	# Apply movement manually to avoid glitchy movement from move_and_slide()
	# This gives us full control over the physics and prevents unwanted movement
	var movement = player_velocity * delta
	
	# Apply all movement (including Y for jumping)
	position.x += movement.x
	position.y += movement.y
	position.z += movement.z
	
	if debug_mode and (move_input != Vector2.ZERO or jump_pressed):
		GameLogger.debug("Manual movement applied - Position: " + str(position) + " Movement: " + str(movement) + " Velocity: " + str(player_velocity))
	
	# Ground collision
	if position.y < 1.0:
		position.y = 1.0
		player_velocity.y = 0

func _handle_camera(_delta):
	if camera_input != Vector2.ZERO:
		# Apply camera rotation
		rotate_y(-camera_input.x * look_sensitivity)
		camera.rotate_x(-camera_input.y * look_sensitivity)
		
		# Clamp pitch
		camera.rotation.x = clamp(camera.rotation.x, min_pitch, max_pitch)
		
		# Debug output removed - was cluttering console
		# if debug_mode:
		#	print("Camera input: ", camera_input)
		
		# Reset input
		camera_input = Vector2.ZERO

func _on_interaction_started(interactable: Node):
	is_interacting = true
	if debug_mode:
		print("Started interaction with: ", interactable.name)

func _on_interaction_ended(interactable: Node):
	is_interacting = false
	if debug_mode:
		print("Ended interaction with: ", interactable.name)

# Command Manager callbacks
func _on_command_executed(command: CulturalActionCommand):
	if debug_mode:
		print("Command executed: ", command.get_description())

func _on_command_undone(command: CulturalActionCommand):
	if debug_mode:
		print("Command undone: ", command.get_description())

func _on_command_redone(command: CulturalActionCommand):
	if debug_mode:
		print("Command redone: ", command.get_description())

# Public interface
func get_current_region() -> String:
	return current_region

func set_current_region(region: String):
	current_region = region
	if EventBus:
		EventBus.emit_event(EventBus.EventType.SESSION_UPDATE, {
			"update_type": "region_changed",
			"region": region
		}, 3, "player_system")

func is_player_interacting() -> bool:
	return is_interacting

func get_player_position() -> Vector3:
	return global_position

func get_player_velocity() -> Vector3:
	return player_velocity

func is_player_running() -> bool:
	return is_running

func is_player_on_ground() -> bool:
	return is_on_ground

func get_camera() -> Camera3D:
	return camera

func get_interaction_controller() -> Node:
	return interaction_controller

func get_command_manager() -> CulturalCommandManager:
	return command_manager
