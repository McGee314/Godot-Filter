extends Node

# Test script to verify Terrain3D addon after reinstallation
# This will test if the addon is properly installed and functional

func _ready():
	print("=== Terrain3D Addon Reinstallation Test ===")
	
	# Test 1: Check if addon files exist
	test_addon_files()
	
	# Test 2: Check if addon is enabled
	test_addon_enabled()
	
	# Test 3: Test Terrain3D class availability
	test_terrain3d_class()
	
	# Test 4: Test Terrain3D node creation
	test_terrain3d_creation()
	
	print("=== Terrain3D Addon Reinstallation Test Completed ===")

func test_addon_files():
	"""Test if Terrain3D addon files exist after reinstallation"""
	print("Testing Terrain3D addon files...")
	
	var addon_files = [
		"res://addons/terrain_3d/plugin.cfg",
		"res://addons/terrain_3d/terrain.gdextension",
		"res://addons/terrain_3d/README.md"
	]
	
	var dll_files = [
		"res://addons/terrain_3d/bin/libterrain.windows.debug.x86_64.dll",
		"res://addons/terrain_3d/bin/libterrain.windows.release.x86_64.dll"
	]
	
	# Test addon files
	for file_path in addon_files:
		if FileAccess.file_exists(file_path):
			print("✅ Addon file exists: " + file_path)
		else:
			print("❌ Addon file missing: " + file_path)
	
	# Test DLL files (use FileAccess for binary files)
	for file_path in dll_files:
		if FileAccess.file_exists(file_path):
			print("✅ DLL file exists: " + file_path)
		else:
			print("❌ DLL file missing: " + file_path)

func test_addon_enabled():
	"""Test if Terrain3D addon is enabled in project settings"""
	print("Testing Terrain3D addon enabled status...")
	
	# Check if addon is enabled in project settings
	var enabled_plugins = ProjectSettings.get_setting("editor_plugins/enabled", PackedStringArray())
	
	var addon_enabled = false
	for plugin in enabled_plugins:
		if "terrain_3d" in plugin:
			addon_enabled = true
			print("✅ Terrain3D addon is enabled in project settings")
			break
	
	if not addon_enabled:
		print("❌ Terrain3D addon is not enabled in project settings")
		print("Current enabled plugins: " + str(enabled_plugins))

func test_terrain3d_class():
	"""Test if Terrain3D class is available"""
	print("Testing Terrain3D class availability...")
	
	# Try to check if Terrain3D class exists
	var class_exists = ClassDB.class_exists("Terrain3D")
	if class_exists:
		print("✅ Terrain3D class exists in ClassDB")
	else:
		print("❌ Terrain3D class not found in ClassDB")

func test_terrain3d_creation():
	"""Test if Terrain3D node can be created"""
	print("Testing Terrain3D node creation...")
	
	# Try to create Terrain3D node
	var terrain_3d = ClassDB.instantiate("Terrain3D")
	if terrain_3d:
		print("✅ Terrain3D node created successfully")
		
		# Test basic properties
		print("✅ Terrain3D position: " + str(terrain_3d.position))
		print("✅ Terrain3D name: " + terrain_3d.name)
		
		# Test if we can modify properties
		terrain_3d.position = Vector3(10, 0, 10)
		print("✅ Terrain3D position modified: " + str(terrain_3d.position))
		
		# Clean up
		terrain_3d.free()
	else:
		print("❌ Terrain3D node creation failed")

func _input(event):
	# Allow manual test triggering
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				print("Manual test trigger: Addon files")
				test_addon_files()
			KEY_2:
				print("Manual test trigger: Addon enabled")
				test_addon_enabled()
			KEY_3:
				print("Manual test trigger: Terrain3D class")
				test_terrain3d_class()
			KEY_4:
				print("Manual test trigger: Terrain3D creation")
				test_terrain3d_creation()
			KEY_ESCAPE:
				get_tree().quit()
