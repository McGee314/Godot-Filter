extends CharacterBody3D

# Movement settings (from working complex systems)
var MOVE_SPEED: float = 8.0
var RUN_SPEED: float = 16.0
var JUMP_FORCE: float = 15.0
var ACCELERATION: float = 25.0
var DECELERATION: float = 30.0
var AIR_CONTROL: float = 0.3

# Physics settings (from working complex systems)
var gravity: float = 40.0
var max_fall_speed: float = 50.0

# Complex camera settings (increased sensitivity for better control)
var mouse_sensitivity: float = 0.00125
var camera_distance: float = 6.0
var camera_height: float = 1.5
var camera_smoothness: float = 2.0  # Reduced for more responsive feel
var max_pitch: float = 70.0
var min_pitch: float = -30.0

# Complex physics variables
var current_speed: float = 0.0
var target_speed: float = 0.0
var velocity_horizontal: Vector2 = Vector2.ZERO
var is_running: bool = false
var is_grounded: bool = false

# Camera variables
var camera_rotation: Vector2 = Vector2.ZERO
var target_camera_rotation: Vector2 = Vector2.ZERO

# Mouse/UI behavior
var require_right_mouse_to_rotate: bool = false
var last_mouse_delta: Vector2 = Vector2.ZERO

# Jump cooldown (from working simple version)
var jump_cooldown: float = 0.0
var jump_delay: float = 0.3

# Input action variables
var move_input: Vector2 = Vector2.ZERO

# Node references - flexible camera setup
@onready var camera_pivot: Node3D = $CameraPivot
var camera_arm: SpringArm3D
var camera: Camera3D

# FPS monitoring
var fps_update_timer: float = 0.0
var fps_update_interval: float = 1.0  # Update FPS every 1 second
var frame_count: int = 0
var fps: float = 0.0

func _ready():
	GameLogger.info("Integrated Player Controller initialized")
	GameLogger.info("Features: Complex Physics + Complex Camera + Input Actions")
	GameLogger.info("Controls: WASD = Move, Shift = Run, Space = Jump, RMB = Look, ESC = Exit")
	
	# Set mouse mode to captured for camera control
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Add to player group for radar system
	add_to_group("player")
	
	# Robust camera node resolution (supports CameraArm or SpringArm3D)
	GameLogger.info("Resolving camera nodes...")
	GameLogger.info("CameraPivot exists: " + str(has_node("CameraPivot")))
	
	if has_node("CameraPivot"):
		GameLogger.info("CameraArm exists: " + str(has_node("CameraPivot/CameraArm")))
		GameLogger.info("SpringArm3D exists: " + str(has_node("CameraPivot/SpringArm3D")))
	
	# Try CameraArm first (for Fixed scene)
	if has_node("CameraPivot/CameraArm"):
		camera_arm = get_node("CameraPivot/CameraArm") as SpringArm3D
		if has_node("CameraPivot/CameraArm/Camera3D"):
			camera = get_node("CameraPivot/CameraArm/Camera3D") as Camera3D
			GameLogger.info("Camera resolved via CameraArm path")
		else:
			GameLogger.error("Camera3D not found under CameraArm")
	# Try SpringArm3D (for TerrainAssets scene)
	elif has_node("CameraPivot/SpringArm3D"):
		camera_arm = get_node("CameraPivot/SpringArm3D") as SpringArm3D
		if has_node("CameraPivot/SpringArm3D/Camera3D"):
			camera = get_node("CameraPivot/SpringArm3D/Camera3D") as Camera3D
			GameLogger.info("Camera resolved via SpringArm3D path")
		else:
			GameLogger.error("Camera3D not found under SpringArm3D")
	else:
		GameLogger.error("No camera arm found at CameraPivot/CameraArm or CameraPivot/SpringArm3D")
	
	# Ensure camera is current if found
	if camera:
		camera.current = true
	
	# Setup complex camera system
	setup_complex_camera()

func _physics_process(delta: float):
	# Get input using input actions
	move_input = get_input_actions()
	# Only log when there's actual input
	if move_input.length() > 0.1:
		GameLogger.debug("_physics_process - move_input: " + str(move_input))
	
	# Complex physics system
	handle_complex_movement(delta)
	handle_complex_jumping(delta)
	apply_complex_gravity(delta)
	
	# Complex camera system
	handle_complex_camera(delta)
	
	# Move like the demo
	move_and_slide()
	
	# Update FPS monitoring
	update_fps_monitoring(delta)
	
	# Logging
	log_integrated_status()

