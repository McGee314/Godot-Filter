extends Node3D

# Test script for Terrain3D addon in Godot Editor
# This tests Terrain3D functionality directly in the editor environment

@onready var terrain: Terrain3D = $Terrain3D

func _ready():
	print("=== Terrain3D Editor Test ===")
	
	# Test 1: Check if Terrain3D node exists
	test_terrain3d_node()
	
	# Test 2: Test Terrain3D properties
	test_terrain3d_properties()
	
	# Test 3: Test Terrain3D methods
	test_terrain3d_methods()
	
	# Test 4: Test PSX Asset Pack integration
	test_psx_integration()
	
	print("=== Terrain3D Editor Test Completed ===")
	print("Press ESC to exit test mode")

func test_terrain3d_node():
	"""Test if Terrain3D node exists and is properly configured"""
	print("Testing Terrain3D node...")
	
	if terrain:
		print("✅ Terrain3D node found in scene")
		print("✅ Terrain3D name: " + terrain.name)
		print("✅ Terrain3D position: " + str(terrain.position))
		print("✅ Terrain3D transform: " + str(terrain.transform))
	else:
		print("❌ Terrain3D node not found in scene")

func test_terrain3d_properties():
	"""Test Terrain3D properties"""
	print("Testing Terrain3D properties...")
	
	if terrain:
		# Test basic properties
		print("✅ Terrain3D material: " + str(terrain.material))
		print("✅ Terrain3D collision mask: " + str(terrain.collision_mask))
		print("✅ Terrain3D top level: " + str(terrain.top_level))
		
		# Test if we can modify properties
		terrain.position = Vector3(0, 0, 0)
		print("✅ Terrain3D position modified successfully")
		
		# Test material assignment
		if terrain.material:
			print("✅ Terrain3D has material assigned")
		else:
			print("⚠️ Terrain3D has no material assigned")

func test_terrain3d_methods():
	"""Test Terrain3D methods"""
	print("Testing Terrain3D methods...")
	
	if terrain:
		# Get method list
		var methods = terrain.get_method_list()
		print("✅ Terrain3D has " + str(methods.size()) + " methods")
		
		# Look for terrain-specific methods
		var terrain_methods = []
		for method in methods:
			if "terrain" in method.name.to_lower():
				terrain_methods.append(method.name)
		
		if terrain_methods.size() > 0:
			print("✅ Found terrain-specific methods:")
			for method in terrain_methods:
				print("   - " + method)
		else:
			print("⚠️ No terrain-specific methods found")

func test_psx_integration():
	"""Test PSX Asset Pack integration with Terrain3D"""
	print("Testing PSX Asset Pack integration...")
	
	# Test PSX Asset Pack loading
	var papua_pack = load("res://Assets/Terrain/Papua/psx_assets.tres")
	if papua_pack:
		print("✅ Papua PSX asset pack loaded successfully")
		
		# Test asset validation
		var validation = papua_pack.validate_assets()
		if validation.valid:
			print("✅ Papua assets validated: " + str(validation.valid_assets) + "/" + str(validation.total_assets))
		else:
			print("❌ Papua assets validation failed: " + str(validation.missing))
	else:
		print("❌ Failed to load Papua PSX asset pack")
	
	# Test Tambora PSX Asset Pack
	var tambora_pack = load("res://Assets/Terrain/Tambora/psx_assets.tres")
	if tambora_pack:
		print("✅ Tambora PSX asset pack loaded successfully")
		
		# Test asset validation
		var validation = tambora_pack.validate_assets()
		if validation.valid:
			print("✅ Tambora assets validated: " + str(validation.valid_assets) + "/" + str(validation.total_assets))
		else:
			print("❌ Tambora assets validation failed: " + str(validation.missing))
	else:
		print("❌ Failed to load Tambora PSX asset pack")

func _input(event):
	# Allow manual test triggering
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				print("Manual test trigger: Terrain3D node")
				test_terrain3d_node()
			KEY_2:
				print("Manual test trigger: Terrain3D properties")
				test_terrain3d_properties()
			KEY_3:
				print("Manual test trigger: Terrain3D methods")
				test_terrain3d_methods()
			KEY_4:
				print("Manual test trigger: PSX integration")
				test_psx_integration()
			KEY_ESCAPE:
				print("Exiting test mode...")
				get_tree().quit()
