extends Node

# Test script to verify graph generation works in the scene
# Add this as a child node to PapuaScene_Terrain3D for testing

func _ready():
	print("=== Scene Graph Generation Test ===")
	# Wait a bit for scene to initialize
	await get_tree().process_frame
	await get_tree().create_timer(2.0).timeout
	test_find_terrain_controller()

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_0:
				# Manual test trigger
				print("🔧 Manual test trigger - Attempting graph generation...")
				test_manual_graph_generation()

func test_find_terrain_controller():
	print("🔍 Looking for Terrain3DController in scene...")
	
	# Search for terrain controller
	var terrain_controller = find_terrain_controller_recursive(get_tree().current_scene)
	if terrain_controller:
		print("✅ Found Terrain3DController: %s" % terrain_controller.get_path())
		print("  - Node name: %s" % terrain_controller.name)
		print("  - Script: %s" % (terrain_controller.get_script().resource_path if terrain_controller.get_script() else "None"))
		print("  - Input processing: %s" % terrain_controller.is_processing_input())
	else:
		print("❌ Terrain3DController not found in scene!")
		print("🔍 Available nodes:")
		print_scene_structure(get_tree().current_scene, 0)

func find_terrain_controller_recursive(node: Node) -> Node:
	if node.name.contains("Terrain3DController") or node.name.contains("TerrainController"):
		return node
	
	for child in node.get_children():
		var result = find_terrain_controller_recursive(child)
		if result:
			return result
	
	return null

func print_scene_structure(node: Node, indent: int):
	var indent_str = "  ".repeat(indent)
	print("%s- %s (%s)" % [indent_str, node.name, node.get_class()])
	
	if indent < 3:  # Limit depth
		for child in node.get_children():
			print_scene_structure(child, indent + 1)

func test_manual_graph_generation():
	print("🎯 Manual graph generation test...")
	var terrain_controller = find_terrain_controller_recursive(get_tree().current_scene)
	if terrain_controller and terrain_controller.has_method("_generate_modern_wheel_graph"):
		print("✅ Calling _generate_modern_wheel_graph(5)...")
		terrain_controller._generate_modern_wheel_graph(5)
	else:
		print("❌ Cannot call graph generation method")
