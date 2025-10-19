extends Node3D

# Controller for region scenes with back button functionality

func _ready():
	# Start the region session
	var region_name = get_region_name()
	Global.start_region_session(region_name)
	
	# Register with GameSceneManager (if available)
	if has_node("/root/GameSceneManager"):
		var scene_manager = get_node("/root/GameSceneManager")
		if scene_manager:
			scene_manager.set_current_scene(get_scene_name())
	
	# Set up back button (optional - for exhibition use)
	var back_button = get_node_or_null("UI/BackButton")
	if back_button:
		back_button.pressed.connect(_on_back_button_pressed)

func get_region_name() -> String:
	# Determine region name based on scene name
	var scene_name = scene_file_path.get_file().get_basename()
	
	match scene_name:
		"PasarScene":
			return "Indonesia Barat"
		"TamboraScene":
			return "Indonesia Tengah"
		"PapuaScene":
			return "Indonesia Timur"
		"PapuaScene_Terrain3D":
			return "Indonesia Timur (Terrain3D)"
		_:
			return "Unknown Region"

func get_scene_name() -> String:
	# Get the scene name for GameSceneManager
	return scene_file_path.get_file().get_basename()

func _input(event):
	"""Handle input for region scenes"""
	if event.is_action_pressed("ui_cancel"):
		# ESC key - show confirmation dialog before returning to 3D map
		GameLogger.info("🔘 RegionSceneController: ESC key pressed in region scene")
		
		# Check if there's already an active dialog to prevent conflicts
		if UnifiedExitDialog.active_dialog_instance and is_instance_valid(UnifiedExitDialog.active_dialog_instance):
			GameLogger.info("⚠️ RegionSceneController: UnifiedExitDialog already active - ignoring new request")
			get_viewport().set_input_as_handled()
			return
		
		# Aggressively consume the input to prevent other systems from processing it
		get_viewport().set_input_as_handled()
		_show_exit_confirmation()
		return  # Exit function immediately after handling

func _on_back_button_pressed():
	# Back button - show confirmation dialog before returning to 3D map
	GameLogger.info("🔘 RegionSceneController: Back button pressed")
	_show_exit_confirmation()

func _show_exit_confirmation():
	"""Show unified exit confirmation dialog for region scenes"""
	var region_name = get_region_name()
	var scene_name = get_scene_name()
	GameLogger.info("🔧 RegionSceneController: Showing exit confirmation for region: " + region_name + " (Scene: " + scene_name + ")")
	UnifiedExitDialog.show_region_exit_dialog(region_name)

# Note: Escape key handling is now managed by GameSceneManager
# This provides consistent behavior across all game scenes
