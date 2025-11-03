extends Node

# Simple validation test for Terrain3D functionality

func _ready():
	print("=== Terrain3D Validation Test ===")
	test_basic_setup()
	test_asset_packs()
	test_terrain_manager()
	test_heightmap_creation()
	print("=== Terrain3D Validation Complete ===")

func test_basic_setup():
	print("\n🔧 Testing basic setup...")
	
	# Test if we can access the TerrainManager class
	var terrain_manager_class = preload("res://Systems/Terrain/TerrainManager.gd")
	if terrain_manager_class:
		print("  ✅ TerrainManager class accessible")
	else:
		print("  ❌ TerrainManager class not found")
		return
	
	# Test if we can create a TerrainManager instance
	var terrain_manager = terrain_manager_class.new()
	if terrain_manager:
		print("  ✅ TerrainManager instance created successfully")
		terrain_manager.queue_free()
	else:
		print("  ❌ Failed to create TerrainManager instance")

func test_asset_packs():
	print("\n📦 Testing asset packs...")
	
	# Test Papua asset pack
	var papua_pack = load("res://Assets/Terrain/Papua/psx_assets.tres")
	if papua_pack:
		print("  ✅ Papua asset pack loaded successfully")
		var papua_info = papua_pack.get_pack_info()
		print("    📊 Papua: " + str(papua_info.total_assets) + " total assets")
		
		# Test validation
		var validation = papua_pack.validate_assets()
		if validation.valid:
			print("    ✅ Papua assets validated: " + str(validation.valid_assets) + "/" + str(validation.total_assets))
		else:
			print("    ⚠️ Papua assets validation failed: " + str(validation.missing.size()) + " missing")
	else:
		print("  ❌ Failed to load Papua asset pack")
	
	# Test Tambora asset pack
	var tambora_pack = load("res://Assets/Terrain/Tambora/psx_assets.tres")
	if tambora_pack:
		print("  ✅ Tambora asset pack loaded successfully")
		var tambora_info = tambora_pack.get_pack_info()
		print("    📊 Tambora: " + str(tambora_info.total_assets) + " total assets")
		
		# Test validation
		var validation = tambora_pack.validate_assets()
		if validation.valid:
			print("    ✅ Tambora assets validated: " + str(validation.valid_assets) + "/" + str(validation.total_assets))
		else:
			print("    ⚠️ Tambora assets validation failed: " + str(validation.missing.size()) + " missing")
	else:
		print("  ❌ Failed to load Tambora asset pack")

func test_terrain_manager():
	print("\n🏔️ Testing TerrainManager functionality...")
	
	# Create a TerrainManager instance
	var terrain_manager = preload("res://Systems/Terrain/TerrainManager.gd").new()
	if not terrain_manager:
		print("  ❌ Failed to create TerrainManager")
		return
	
	# Test with Papua pack
	var papua_pack = load("res://Assets/Terrain/Papua/psx_assets.tres")
	if papua_pack:
		terrain_manager.set_psx_asset_pack(papua_pack)
		print("  ✅ Set Papua asset pack in TerrainManager")
		
		# Test asset retrieval
		var trees = terrain_manager.get_psx_assets_by_category("trees")
		var vegetation = terrain_manager.get_psx_assets_by_category("vegetation")
		var stones = terrain_manager.get_psx_assets_by_category("stones")
		
		print("    📊 Trees: " + str(trees.size()) + " assets")
		print("    📊 Vegetation: " + str(vegetation.size()) + " assets")
		print("    📊 Stones: " + str(stones.size()) + " assets")
		
		# Test random asset selection
		var random_tree = terrain_manager.get_random_psx_asset("trees")
		if random_tree != "":
			print("    ✅ Random tree: " + random_tree.get_file())
		else:
			print("    ⚠️ No random tree available")
	else:
		print("  ❌ Could not load Papua pack for TerrainManager test")
	
	# Clean up
	terrain_manager.queue_free()
	print("  ✅ TerrainManager test completed")

func test_heightmap_creation():
	print("\n🗺️ Testing heightmap creation...")
	
	# Check if test heightmaps exist
	var papua_heightmap = "res://Assets/Terrain/Papua/heightmaps/papua_test_heightmap.png"
	var tambora_heightmap = "res://Assets/Terrain/Tambora/heightmaps/tambora_test_heightmap.png"
	
	if FileAccess.file_exists(papua_heightmap):
		print("  ✅ Papua test heightmap exists")
	else:
		print("  ⚠️ Papua test heightmap not found - run test_heightmap_creation.tscn to create it")
	
	if FileAccess.file_exists(tambora_heightmap):
		print("  ✅ Tambora test heightmap exists")
	else:
		print("  ⚠️ Tambora test heightmap not found - run test_heightmap_creation.tscn to create it")
	
	# Test TerrainManager with heightmap
	var terrain_manager = preload("res://Systems/Terrain/TerrainManager.gd").new()
	if terrain_manager:
		# Configure heightmap
		terrain_manager.configure_heightmap(papua_heightmap)
		print("  ✅ Heightmap configured in TerrainManager")
		
		# Test build validation
		var build_success = terrain_manager.build_terrain()
		if build_success:
			print("  ✅ Terrain build validation passed with heightmap")
		else:
			print("  ⚠️ Terrain build validation failed (may need PSX asset pack)")
		
		terrain_manager.queue_free()
	else:
		print("  ❌ Failed to create TerrainManager for heightmap test")

func _input(event):
	"""Handle input for testing"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				get_tree().quit()
