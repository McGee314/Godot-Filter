extends Node

# Simple test to check Terrain3D addon accessibility
# This tests if the addon files are present and accessible

func _ready():
	print("=== Terrain3D Addon Simple Test ===")
	
	# Test 1: Check addon files exist
	test_addon_files()
	
	# Test 2: Check if addon is enabled in project
	test_addon_enabled()
	
	# Test 3: Try to access Terrain3D class
	test_terrain3d_class_access()
	
	print("=== Terrain3D Addon Simple Test Completed ===")

func test_addon_files():
	"""Test if Terrain3D addon files exist"""
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

func test_terrain3d_class_access():
	"""Test if Terrain3D class can be accessed"""
	print("Testing Terrain3D class access...")
	
	# Try to check if Terrain3D class exists
	var class_exists = ClassDB.class_exists("Terrain3D")
	if class_exists:
		print("✅ Terrain3D class exists in ClassDB")
	else:
		print("❌ Terrain3D class not found in ClassDB")
	
	# Try to create Terrain3D node (this might fail if addon not loaded)
	var terrain_3d = ClassDB.instantiate("Terrain3D")
	if terrain_3d:
		print("✅ Terrain3D can be instantiated")
		terrain_3d.free()
	else:
		print("❌ Terrain3D instantiation failed")

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
				print("Manual test trigger: Class access")
				test_terrain3d_class_access()
			KEY_ESCAPE:
				get_tree().quit()