func get_input_actions() -> Vector2:
	## Get input using input actions (from working input actions test)
	var input = Vector2.ZERO
	var path: String = ""
	
	# Debug: Check if actions exist (reduced logging)
	if input == Vector2.ZERO:  # Only log when no input detected
		GameLogger.debug("=== INPUT DEBUG ===")
		GameLogger.debug("move_forward exists: " + str(InputMap.has_action("move_forward")))
		GameLogger.debug("move_back exists: " + str(InputMap.has_action("move_back")))
		GameLogger.debug("move_left exists: " + str(InputMap.has_action("move_left")))
		GameLogger.debug("move_right exists: " + str(InputMap.has_action("move_right")))
	
	# Prefer project input actions if present
	if InputMap.has_action("move_forward") and Input.is_action_pressed("move_forward"):
		input.y -= 1
		path = "actions"
		GameLogger.debug("W/Forward pressed via actions")
	if InputMap.has_action("move_back") and Input.is_action_pressed("move_back"):
		input.y += 1
		path = "actions"
		GameLogger.debug("S/Back pressed via actions")
	if InputMap.has_action("move_left") and Input.is_action_pressed("move_left"):
		input.x -= 1
		path = "actions"
		GameLogger.debug("A/Left pressed via actions")
	if InputMap.has_action("move_right") and Input.is_action_pressed("move_right"):
		input.x += 1
		path = "actions"
		GameLogger.debug("D/Right pressed via actions")
	
	# Fallback to ui_* if custom actions are missing
	if input == Vector2.ZERO:
		if InputMap.has_action("ui_up") and Input.is_action_pressed("ui_up"):
			input.y -= 1
			path = "ui"
		if InputMap.has_action("ui_down") and Input.is_action_pressed("ui_down"):
			input.y += 1
			path = "ui"
		if InputMap.has_action("ui_left") and Input.is_action_pressed("ui_left"):
			input.x -= 1
			path = "ui"
		if InputMap.has_action("ui_right") and Input.is_action_pressed("ui_right"):
			input.x += 1
			path = "ui"
	
	# Raw physical WASD fallback as last resort
	if input == Vector2.ZERO:
		if Input.is_physical_key_pressed(KEY_W):
			input.y -= 1
			path = "phys"
			GameLogger.debug("W pressed via physical key")
		if Input.is_physical_key_pressed(KEY_S):
			input.y += 1
			path = "phys"
			GameLogger.debug("S pressed via physical key")
		if Input.is_physical_key_pressed(KEY_A):
			input.x -= 1
			path = "phys"
			GameLogger.debug("A pressed via physical key")
		if Input.is_physical_key_pressed(KEY_D):
			input.x += 1
			path = "phys"
			GameLogger.debug("D pressed via physical key")
	
	# Check for running
	is_running = (InputMap.has_action("sprint") and Input.is_action_pressed("sprint")) or Input.is_physical_key_pressed(KEY_SHIFT)
	
	var normalized = input.normalized()
	if normalized == Vector2.ZERO:
		GameLogger.debug("Input: no direction detected (path=" + path + ")")
	else:
		GameLogger.debug("Input: " + str(normalized) + " (path=" + path + ", running=" + str(is_running) + ")")
	return normalized

func handle_complex_movement(delta: float):
	## Complex movement with acceleration/deceleration (from working complex physics)
	is_grounded = is_on_floor()
	
	# Get camera-relative direction
	var direction: Vector3 = get_camera_relative_input()
	var input_vector = Vector2(direction.x, direction.z)
	
	# Debug input
	if input_vector.length() > 0.1:
		GameLogger.debug("Movement input: " + str(input_vector) + " (move_input: " + str(move_input) + ")")
	
	# Determine target speed
	if input_vector.length() > 0.1:
		target_speed = RUN_SPEED if is_running else MOVE_SPEED
	else:
		target_speed = 0.0
	
	# Apply acceleration/deceleration
	var acceleration_rate = ACCELERATION if target_speed > current_speed else DECELERATION
	current_speed = move_toward(current_speed, target_speed, acceleration_rate * delta)
	
	# Calculate movement direction
	var movement_direction = input_vector.normalized() if input_vector.length() > 0.1 else Vector2.ZERO
	
	# Apply movement with complex physics
	if is_grounded:
		# Ground movement
		velocity_horizontal = movement_direction * current_speed
	else:
		# Air movement with reduced control
		var air_movement = movement_direction * current_speed * AIR_CONTROL
		velocity_horizontal = velocity_horizontal.lerp(air_movement, 0.1)
	
	# Apply horizontal velocity
	velocity.x = velocity_horizontal.x
	velocity.z = velocity_horizontal.y

