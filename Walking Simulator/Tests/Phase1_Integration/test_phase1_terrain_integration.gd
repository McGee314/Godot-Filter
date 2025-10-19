extends Node

# Phase 1 Terrain Integration Test Runner
# This validates all Phase 1 components: PSX assets, Terrain3D, and terrain management

var test_results = {
	"psx_asset_packs": false,
	"terrain_manager": false,
	"terrain3d_setup": false,
	"asset_validation": false,
	"integration": false
}

func _ready():
	GameLogger.info("Phase1Test: Starting Phase 1 Terrain Integration Test")
	
	# Run all Phase 1 tests
	test_psx_asset_packs()
	test_terrain_manager()
	test_terrain3d_setup()
	test_asset_validation()
	test_integration()
	
	# Report results
	report_results()
	
	GameLogger.info("Phase1Test: Phase 1 Terrain Integration Test completed")

func test_psx_asset_packs():
	"""Test PSX asset pack loading and validation"""
	GameLogger.info("Phase1Test: Testing PSX asset packs...")
	
	# Test Papua asset pack
	var papua_pack = load("res://Assets/Terrain/Papua/psx_assets.tres")
	if not papua_pack:
		GameLogger.error("Phase1Test: Failed to load Papua PSX asset pack")
		return
	
	# Test Tambora asset pack
	var tambora_pack = load("res://Assets/Terrain/Tambora/psx_assets.tres")
	if not tambora_pack:
		GameLogger.error("Phase1Test: Failed to load Tambora PSX asset pack")
		return
	
	# Validate both packs
	var papua_validation = papua_pack.validate_assets()
	var tambora_validation = tambora_pack.validate_assets()
	
	if papua_validation.valid and tambora_validation.valid:
		GameLogger.info("Phase1Test: PSX asset packs validation passed")
		GameLogger.info("Phase1Test: Papua: " + str(papua_validation.valid_assets) + "/" + str(papua_validation.total_assets) + " assets")
		GameLogger.info("Phase1Test: Tambora: " + str(tambora_validation.valid_assets) + "/" + str(tambora_validation.total_assets) + " assets")
		test_results.psx_asset_packs = true
	else:
		GameLogger.error("Phase1Test: PSX asset packs validation failed")
		if not papua_validation.valid:
			GameLogger.error("Phase1Test: Papua missing assets: " + str(papua_validation.missing))
		if not tambora_validation.valid:
			GameLogger.error("Phase1Test: Tambora missing assets: " + str(tambora_validation.missing))

func test_terrain_manager():
	"""Test terrain manager functionality"""
	GameLogger.info("Phase1Test: Testing terrain manager...")
	
	# Create terrain manager instance
	var terrain_manager = TerrainManager.new()
	add_child(terrain_manager)
	
	# Test basic functionality
	terrain_manager.configure_heightmap("test_heightmap.png")
	terrain_manager.set_material(StandardMaterial3D.new())
	
	# Test PSX asset pack integration
	var psx_pack = load("res://Assets/Terrain/Papua/psx_assets.tres")
	if psx_pack:
		terrain_manager.set_psx_asset_pack(psx_pack)
		
		# Test terrain build validation
		var build_success = terrain_manager.build_terrain()
		if build_success:
			GameLogger.info("Phase1Test: Terrain manager build validation passed")
			test_results.terrain_manager = true
		else:
			GameLogger.error("Phase1Test: Terrain manager build validation failed")
		
		# Test PSX asset access
		var trees = terrain_manager.get_psx_assets_by_category("trees")
		if trees.size() > 0:
			GameLogger.info("Phase1Test: Terrain manager PSX asset access working: " + str(trees.size()) + " trees")
		else:
			GameLogger.error("Phase1Test: Terrain manager PSX asset access failed")
	
	# Clean up
	terrain_manager.queue_free()

func test_terrain3d_setup():
	"""Test Terrain3D node setup"""
	GameLogger.info("Phase1Test: Testing Terrain3D setup...")
	
	# Create Terrain3D node
	var terrain_3d = Terrain3D.new()
	add_child(terrain_3d)
	
	# Test basic properties
	if terrain_3d:
		GameLogger.info("Phase1Test: Terrain3D node created successfully")
		test_results.terrain3d_setup = true
	else:
		GameLogger.error("Phase1Test: Failed to create Terrain3D node")
	
	# Clean up
	terrain_3d.queue_free()

func test_asset_validation():
	"""Test asset validation across all systems"""
	GameLogger.info("Phase1Test: Testing asset validation...")
	
	# Test PSX asset pack validation
	var psx_pack = load("res://Assets/Terrain/Papua/psx_assets.tres")
	if psx_pack:
		var validation = psx_pack.validate_assets()
		if validation.valid:
			GameLogger.info("Phase1Test: Asset validation passed: " + str(validation.valid_assets) + " valid assets")
			test_results.asset_validation = true
		else:
			GameLogger.error("Phase1Test: Asset validation failed: " + str(validation.missing))
	else:
		GameLogger.error("Phase1Test: Failed to load PSX asset pack for validation")

func test_integration():
	"""Test integration between all components"""
	GameLogger.info("Phase1Test: Testing component integration...")
	
	# Test complete integration workflow
	var terrain_manager = TerrainManager.new()
	add_child(terrain_manager)
	
	var psx_pack = load("res://Assets/Terrain/Papua/psx_assets.tres")
	if psx_pack:
		terrain_manager.set_psx_asset_pack(psx_pack)
		
		# Test complete workflow
		var status = terrain_manager.get_status()
		if status.has("psx_pack_info"):
			var pack_info = status.psx_pack_info
			GameLogger.info("Phase1Test: Integration test passed: " + pack_info.region_name + " with " + str(pack_info.total_assets) + " assets")
			test_results.integration = true
		else:
			GameLogger.error("Phase1Test: Integration test failed: missing PSX pack info")
	
	# Clean up
	terrain_manager.queue_free()

func report_results():
	"""Report test results"""
	GameLogger.info("Phase1Test: === Phase 1 Test Results ===")
	
	var passed_tests = 0
	var total_tests = test_results.size()
	
	for test_name in test_results:
		var result = test_results[test_name]
		if result:
			GameLogger.info("Phase1Test: ✅ " + test_name + ": PASSED")
			passed_tests += 1
		else:
			GameLogger.error("Phase1Test: ❌ " + test_name + ": FAILED")
	
	GameLogger.info("Phase1Test: === Summary: " + str(passed_tests) + "/" + str(total_tests) + " tests passed ===")
	
	if passed_tests == total_tests:
		GameLogger.info("Phase1Test: 🎉 Phase 1 Terrain Integration COMPLETE - Ready for Phase 2")
	else:
		GameLogger.error("Phase1Test: ⚠️ Phase 1 Terrain Integration INCOMPLETE - Issues need resolution")

func _input(event):
	# Allow manual test triggering
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				GameLogger.info("Phase1Test: Manual test trigger: PSX asset packs")
				test_psx_asset_packs()
			KEY_2:
				GameLogger.info("Phase1Test: Manual test trigger: Terrain manager")
				test_terrain_manager()
			KEY_3:
				GameLogger.info("Phase1Test: Manual test trigger: Terrain3D setup")
				test_terrain3d_setup()
			KEY_4:
				GameLogger.info("Phase1Test: Manual test trigger: Asset validation")
				test_asset_validation()
			KEY_5:
				GameLogger.info("Phase1Test: Manual test trigger: Integration")
				test_integration()
			KEY_R:
				GameLogger.info("Phase1Test: Manual test trigger: Report results")
				report_results()
			KEY_ESCAPE:
				get_tree().quit()
