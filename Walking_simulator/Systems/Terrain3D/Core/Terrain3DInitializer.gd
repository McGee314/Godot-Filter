extends Node3D

## Papua Scene Terrain3D Initializer
## Handles Terrain3D setup and asset placement for the Papua scene

@onready var terrain3d: Terrain3D
@onready var player: CharacterBody3D
@onready var terrain_controller: Node3D

func _ready():
	GameLogger.info("🌍 PapuaScene_Terrain3D_Initializer: Starting initialization...")
	
	# Get references
	terrain3d = get_node_or_null("../Terrain3DManager/Terrain3D")
	player = get_node_or_null("../Player")
	terrain_controller = get_node_or_null("../TerrainController")
	
	if not terrain3d:
		GameLogger.error("❌ Terrain3D node not found!")
		return
	
	if not player:
		GameLogger.error("❌ Player not found!")
		return
	
	if not terrain_controller:
		GameLogger.error("❌ TerrainController not found!")
		return
	
	# Wait for Terrain3D to be ready
	await get_tree().process_frame
	await get_tree().process_frame  # Extra frame to ensure Terrain3D is ready
	
	# Initialize Terrain3D system
	initialize_terrain3d()
	
	# Wait a bit more for terrain to be generated
	await get_tree().create_timer(1.0).timeout
	
	# Position player on terrain
	position_player_on_terrain()
	
	# Place forest assets (disabled - use F key to generate manually)
	# place_forest_assets()
	
	GameLogger.info("✅ PapuaScene_Terrain3D_Initializer: Initialization complete")

func initialize_terrain3d():
	"""Initialize the Terrain3D system"""
	GameLogger.info("🏗️ Initializing Terrain3D system...")
	
	# Use existing demo terrain data - DO NOT generate new terrain
	GameLogger.info("📁 Using existing demo terrain data from: %s" % terrain3d.data_directory)
	
	# Force Terrain3D to reload the existing data
	if terrain3d.has_method("reload"):
		GameLogger.info("🔄 Reloading existing Terrain3D data...")
		terrain3d.reload()
	
	# Wait for terrain to be ready
	await get_tree().process_frame
	
	GameLogger.info("✅ Terrain3D system initialized with existing demo data")

func place_forest_assets():
	"""Place forest assets in the scene"""
	GameLogger.info("🌲 Placing forest assets...")
	
	# Use TerrainController to place forest assets
	if terrain_controller and terrain_controller.has_method("_on_generate_forest"):
		terrain_controller._on_generate_forest()
	
	GameLogger.info("✅ Forest assets placed")

func position_player_on_terrain():
	"""Position the player on the terrain surface"""
	GameLogger.info("👤 Positioning player on terrain...")
	
	if not player:
		return
	
	# Position player at safe height above ground
	player.global_position.y = 15.0  # Safe height above ground
	GameLogger.info("✅ Player positioned at safe height: 15.0")

func _input(event):
	"""Handle input for testing"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F:
				# Test forest generation
				GameLogger.info("🌲 Testing forest generation...")
				if terrain_controller and terrain_controller.has_method("_on_generate_forest"):
					terrain_controller._on_generate_forest()
			KEY_C:
				# Clear assets
				GameLogger.info("🧹 Clearing assets...")
				if terrain_controller and terrain_controller.has_method("_on_clear_assets"):
					terrain_controller._on_clear_assets()
			KEY_T:
				# Show terrain info
				show_terrain_info()
			KEY_R:
				# Regenerate terrain
				GameLogger.info("🔄 Regenerating terrain...")
				if terrain_controller and terrain_controller.has_method("_regenerate_terrain"):
					terrain_controller._regenerate_terrain()

func show_terrain_info():
	"""Show terrain system information"""
	GameLogger.info("📊 Terrain3D System Info:")
	GameLogger.info("   Terrain3D Node: %s" % ("Found" if terrain3d else "Not Found"))
	GameLogger.info("   Player Node: %s" % ("Found" if player else "Not Found"))
	GameLogger.info("   TerrainController: %s" % ("Found" if terrain_controller else "Not Found"))
	if terrain3d:
		GameLogger.info("   Data Directory: %s" % terrain3d.data_directory)
		GameLogger.info("   Material: %s" % ("Loaded" if terrain3d.material else "None"))
		GameLogger.info("   Assets: %s" % ("Loaded" if terrain3d.assets else "None"))
