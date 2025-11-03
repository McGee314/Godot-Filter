class_name CameraManager
extends Node3D

## Camera Manager - Facade for camera view system (SOLID: Interface Segregation + Facade Pattern)
## Provides simple interface to complex camera view system

signal camera_view_changed(view_name: String)

# Current view management
var current_view: CameraViewBase
var current_view_type: CameraViewFactory.ViewType = CameraViewFactory.ViewType.PLAYER_VIEW

# References
var camera: Camera3D
var player: Node3D
var terrain_controller: Node3D

# View instances (lazy loaded)
var view_instances: Dictionary = {}

func _ready():
	GameLogger.info("📷 CameraManager initializing...")
	
	# Setup references
	setup_references()
	
	# Initialize with player view
	switch_to_view(CameraViewFactory.ViewType.PLAYER_VIEW)
	
	GameLogger.info("✅ CameraManager ready")

func setup_references():
	"""Setup camera, player, and terrain controller references"""
	# Find camera
	var camera_paths = ["Camera3D", "../Camera3D", "../../Camera3D", "../Player/Camera3D"]
	for path in camera_paths:
		camera = get_node_or_null(path)
		if camera:
			GameLogger.info("✅ CameraManager found camera at: %s" % path)
			break
	
	if not camera:
		GameLogger.error("❌ CameraManager: Camera not found")
		return
	
	# Find player
	var player_paths = ["../Player", "../../Player", "../../../Player"]
	for path in player_paths:
		player = get_node_or_null(path)
		if player:
			GameLogger.info("✅ CameraManager found player at: %s" % path)
			break
	
	if not player:
		GameLogger.warning("⚠️ CameraManager: Player not found")
	
	# Find terrain controller
	terrain_controller = get_node_or_null("../TerrainController")
	if terrain_controller:
		GameLogger.info("✅ CameraManager found terrain controller")
	else:
		GameLogger.warning("⚠️ CameraManager: Terrain controller not found")

func _input(event):
	"""Handle camera view switching input"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				switch_to_view(CameraViewFactory.ViewType.PLAYER_VIEW)
			KEY_2:
				switch_to_view(CameraViewFactory.ViewType.FAR_SIDE_VIEW)
			KEY_3:
				switch_to_view(CameraViewFactory.ViewType.CANOPY_VIEW)

func switch_to_view(view_type: CameraViewFactory.ViewType):
	"""Switch to a specific camera view (SOLID: Open/Closed Principle)"""
	if view_type == current_view_type:
		GameLogger.info("📷 Already in %s - no change needed" % CameraViewFactory.get_view_name(view_type))
		return
	
	var old_view_name = CameraViewFactory.get_view_name(current_view_type)
	var new_view_name = CameraViewFactory.get_view_name(view_type)
	
	GameLogger.info("📷 Switching camera view: %s → %s" % [old_view_name, new_view_name])
	
	# Deactivate current view
	if current_view:
		current_view.on_view_deactivated()
	
	# Get or create new view instance
	var new_view = get_or_create_view(view_type)
	if not new_view:
		GameLogger.error("❌ Failed to create camera view: %s" % new_view_name)
		return
	
	# Setup new view
	new_view.setup_references(camera, player, terrain_controller)
	new_view.update_targets()
	new_view.on_view_activated()
	
	# Update current state
	current_view = new_view
	current_view_type = view_type
	
	# Emit signal
	emit_signal("camera_view_changed", new_view_name)
	
	GameLogger.info("✅ Camera view switched to: %s" % new_view_name)

func get_or_create_view(view_type: CameraViewFactory.ViewType) -> CameraViewBase:
	"""Get existing view instance or create new one (SOLID: Lazy Loading)"""
	var view_key = str(view_type)
	
	# Return existing instance if available
	if view_key in view_instances:
		return view_instances[view_key]
	
	# Create new instance using factory
	var new_view = CameraViewFactory.create_view(view_type)
	if new_view:
		view_instances[view_key] = new_view
		add_child(new_view)  # Add to scene tree for proper lifecycle
		GameLogger.info("📷 Created new view instance: %s" % CameraViewFactory.get_view_name(view_type))
	
	return new_view

func _process(delta):
	"""Update current camera view"""
	if current_view:
		# Update view targets (for player-following views)
		current_view.update_targets()
		
		# Apply smooth transition
		current_view.apply_smooth_transition(delta)

## Public interface methods (SOLID: Interface Segregation)

func get_current_view_name() -> String:
	"""Get name of current camera view"""
	return CameraViewFactory.get_view_name(current_view_type)

func get_current_view_info() -> Dictionary:
	"""Get detailed information about current view"""
	if current_view:
		return current_view.get_view_info()
	return {}

func get_available_views() -> Array:
	"""Get list of all available camera views"""
	var views = []
	for view_type in CameraViewFactory.get_all_view_types():
		views.append({
			"type": view_type,
			"name": CameraViewFactory.get_view_name(view_type),
			"description": CameraViewFactory.get_view_description(view_type),
			"key": CameraViewFactory.get_view_key_binding(view_type)
		})
	return views

func force_camera_update():
	"""Force immediate camera position update (no smooth transition)"""
	if current_view:
		current_view.update_targets()
		if camera:
			camera.global_position = current_view.target_position
			camera.rotation = current_view.target_rotation
		GameLogger.info("📷 Camera position force updated for: %s" % get_current_view_name())

## Debug and utility methods

func print_camera_status():
	"""Print current camera status for debugging"""
	GameLogger.info("📷 Camera Manager Status:")
	GameLogger.info("  Current View: %s" % get_current_view_name())
	GameLogger.info("  Camera Position: %s" % (camera.global_position if camera else "No camera"))
	GameLogger.info("  Target Position: %s" % (current_view.target_position if current_view else "No view"))
	GameLogger.info("  Player Position: %s" % (player.global_position if player else "No player"))
	GameLogger.info("  Active Views: %d" % view_instances.size())

func reset_to_player_view():
	"""Reset camera to default player view"""
	switch_to_view(CameraViewFactory.ViewType.PLAYER_VIEW)
	force_camera_update()
	GameLogger.info("🔄 Camera reset to player view")
