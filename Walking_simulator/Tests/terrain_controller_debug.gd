extends Node

# Debug script to test if Terrain3DController is working
# Add this to the scene to verify controller functionality

func _ready():
	print("🔍 === TERRAIN CONTROLLER DEBUG TEST ===")
	await get_tree().process_frame
	await get_tree().create_timer(1.0).timeout
	test_controller_existence()

func test_controller_existence():
	print("🔍 Searching for TerrainController in scene...")
	
	var scene_root = get_tree().current_scene
	print("📁 Scene root: %s" % scene_root.name)
	
	# Look for TerrainController
	var terrain_controller = scene_root.get_node_or_null("TerrainController")
	if terrain_controller:
		print("✅ Found TerrainController: %s" % terrain_controller.name)
		print("  - Script: %s" % (terrain_controller.get_script().resource_path if terrain_controller.get_script() else "None"))
		print("  - Input processing: %s" % terrain_controller.is_processing_input())
		print("  - Class: %s" % terrain_controller.get_class())
		
		# Test calling a method
		if terrain_controller.has_method("_show_terrain_info"):
			print("✅ TerrainController has _show_terrain_info method")
		else:
			print("❌ TerrainController missing _show_terrain_info method")
			
	else:
		print("❌ TerrainController not found!")
		print("📁 Available nodes:")
		for child in scene_root.get_children():
			print("  - %s (%s)" % [child.name, child.get_class()])

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_0:
		print("🔧 Manual controller test triggered")
		test_controller_existence()
