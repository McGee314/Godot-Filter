extends Node3D

# Test script for terrain integration validation
# This tests Phase 1 completion: PSX assets, Terrain3D setup, and basic integration

@onready var terrain_manager: TerrainManager = $TerrainManager
@onready var terrain_3d: Terrain3D = $Terrain3D

func _ready():
	GameLogger.info("TestTerrain: Starting terrain integration test")
	
	# Test 1: Validate PSX asset pack loading
	test_psx_asset_pack()
	
	# Test 2: Validate Terrain3D node
	test_terrain3d_node()
	
	# Test 3: Validate terrain manager integration
	test_terrain_manager()
	
	GameLogger.info("TestTerrain: Terrain integration test completed")

func _input(event):
	"""Handle input for testing"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				get_tree().quit()

func test_psx_asset_pack():
	"""Test PSX asset pack loading and validation"""
	GameLogger.info("TestTerrain: Testing PSX asset pack...")
	
	# Load Papua PSX asset pack
	var psx_pack = load("res://Assets/Terrain/Papua/psx_assets.tres")
	if not psx_pack:
		GameLogger.error("TestTerrain: Failed to load Papua PSX asset pack")
		return
	
	# Validate asset pack
	var validation = psx_pack.validate_assets()
	if validation.valid:
		GameLogger.info("TestTerrain: PSX asset validation passed: " + str(validation.valid_assets) + "/" + str(validation.total_assets) + " assets")
	else:
		GameLogger.error("TestTerrain: PSX asset validation failed: " + str(validation.missing))
	
	# Test asset categories
	var categories = ["trees", "vegetation", "stones", "debris", "mushrooms"]
	for category in categories:
		var assets = psx_pack.get_assets_by_category(category)
		GameLogger.info("TestTerrain: Category '" + category + "': " + str(assets.size()) + " assets")
		
		# Test random asset selection
		var random_asset = psx_pack.get_random_asset(category)
		if random_asset != "":
			GameLogger.info("TestTerrain: Random " + category + " asset: " + random_asset.get_file())

func test_terrain3d_node():
	"""Test Terrain3D node setup"""
	GameLogger.info("TestTerrain: Testing Terrain3D node...")
	
	if not terrain_3d:
		GameLogger.error("TestTerrain: Terrain3D node not found")
		return
	
	GameLogger.info("TestTerrain: Terrain3D node found and ready")
	
	# Test basic Terrain3D properties
	GameLogger.info("TestTerrain: Terrain3D transform: " + str(terrain_3d.transform))

func test_terrain_manager():
	"""Test terrain manager integration"""
	GameLogger.info("TestTerrain: Testing terrain manager...")
	
	if not terrain_manager:
		GameLogger.error("TestTerrain: TerrainManager not found")
		return
	
	# Load and set PSX asset pack
	var psx_pack = load("res://Assets/Terrain/Papua/psx_assets.tres")
	if psx_pack:
		terrain_manager.set_psx_asset_pack(psx_pack)
		
			# Test terrain build validation (without heightmap for now)
	# Note: build_terrain() requires heightmap, so we'll test other functionality
	GameLogger.info("TestTerrain: Skipping terrain build (no heightmap configured)")
	
	# Test terrain configuration
	terrain_manager.configure_heightmap("res://Assets/Terrain/Papua/heightmaps/papua_test_heightmap.png")
	GameLogger.info("TestTerrain: Heightmap configured (test heightmap)")
	
	# Now test build validation
	var build_success = terrain_manager.build_terrain()
	if build_success:
		GameLogger.info("TestTerrain: Terrain build validation passed")
	else:
		GameLogger.warning("TestTerrain: Terrain build validation failed (expected without actual heightmap)")
		
		# Get terrain status
		var status = terrain_manager.get_status()
		GameLogger.info("TestTerrain: Terrain status: " + str(status))
		
		# Test PSX asset access through manager
		var trees = terrain_manager.get_psx_assets_by_category("trees")
		GameLogger.info("TestTerrain: Trees available through manager: " + str(trees.size()))
		
		var random_tree = terrain_manager.get_random_psx_asset("trees")
		if random_tree != "":
			GameLogger.info("TestTerrain: Random tree from manager: " + random_tree.get_file())

func _input(event):
	# Allow testing with keyboard input
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				GameLogger.info("TestTerrain: Manual test trigger: PSX asset validation")
				test_psx_asset_pack()
			KEY_2:
				GameLogger.info("TestTerrain: Manual test trigger: Terrain3D validation")
				test_terrain3d_node()
			KEY_3:
				GameLogger.info("TestTerrain: Manual test trigger: Terrain manager validation")
				test_terrain_manager()
			KEY_ESCAPE:
				get_tree().quit()