func handle_complex_jumping(delta: float):
	## Complex jumping system (from working complex physics)
	if ((InputMap.has_action("ui_accept") and Input.is_action_pressed("ui_accept")) or Input.is_physical_key_pressed(KEY_SPACE)) and is_grounded and jump_cooldown <= 0.0:
		velocity.y = JUMP_FORCE
		jump_cooldown = jump_delay
		GameLogger.debug("INTEGRATED JUMP! Velocity: " + str(velocity))
	
	# Update jump cooldown
	if jump_cooldown > 0.0:
		jump_cooldown -= delta

func apply_complex_gravity(delta: float):
	## Complex gravity with fall speed limiting (from working complex physics)
	if not is_grounded:
		velocity.y -= gravity * delta
		velocity.y = max(velocity.y, -max_fall_speed)
	else:
		# Ensure we're properly grounded
		if velocity.y < 0:
			velocity.y = 0

func setup_complex_camera():
	## Setup complex camera system (from working complex camera)
	if not camera_pivot or not camera_arm or not camera:
		GameLogger.error("❌ Complex camera setup failed - missing nodes")
		return
	
	# Set initial camera position
	camera_arm.spring_length = camera_distance
	camera_pivot.position.y = camera_height
	
	# Ensure camera is looking forward, not down
	camera_pivot.rotation = Vector3.ZERO
	camera_arm.rotation = Vector3.ZERO
	camera.rotation = Vector3.ZERO
	
	# Set initial camera rotation to look forward
	target_camera_rotation = Vector2.ZERO
	camera_rotation = Vector2.ZERO
	
	GameLogger.info("✅ Complex camera system initialized")
	GameLogger.info("Camera position: " + str(camera.global_position))
	GameLogger.info("Camera rotation: " + str(camera.global_rotation))
	GameLogger.info("Camera pivot position: " + str(camera_pivot.global_position))
	GameLogger.info("Camera arm position: " + str(camera_arm.global_position))
	GameLogger.info("Player position: " + str(global_position))

func handle_complex_camera(delta: float):
	## Complex camera handling (from working complex camera)
	if not camera_pivot or not camera_arm or not camera:
		return
	
	# Handle mouse input for camera rotation
	handle_mouse_look()
	
	# Update camera rotation with smoothing
	camera_rotation = camera_rotation.lerp(target_camera_rotation, camera_smoothness * delta)
	
	# Apply camera rotation
	camera_pivot.rotation.y = camera_rotation.x
	camera_arm.rotation.x = camera_rotation.y

