extends SceneTree

## Headless unit test for W5 generation in Papua Terrain3D scene
## Tests KEY_5 functionality and hexagon generation
## Runs completely headless with comprehensive GameLogger output

func _initialize():
	"""Initialize the headless test"""
	GameLogger.info("🧪 [W5 Headless Test] Initializing W5 generation test...")
	
	# Enable focused debugging for this test
	var debug_config = get_node_or_null("/root/DebugConfig")
	if debug_config:
		debug_config.enable_graph_system_focus()
		GameLogger.info("✅ [W5 Headless Test] Debug focus enabled for GraphSystem")
	
	# Load and test Papua scene
	test_w5_generation()

func test_w5_generation():
	"""Test W5 generation functionality"""
	GameLogger.info("🔬 [W5 Headless Test] Starting W5 generation test...")
	
	# Load Papua scene
	var scene_path = "res://Scenes/IndonesiaTimur/PapuaScene_Terrain3D.tscn"
	var scene_resource = load(scene_path)
	if not scene_resource:
		GameLogger.graph_error("❌ [W5 Headless Test] Failed to load Papua scene")
		quit(1)
		return
	
	var papua_scene = scene_resource.instantiate()
	if not papua_scene:
		GameLogger.graph_error("❌ [W5 Headless Test] Failed to instantiate Papua scene")
		quit(1)
		return
	
	# Set as current scene
	current_scene = papua_scene
	GameLogger.info("✅ [W5 Headless Test] Papua scene loaded successfully")
	
	# Find terrain controller
	var terrain_controller = papua_scene.find_child("TerrainController", true, false)
	if not terrain_controller:
		# Try alternative names
		var controller_names = ["Terrain3DController", "PapuaTerrainController"]
		for name in controller_names:
			terrain_controller = papua_scene.find_child(name, true, false)
			if terrain_controller:
				break
	
	if not terrain_controller:
		GameLogger.graph_error("❌ [W5 Headless Test] Terrain controller not found")
		quit(1)
		return
	
	GameLogger.info("✅ [W5 Headless Test] Found terrain controller: %s" % terrain_controller.name)
	
	# Test W5 generation
	GameLogger.info("🔑 [W5 Headless Test] Testing W5 generation (simulating KEY_5)...")
	
	if terrain_controller.has_method("_generate_modern_wheel_graph"):
		GameLogger.info("🚀 [W5 Headless Test] Calling _generate_modern_wheel_graph(5)...")
		terrain_controller._generate_modern_wheel_graph(5)
		GameLogger.info("✅ [W5 Headless Test] W5 generation method called successfully")
	else:
		GameLogger.graph_error("❌ [W5 Headless Test] _generate_modern_wheel_graph method not found")
		quit(1)
		return
	
	# Wait a moment for generation to complete
	await process_frame
	await process_frame
	
	# Check for generated content
	var graph_nodes = []
	_find_graph_nodes_recursive(papua_scene, graph_nodes)
	
	GameLogger.info("📊 [W5 Headless Test] Post-generation analysis:")
	GameLogger.info("  - Graph nodes found: %d" % graph_nodes.size())
	
	if graph_nodes.size() > 0:
		for node in graph_nodes:
			GameLogger.info("  - Node: %s (%s)" % [node.name, node.get_class()])
		GameLogger.info("🎉 [W5 Headless Test] W5 generation test PASSED!")
		quit(0)
	else:
		GameLogger.graph_error("💥 [W5 Headless Test] W5 generation test FAILED - no graph nodes generated")
		quit(1)

func _find_graph_nodes_recursive(node: Node, found_nodes: Array):
	"""Recursively find graph-related nodes"""
	if node.name.contains("Graph") or node.name.contains("Wheel") or node.name.contains("Vertex") or node.name.contains("Edge") or node.name.contains("Path"):
		found_nodes.append(node)
	
	for child in node.get_children():
		_find_graph_nodes_recursive(child, found_nodes)
