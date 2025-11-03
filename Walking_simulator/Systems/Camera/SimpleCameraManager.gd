class_name SimpleCameraManager
extends Node3D

## Configurable Camera Manager for switching between different camera views
## Uses CameraSceneConfig resources for flexible, reusable camera setups

enum CameraMode {
	PLAYER_VIEW,    # Default third-person
	FAR_SIDE_VIEW,  # High overview
	CANOPY_VIEW     # Above forest level
}

@export var camera_config: CameraSceneConfig
@export var config_file_path: String = "res://Resources/Camera/Scenes/SimpleCameraConfig.tres"

var current_mode: CameraMode = CameraMode.PLAYER_VIEW
var camera: Camera3D
var player: Node3D
var terrain_controller: Node3D
var spring_arm: SpringArm3D
var camera_pivot: Node3D

# SpringArm configuration for different views
var original_spring_length: float
var original_spring_position: Vector3
var original_spring_rotation: Vector3

# Camera settings
var transition_speed: float = 2.0
var mouse_sensitivity: float = 0.002

# View configurations are now loaded from CameraSceneConfig resource
# This allows for easy customization per scene without code changes

# Current camera state
var target_position: Vector3
var target_rotation: Vector3
var scene_center: Vector3

func _ready():
	print("=== CONFIGURABLE CAMERAMANAGER STARTING ===")
	GameLogger.info("📷 Configurable SimpleCameraManager initialized")
	GameLogger.info("🔍 SimpleCameraManager node path: %s" % get_path())
	
	# Set higher process priority to run after player controller
	process_priority = 10
	
	# Load camera configuration
	load_camera_config()
	
	# Find camera and player references
	setup_references()
	
	# Calculate scene center
	calculate_scene_center()
	
	# Set initial view
	if camera_config:
		var _default_view = camera_config.get_default_view()  # Prefix with underscore to indicate intentionally unused
		set_camera_mode(CameraMode.PLAYER_VIEW)  # Start with player view
		GameLogger.info("✅ Camera manager ready - Using config: %s" % camera_config.scene_name)
		log_available_views()
	else:
		GameLogger.error("❌ No camera configuration loaded")
	
	print("=== CONFIGURABLE CAMERAMANAGER READY ===")
	
	# Test input processing
	set_process_input(true)
	GameLogger.info("🎮 Input processing enabled for SimpleCameraManager")

func load_camera_config():
	"""Load camera configuration from resource file"""
	if camera_config:
		GameLogger.info("📁 Using assigned camera config: %s" % camera_config.scene_name)
		return
	
	if config_file_path.is_empty():
		GameLogger.warning("⚠️ No config file path specified")
		return
	
	if ResourceLoader.exists(config_file_path):
		var resource = load(config_file_path)
		GameLogger.info("📁 Raw resource loaded: %s" % str(resource))
		
		if resource is CameraSceneConfig:
			camera_config = resource
			GameLogger.info("📁 Loaded camera config from: %s" % config_file_path)
			GameLogger.info("🎬 Scene: %s - %s" % [camera_config.scene_name, camera_config.scene_description])
		else:
			GameLogger.error("❌ Failed to load camera config as CameraSceneConfig")
			GameLogger.error("❌ Resource type: %s" % str(resource.get_class()) if resource else "null")
			GameLogger.warning("⚠️ Using fallback hardcoded camera configuration")
			create_fallback_config()
	else:
		GameLogger.error("❌ Camera config file not found: %s" % config_file_path)
		GameLogger.warning("⚠️ Using fallback hardcoded camera configuration")
		create_fallback_config()

func create_fallback_config():
	"""Create a fallback camera configuration if file loading fails"""
	GameLogger.info("🔧 Creating fallback camera configuration")
	
	# Create a simple CameraSceneConfig manually
	camera_config = CameraSceneConfig.new()
	camera_config.scene_name = "Papua Scene (Fallback)"
	camera_config.scene_description = "Fallback camera configuration"
	camera_config.default_view_index = 0
	
	# Create simple view configs
	var player_view = CameraViewConfig.new()
	player_view.view_name = "Player View"
	player_view.view_description = "Normal third-person player view"
	player_view.key_binding = KEY_1
	player_view.spring_length = 7.0
	player_view.pivot_rotation = Vector3(-0.261799, 0, 0)
	player_view.pivot_offset = Vector3(0, 2.5, 0)
	
	var far_view = CameraViewConfig.new()
	far_view.view_name = "Far Side View"
	far_view.view_description = "High overview from far side"
	far_view.key_binding = KEY_2
	far_view.spring_length = 50.0
	far_view.pivot_rotation = Vector3(-0.785398, 0.785398, 0)
	far_view.pivot_offset = Vector3(0, 30.0, 0)
	
	var canopy_view = CameraViewConfig.new()
	canopy_view.view_name = "Canopy View"
	canopy_view.view_description = "Above forest canopy level"
	canopy_view.key_binding = KEY_3
	canopy_view.spring_length = 15.0
	canopy_view.pivot_rotation = Vector3(-1.0472, 0, 0)
	canopy_view.pivot_offset = Vector3(0, 20.0, 0)
	
	camera_config.views = [player_view, far_view, canopy_view]
	GameLogger.info("✅ Fallback camera configuration created successfully")

