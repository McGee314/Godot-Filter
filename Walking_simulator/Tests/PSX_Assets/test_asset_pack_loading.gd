extends Node

# Simple test to verify asset pack loading after fixing .tres files

func _ready():
	print("=== Testing Asset Pack Loading ===")
	test_papua_pack()
	test_tambora_pack()
	print("=== Asset Pack Loading Test Complete ===")

func test_papua_pack():
	print("\nTesting Papua Asset Pack...")
	
	var papua_pack = load("res://Assets/Terrain/Papua/psx_assets.tres")
	if not papua_pack:
		print("  ❌ Failed to load Papua asset pack")
		return
	
	print("  ✅ Successfully loaded Papua asset pack")
	print("  📊 Pack info: ", papua_pack.get_pack_info())
	
	# Test validation
	var validation = papua_pack.validate_assets()
	print("  📊 Validation: ", validation.valid_assets, "/", validation.total_assets, " assets valid")
	
	if not validation.valid:
		print("  ⚠️  Some assets are missing:")
		for missing in validation.missing:
			print("    - ", missing)

func test_tambora_pack():
	print("\nTesting Tambora Asset Pack...")
	
	var tambora_pack = load("res://Assets/Terrain/Tambora/psx_assets.tres")
	if not tambora_pack:
		print("  ❌ Failed to load Tambora asset pack")
		return
	
	print("  ✅ Successfully loaded Tambora asset pack")
	print("  📊 Pack info: ", tambora_pack.get_pack_info())
	
	# Test validation
	var validation = tambora_pack.validate_assets()
	print("  📊 Validation: ", validation.valid_assets, "/", validation.total_assets, " assets valid")
	
	if not validation.valid:
		print("  ⚠️  Some assets are missing:")
		for missing in validation.missing:
			print("    - ", missing)
