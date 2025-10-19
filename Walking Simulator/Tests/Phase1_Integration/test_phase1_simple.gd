extends Node

# Simple Phase 1 Test - Validates basic functionality without external dependencies
# This tests the core Phase 1 components: PSX assets, resource files, and basic validation

func _ready():
	print("=== Phase 1 Terrain Integration Test ===")
	
	# Test 1: PSX Asset Pack Loading
	test_psx_asset_packs()
	
	# Test 2: Resource File Validation
	test_resource_files()
	
	# Test 3: Asset Path Validation
	test_asset_paths()
	
	print("=== Phase 1 Test Completed ===")

func test_psx_asset_packs():
	"""Test PSX asset pack loading and validation"""
	print("Testing PSX asset packs...")
	
	# Test Papua asset pack
	var papua_pack = load("res://Assets/Terrain/Papua/psx_assets.tres")
	if papua_pack:
		print("✅ Papua PSX asset pack loaded successfully")
		
		# Test basic properties
		if papua_pack.has_method("validate_assets"):
			var validation = papua_pack.validate_assets()
			if validation.valid:
				print("✅ Papua asset validation passed: " + str(validation.valid_assets) + "/" + str(validation.total_assets) + " assets")
			else:
				print("❌ Papua asset validation failed: " + str(validation.missing))
		else:
			print("⚠️ Papua pack missing validate_assets method")
	else:
		print("❌ Failed to load Papua PSX asset pack")
	
	# Test Tambora asset pack
	var tambora_pack = load("res://Assets/Terrain/Tambora/psx_assets.tres")
	if tambora_pack:
		print("✅ Tambora PSX asset pack loaded successfully")
		
		# Test basic properties
		if tambora_pack.has_method("validate_assets"):
			var validation = tambora_pack.validate_assets()
			if validation.valid:
				print("✅ Tambora asset validation passed: " + str(validation.valid_assets) + "/" + str(validation.total_assets) + " assets")
			else:
				print("❌ Tambora asset validation failed: " + str(validation.missing))
		else:
			print("⚠️ Tambora pack missing validate_assets method")
	else:
		print("❌ Failed to load Tambora PSX asset pack")

func test_resource_files():
	"""Test resource file existence"""
	print("Testing resource files...")
	
	# Test directory structure
	var directories = [
		"res://Assets/Terrain/",
		"res://Assets/Terrain/Papua/",
		"res://Assets/Terrain/Tambora/",
		"res://Assets/Terrain/Shared/",
		"res://Systems/Terrain/"
	]
	
	for dir_path in directories:
		var dir = DirAccess.open(dir_path)
		if dir:
			print("✅ Directory exists: " + dir_path)
		else:
			print("❌ Directory missing: " + dir_path)
	
	# Test resource files
	var resource_files = [
		"res://Assets/Terrain/Papua/psx_assets.tres",
		"res://Assets/Terrain/Tambora/psx_assets.tres",
		"res://Systems/Terrain/PSXAssetPack.gd",
		"res://Systems/Terrain/TerrainManager.gd"
	]
	
	for file_path in resource_files:
		if ResourceLoader.exists(file_path):
			print("✅ Resource file exists: " + file_path)
		else:
			print("❌ Resource file missing: " + file_path)

func test_asset_paths():
	"""Test PSX asset paths"""
	print("Testing PSX asset paths...")
	
	# Test some key PSX assets from the new Shared folder structure
	var test_assets = [
		"res://Assets/Terrain/Shared/psx_models/trees/pine/pine_tree_n_1.glb",
		"res://Assets/Terrain/Shared/psx_models/stones/stone_1.glb",
		"res://Assets/Terrain/Shared/psx_models/vegetation/grass/grass_1.glb",
		"res://Assets/Terrain/Shared/psx_models/mushrooms/mushroom_n_1.glb"
	]
	
	var valid_count = 0
	for asset_path in test_assets:
		if ResourceLoader.exists(asset_path):
			print("✅ Asset exists: " + asset_path.get_file())
			valid_count += 1
		else:
			print("❌ Asset missing: " + asset_path)
	
	print("Asset validation: " + str(valid_count) + "/" + str(test_assets.size()) + " assets found")
	
	# Also test the Shared folder structure
	print("Testing Shared folder structure...")
	var shared_dirs = [
		"res://Assets/Terrain/Shared/psx_models/trees/",
		"res://Assets/Terrain/Shared/psx_models/vegetation/",
		"res://Assets/Terrain/Shared/psx_models/stones/",
		"res://Assets/Terrain/Shared/psx_models/mushrooms/",
		"res://Assets/Terrain/Shared/psx_models/debris/"
	]
	
	var dir_count = 0
	for dir_path in shared_dirs:
		var dir = DirAccess.open(dir_path)
		if dir:
			print("✅ Shared directory exists: " + dir_path)
			dir_count += 1
		else:
			print("❌ Shared directory missing: " + dir_path)
	
	print("Shared directory validation: " + str(dir_count) + "/" + str(shared_dirs.size()) + " directories found")

func _input(event):
	# Allow manual test triggering
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				print("Manual test trigger: PSX asset packs")
				test_psx_asset_packs()
			KEY_2:
				print("Manual test trigger: Resource files")
				test_resource_files()
			KEY_3:
				print("Manual test trigger: Asset paths")
				test_asset_paths()
			KEY_ESCAPE:
				print("Exiting test scene...")
				get_tree().quit()