func handle_mouse_look():
	## Mouse look handling (from working complex camera)
	# Only rotate when RMB is held if required, so UI remains usable
	if require_right_mouse_to_rotate and not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		GameLogger.debug("Mouse look blocked - RMB required but not pressed")
		return
	
	var mouse_delta = last_mouse_delta
	last_mouse_delta = Vector2.ZERO
	
	if mouse_delta.length() > 0.0:
		GameLogger.debug("Mouse look processing - delta: " + str(mouse_delta))
		# Update target rotation
		target_camera_rotation.x -= mouse_delta.x * mouse_sensitivity
		target_camera_rotation.y -= mouse_delta.y * mouse_sensitivity
		
		# Clamp pitch
		target_camera_rotation.y = clamp(target_camera_rotation.y, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
		GameLogger.debug("Target camera rotation: " + str(target_camera_rotation))

func get_camera_relative_input() -> Vector3:
	## Get input relative to complex camera system (from working complex camera)
	var input_dir: Vector3 = Vector3.ZERO
	
	# Only log when there's actual input
	if move_input.length() > 0.1:
		GameLogger.debug("get_camera_relative_input called - move_input: " + str(move_input))
	
	if not camera:
		GameLogger.error("❌ No camera found for input")
		return input_dir
	
	GameLogger.debug("Camera found - using for input calculation")
	
	# Use complex camera for input
	if move_input.x < 0: # Left
		input_dir -= camera.global_transform.basis.x
		GameLogger.debug("Left input detected")
	if move_input.x > 0: # Right
		input_dir += camera.global_transform.basis.x
		GameLogger.debug("Right input detected")
	if move_input.y < 0: # Forward
		input_dir -= camera.global_transform.basis.z
		GameLogger.debug("Forward input detected")
	if move_input.y > 0: # Backward
		input_dir += camera.global_transform.basis.z
		GameLogger.debug("Backward input detected")
	
	GameLogger.debug("Final input_dir: " + str(input_dir))
	return input_dir

func log_integrated_status():
	## Log integrated status for debugging
	if is_grounded:
		if velocity.length() > 0.1:
			var jump_status = " (Can Jump)" if jump_cooldown <= 0.0 else " (Jump Cooldown: %.1f)" % jump_cooldown
			var speed_status = " (Speed: %.1f/%.1f)" % [current_speed, target_speed]
			var camera_status = " (Camera: %.1f, %.1f)" % [camera_rotation.x, camera_rotation.y]
			var input_status = " (Input: %s)" % move_input
			GameLogger.debug("INTEGRATED MOVING! Pos: " + str(global_position) + " Vel: " + str(velocity) + speed_status + camera_status + input_status + jump_status)
		else:
			var jump_status = " (Can Jump)" if jump_cooldown <= 0.0 else " (Jump Cooldown: %.1f)" % jump_cooldown
			var camera_status = " (Camera: %.1f, %.1f)" % [camera_rotation.x, camera_rotation.y]
			var input_status = " (Input: %s)" % move_input
			GameLogger.debug("INTEGRATED GROUNDED! Pos: " + str(global_position) + " Vel: " + str(velocity) + camera_status + input_status + jump_status)
	else:
		GameLogger.debug("INTEGRATED FALLING: velocity.y=" + str(velocity.y) + " pos=" + str(global_position))

func update_fps_monitoring(delta: float):
	## Update FPS monitoring
	frame_count += 1
	fps_update_timer += delta
	
	# Update FPS display every update_interval seconds
	if fps_update_timer >= fps_update_interval:
		fps = frame_count / fps_update_timer
		frame_count = 0
		fps_update_timer = 0.0
		
		# Print FPS to console
		var fps_text = "FPS: %.1f" % fps
		if fps >= 60:
			fps_text += " (Excellent)"
		elif fps >= 30:
			fps_text += " (Good)"
		else:
			fps_text += " (Poor)"
		
		GameLogger.debug(fps_text)

func _input(event):
	if event is InputEventKey and event.pressed:
		# Debug all key presses to see what's being received
		GameLogger.debug("🎮 [Player Input] Key pressed: %s (keycode: %d)" % [OS.get_keycode_string(event.keycode), event.keycode], "GraphSystem")
		
		if event.keycode == KEY_M:
			# Toggle mouse mode with M key
			if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				GameLogger.info("Mouse mode: VISIBLE")
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				GameLogger.info("Mouse mode: CAPTURED")
		elif event.keycode == KEY_ESCAPE:
			# ESC key - let the scene's exit system handle it (don't quit directly)
			GameLogger.info("🔧 PlayerControllerIntegrated: ESC pressed - letting scene handle exit")
			# Don't call get_tree().quit() directly - let RegionSceneController handle it
		elif event.keycode in [KEY_5, KEY_6, KEY_7, KEY_8, KEY_9]:
			# Pass terrain generation keys to terrain controller
			GameLogger.info("🔑 [Player Input] Terrain key %s detected - passing to terrain controller..." % OS.get_keycode_string(event.keycode), "GraphSystem")
			# Don't consume the event - let it propagate to terrain controller
			return
		else:
			# For other keys, consume the event to prevent propagation
			get_viewport().set_input_as_handled()
	
	# Handle mouse input for camera
	if event is InputEventMouseMotion:
		GameLogger.debug("Mouse motion detected - mode: " + str(Input.get_mouse_mode()) + ", delta: " + str(event.relative))
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			last_mouse_delta = event.relative
			GameLogger.debug("Mouse delta captured: " + str(last_mouse_delta))