func log_available_views():
	"""Log all available camera views"""
	if not camera_config:
		return
	
	GameLogger.info("🎮 Available camera views:")
	var all_views = camera_config.get_all_views()
	for i in range(all_views.size()):
		var view = all_views[i]
		var key_name = OS.get_keycode_string(view.key_binding)
		GameLogger.info("  %s: %s - %s" % [key_name, view.view_name, view.view_description])

func setup_references():
	"""Setup camera and player references"""
	GameLogger.info("🔍 SimpleCameraManager: Starting reference setup...")
	
	# Find camera (try multiple paths)
	var camera_paths = ["Camera3D", "../Camera3D", "../../Camera3D", "../Player/Camera3D", "../Player/CameraPivot/SpringArm3D/Camera3D"]
	GameLogger.info("🔍 Searching for camera in paths: %s" % str(camera_paths))
	
	for path in camera_paths:
		GameLogger.info("🔍 Trying camera path: %s" % path)
		camera = get_node_or_null(path)
		if camera:
			GameLogger.info("✅ Found camera at: %s (Type: %s)" % [path, camera.get_class()])
			break
		else:
			GameLogger.info("❌ No camera at: %s" % path)
	
	if not camera:
		GameLogger.error("❌ Camera not found in any path!")
		return
	
	# Find player
	var player_paths = ["../Player", "../../Player", "../../../Player"]
	GameLogger.info("🔍 Searching for player in paths: %s" % str(player_paths))
	
	for path in player_paths:
		GameLogger.info("🔍 Trying player path: %s" % path)
		player = get_node_or_null(path)
		if player:
			GameLogger.info("✅ Found player at: %s (Type: %s)" % [path, player.get_class()])
			break
		else:
			GameLogger.info("❌ No player at: %s" % path)
	
	if not player:
		GameLogger.warning("⚠️ Player not found - using scene center for positioning")
	else:
		# Find SpringArm3D and CameraPivot in player
		camera_pivot = player.get_node_or_null("CameraPivot")
		if camera_pivot:
			GameLogger.info("✅ Found CameraPivot")
			spring_arm = camera_pivot.get_node_or_null("SpringArm3D")
			if spring_arm:
				GameLogger.info("✅ Found SpringArm3D - will use for camera control")
				# Store original settings
				original_spring_length = spring_arm.spring_length
				original_spring_position = camera_pivot.position
				original_spring_rotation = camera_pivot.rotation
				GameLogger.info("📏 Original SpringArm length: %.2f" % original_spring_length)
			else:
				GameLogger.warning("⚠️ SpringArm3D not found in CameraPivot")
		else:
			GameLogger.warning("⚠️ CameraPivot not found in player")
	
	# Find terrain controller
	GameLogger.info("🔍 Searching for terrain controller at: ../TerrainController")
	terrain_controller = get_node_or_null("../TerrainController")
	if terrain_controller:
		GameLogger.info("✅ Found terrain controller (Type: %s)" % terrain_controller.get_class())
	else:
		GameLogger.warning("⚠️ Terrain controller not found")

func calculate_scene_center():
	"""Calculate the center point of the scene"""
	if player:
		scene_center = player.global_position
	else:
		scene_center = Vector3.ZERO
	
	# Get terrain height at center
	if terrain_controller and terrain_controller.has_method("get_terrain_height_at_position"):
		var terrain_height = terrain_controller.get_terrain_height_at_position(scene_center)
		scene_center.y = terrain_height
	
	GameLogger.info("📍 Scene center calculated: %s" % scene_center)

# Player camera control is now integrated - we configure the SpringArm3D directly
# instead of disabling it, so no need for separate control functions

