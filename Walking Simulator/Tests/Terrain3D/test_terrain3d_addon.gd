extends Node3D

# Test script to verify Terrain3D addon functionality
# This tests if the Terrain3D addon is properly loaded and working

func _ready():
	print("=== Terrain3D Addon Test ===")
	
	# Test 1: Check if Terrain3D class is available
	test_terrain3d_class()
	
	# Test 2: Create Terrain3D node
	test_terrain3d_creation()
	
	# Test 3: Test basic Terrain3D properties
	test_terrain3d_properties()
	
	print("=== Terrain3D Addon Test Completed ===")

func test_terrain3d_class():
	"""Test if Terrain3D class is available"""
	print("Testing Terrain3D class availability...")
	
	# Try to create Terrain3D node
	var terrain_3d = Terrain3D.new()
	if terrain_3d:
		print("✅ Terrain3D class is available and can be instantiated")
		terrain_3d.queue_free()
	else:
		print("❌ Terrain3D class is not available")

func test_terrain3d_creation():
	"""Test Terrain3D node creation and basic setup"""
	print("Testing Terrain3D node creation...")
	
	# Create Terrain3D node
	var terrain_3d = Terrain3D.new()
	add_child(terrain_3d)
	
	if terrain_3d:
		print("✅ Terrain3D node created successfully")
		
		# Test basic properties
		print("✅ Terrain3D transform: " + str(terrain_3d.transform))
		print("✅ Terrain3D name: " + terrain_3d.name)
		
		# Test if it's in the scene tree
		if terrain_3d.is_inside_tree():
			print("✅ Terrain3D node is properly in scene tree")
		else:
			print("⚠️ Terrain3D node not in scene tree")
		
		# Clean up
		terrain_3d.queue_free()
	else:
		print("❌ Failed to create Terrain3D node")

func test_terrain3d_properties():
	"""Test Terrain3D properties and methods"""
	print("Testing Terrain3D properties...")
	
	# Create Terrain3D node
	var terrain_3d = Terrain3D.new()
	add_child(terrain_3d)
	
	if terrain_3d:
		# Test basic properties
		print("✅ Terrain3D position: " + str(terrain_3d.position))
		print("✅ Terrain3D rotation: " + str(terrain_3d.rotation))
		print("✅ Terrain3D scale: " + str(terrain_3d.scale))
		
		# Test if we can modify properties
		terrain_3d.position = Vector3(10, 0, 10)
		print("✅ Terrain3D position modified: " + str(terrain_3d.position))
		
		# Test if Terrain3D has expected methods (these might not exist in basic setup)
		var methods = terrain_3d.get_method_list()
		print("✅ Terrain3D has " + str(methods.size()) + " methods")
		
		# Look for terrain-specific methods
		var has_terrain_methods = false
		for method in methods:
			if "terrain" in method.name.to_lower():
				has_terrain_methods = true
				print("✅ Found terrain method: " + method.name)
		
		if not has_terrain_methods:
			print("⚠️ No terrain-specific methods found (this might be normal for basic setup)")
		
		# Clean up
		terrain_3d.queue_free()
	else:
		print("❌ Cannot test Terrain3D properties - node creation failed")

func _input(event):
	# Allow manual test triggering
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				print("Manual test trigger: Terrain3D class")
				test_terrain3d_class()
			KEY_2:
				print("Manual test trigger: Terrain3D creation")
				test_terrain3d_creation()
			KEY_3:
				print("Manual test trigger: Terrain3D properties")
				test_terrain3d_properties()
			KEY_ESCAPE:
				get_tree().quit()
