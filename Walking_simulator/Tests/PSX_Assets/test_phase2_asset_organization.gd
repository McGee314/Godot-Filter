extends Node

# Test script for Phase 2: PSX Asset Organization
# Validates that assets are properly organized and accessible

var test_results = {}

func _ready():
	print("=== Phase 2: PSX Asset Organization Test ===")
	run_tests()
	print_results()

func run_tests():
	# Test 1: Validate organized directory structure
	test_results["directory_structure"] = test_directory_structure()
	
	# Test 2: Validate PSX Asset Packs can load
	test_results["asset_pack_loading"] = test_asset_pack_loading()
	
	# Test 3: Validate asset references are correct
	test_results["asset_references"] = test_asset_references()
	
	# Test 4: Validate TerrainManager integration
	test_results["terrain_manager_integration"] = test_terrain_manager_integration()

func test_directory_structure() -> bool:
	print("Testing organized directory structure...")
	
	var required_dirs = [
		"Assets/Terrain/Shared/psx_models/trees/jungle",
		"Assets/Terrain/Shared/psx_models/trees/pine",
		"Assets/Terrain/Shared/psx_models/vegetation/grass",
		"Assets/Terrain/Shared/psx_models/vegetation/ferns",
		"Assets/Terrain/Shared/psx_models/stones/rocks",
		"Assets/Terrain/Shared/psx_models/debris/logs",
		"Assets/Terrain/Shared/psx_models/debris/stumps",
		"Assets/Terrain/Shared/psx_models/mushrooms/variants"
	]
	
	for dir_path in required_dirs:
		if not DirAccess.dir_exists_absolute(dir_path):
			print("  ❌ Missing directory: ", dir_path)
			return false
	
	print("  ✅ All required directories exist")
	return true

func test_asset_pack_loading() -> bool:
	print("Testing PSX Asset Pack loading...")
	
	var papua_pack_path = "res://Assets/Terrain/Papua/psx_assets.tres"
	var tambora_pack_path = "res://Assets/Terrain/Tambora/psx_assets.tres"
	
	# Test Papua pack
	var papua_pack = load(papua_pack_path)
	if not papua_pack:
		print("  ❌ Failed to load Papua asset pack")
		return false
	
	# Test Tambora pack
	var tambora_pack = load(tambora_pack_path)
	if not tambora_pack:
		print("  ❌ Failed to load Tambora asset pack")
		return false
	
	print("  ✅ Both asset packs loaded successfully")
	print("  📊 Papua pack info: ", papua_pack.get_pack_info())
	print("  📊 Tambora pack info: ", tambora_pack.get_pack_info())
	
	return true

func test_asset_references() -> bool:
	print("Testing asset references...")
	
	var papua_pack = load("res://Assets/Terrain/Papua/psx_assets.tres")
	if not papua_pack:
		print("  ❌ Failed to load Papua asset pack")
		return false
	
	var tambora_pack = load("res://Assets/Terrain/Tambora/psx_assets.tres")
	if not tambora_pack:
		print("  ❌ Failed to load Tambora asset pack")
		return false
	
	# Test Papua assets
	var papua_validation = papua_pack.validate_assets()
	if not papua_validation.valid:
		print("  ❌ Papua assets validation failed:")
		for missing in papua_validation.missing:
			print("    - Missing: ", missing)
		return false
	
	# Test Tambora assets
	var tambora_validation = tambora_pack.validate_assets()
	if not tambora_validation.valid:
		print("  ❌ Tambora assets validation failed:")
		for missing in tambora_validation.missing:
			print("    - Missing: ", missing)
		return false
	
	print("  ✅ All asset references are valid")
	print("  📊 Papua: ", papua_validation.valid_assets, "/", papua_validation.total_assets, " assets valid")
	print("  📊 Tambora: ", tambora_validation.valid_assets, "/", tambora_validation.total_assets, " assets valid")
	
	return true

func test_terrain_manager_integration() -> bool:
	print("Testing TerrainManager integration...")
	
	# Create a test TerrainManager
	var terrain_manager = preload("res://Systems/Terrain/TerrainManager.gd").new()
	
	# Test with Papua pack
	var papua_pack = load("res://Assets/Terrain/Papua/psx_assets.tres")
	if not papua_pack:
		print("  ❌ Failed to load Papua asset pack for TerrainManager test")
		return false
	
	terrain_manager.set_psx_asset_pack(papua_pack)
	
	# Test asset retrieval methods
	var trees = terrain_manager.get_psx_assets_by_category("trees")
	var vegetation = terrain_manager.get_psx_assets_by_category("vegetation")
	
	if trees.size() == 0:
		print("  ❌ No trees found in TerrainManager")
		return false
	
	if vegetation.size() == 0:
		print("  ❌ No vegetation found in TerrainManager")
		return false
	
	print("  ✅ TerrainManager integration working")
	print("  📊 Trees available: ", trees.size())
	print("  📊 Vegetation available: ", vegetation.size())
	
	return true

func print_results():
	print("\n=== Test Results ===")
	var all_passed = true
	
	for test_name in test_results:
		var status = "✅ PASS" if test_results[test_name] else "❌ FAIL"
		print(test_name, ": ", status)
		if not test_results[test_name]:
			all_passed = false
	
	print("\nOverall Result: ", "✅ ALL TESTS PASSED" if all_passed else "❌ SOME TESTS FAILED")
	
	if all_passed:
		print("\n🎉 Phase 2: PSX Asset Organization is working correctly!")
		print("📁 Assets are properly organized in Shared folder structure")
		print("📦 PSX Asset Packs are updated with new references")
		print("🔗 TerrainManager integration is functional")
	else:
		print("\n⚠️  Some issues need to be addressed before proceeding")