func _input(event):
	"""Handle camera view switching using configuration"""
	if event is InputEventKey and event.pressed:
		if not camera_config:
			return
		
		# Find camera view by key binding
		var view_config = camera_config.get_view_by_key(event.keycode)
		if view_config:
			var key_name = OS.get_keycode_string(event.keycode)
			GameLogger.info("🔑 %s pressed - switching to %s" % [key_name, view_config.view_name])
			
			# Determine camera mode based on view name
			var camera_mode = get_camera_mode_from_config(view_config)
			if camera_mode != -1:
				set_camera_mode(camera_mode)
			else:
				GameLogger.warning("⚠️ Unknown camera mode for view: %s" % view_config.view_name)
		else:
			# Check if it's a camera key that should be handled
			if event.keycode >= KEY_1 and event.keycode <= KEY_9:
				var key_name = OS.get_keycode_string(event.keycode)
				GameLogger.info("🔑 %s pressed but no camera view configured for this key" % key_name)

func get_camera_mode_from_config(view_config: CameraViewConfig) -> int:
	"""Convert CameraViewConfig to CameraMode enum"""
	if not view_config:
		return -1
	
	# Match by key binding (most reliable)
	match view_config.key_binding:
		KEY_1:
			return CameraMode.PLAYER_VIEW
		KEY_2:
			return CameraMode.FAR_SIDE_VIEW
		KEY_3:
			return CameraMode.CANOPY_VIEW
		_:
			# Try to match by view name as fallback
			var view_name_lower = view_config.view_name.to_lower()
			if "player" in view_name_lower:
				return CameraMode.PLAYER_VIEW
			elif "far" in view_name_lower or "side" in view_name_lower:
				return CameraMode.FAR_SIDE_VIEW
			elif "canopy" in view_name_lower:
				return CameraMode.CANOPY_VIEW
			else:
				return -1  # Unknown mode

func set_camera_mode(new_mode: CameraMode):
	"""Switch to a new camera mode using configuration resource"""
	if new_mode == current_mode:
		return
	
	if not spring_arm or not camera_pivot:
		GameLogger.error("❌ Cannot set camera mode - SpringArm3D or CameraPivot not found")
		return
	
	if not camera_config:
		GameLogger.error("❌ Cannot set camera mode - No camera configuration loaded")
		return
	
	var old_mode = current_mode
	current_mode = new_mode
	
	# Get view configuration from resource
	var view_config = camera_config.get_view_by_index(int(new_mode))
	if not view_config:
		GameLogger.error("❌ No view configuration found for mode: %d" % new_mode)
		return
	
	var old_view_config = camera_config.get_view_by_index(int(old_mode))
	var old_description = old_view_config.view_description if old_view_config else "Unknown"
	
	GameLogger.info("📷 Switching camera: %s → %s" % [old_description, view_config.view_description])
	
	# Apply SpringArm3D configuration from resource
	if view_config.apply_to_spring_arm(spring_arm, camera_pivot):
		GameLogger.info("✅ Camera mode set to: %s" % view_config.view_description)
		GameLogger.info("🔧 Applied config: %s" % view_config.get_debug_info())
	else:
		GameLogger.error("❌ Failed to apply camera configuration")

# Camera configuration is now handled by CameraViewConfig.apply_to_spring_arm()
# This provides better encapsulation and reusability

# Target position calculation is now handled by SpringArm3D automatically
# The SpringArm3D will position the camera based on:
# - spring_length: distance from pivot  
# - pivot_offset: CameraPivot position relative to player
# - pivot_rotation: CameraPivot rotation for camera angle

# Camera movement is now handled by SpringArm3D system
# No need for manual _physics_process override

func get_current_view_info() -> Dictionary:
	"""Get information about current camera view"""
	if not camera_config:
		return {
			"mode": current_mode,
			"description": "No configuration loaded",
			"position": Vector3.ZERO,
			"target_position": Vector3.ZERO,
			"following_player": false
		}
	
	var view_config = camera_config.get_view_by_index(int(current_mode))
	var description = view_config.view_description if view_config else "Unknown view"
	
	return {
		"mode": current_mode,
		"description": description,
		"position": camera.global_position if camera else Vector3.ZERO,
		"target_position": target_position,
		"following_player": current_mode == CameraMode.PLAYER_VIEW
	}

func force_update_position():
	"""Immediately update camera to target position (no smooth transition)"""
	if camera:
		camera.global_position = target_position
		camera.rotation = target_rotation
		GameLogger.info("📷 Camera position force updated")
