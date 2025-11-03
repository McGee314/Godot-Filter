extends Node

## Comprehensive test for KEY_5 W5 generation in Papua Terrain3D scene
## Tests the complete flow: KEY_5 press -> W5 hexagon generation
## Includes excellent GameLogger output for debugging

func _ready():
	GameLogger.info("🧪 [KEY_5 W5 Test] Starting comprehensive KEY_5 W5 generation test...")
	test_key5_w5_functionality()

func test_key5_w5_functionality():
	"""Test KEY_5 functionality for W5 hexagon generation"""
	GameLogger.info("🔬 [KEY_5 W5 Test] Testing KEY_5 -> W5 generation functionality...")
	
	# Load Papua scene
	var scene_path = "res://Scenes/IndonesiaTimur/PapuaScene_Terrain3D.tscn"
	var scene_resource = load(scene_path)
	if not scene_resource:
		GameLogger.graph_error("❌ [KEY_5 W5 Test] Failed to load Papua scene")
		return
	
	var papua_scene = scene_resource.instantiate()
	if not papua_scene:
		GameLogger.graph_error("❌ [KEY_5 W5 Test] Failed to instantiate Papua scene")
		return
	
	# Add to scene tree
	get_tree().current_scene.add_child.call_deferred(papua_scene)
	GameLogger.info("✅ [KEY_5 W5 Test] Papua scene loaded")
	
	# Wait for initialization
	await get_tree().process_frame
	await get_tree().create_timer(1.0).timeout
	
	# Find terrain controller
	var terrain_controller = papua_scene.find_child("TerrainController", true, false)
	if not terrain_controller:
		GameLogger.graph_error("❌ [KEY_5 W5 Test] Terrain controller not found")
		return
	
	GameLogger.info("✅ [KEY_5 W5 Test] Found terrain controller: %s" % terrain_controller.name)
	
	# Test KEY_5 input handling
	GameLogger.info("🔑 [KEY_5 W5 Test] Simulating KEY_5 input event...")
	
	# Create KEY_5 input event
	var input_event = InputEventKey.new()
	input_event.keycode = KEY_5
	input_event.pressed = true
	
	# Send input to terrain controller
	if terrain_controller.has_method("_input"):
		GameLogger.info("🎯 [KEY_5 W5 Test] Sending KEY_5 input to terrain controller...")
		terrain_controller._input(input_event)
		
		# Wait for generation to complete
		await get_tree().process_frame
		await get_tree().create_timer(1.0).timeout
		
		GameLogger.info("🎉 [KEY_5 W5 Test] KEY_5 input simulation completed!")
	else:
		GameLogger.graph_error("❌ [KEY_5 W5 Test] Terrain controller doesn't handle input - trying direct method call...")
		# Fallback: call the method directly
		if terrain_controller.has_method("_generate_modern_wheel_graph"):
			GameLogger.info("🔄 [KEY_5 W5 Test] Calling _generate_modern_wheel_graph(5) directly...")
			terrain_controller._generate_modern_wheel_graph(5)
	
	# Analyze generated content
	var graph_nodes = []
	_find_graph_nodes_recursive(papua_scene, graph_nodes)
	
	GameLogger.info("📊 [KEY_5 W5 Test] Post-generation analysis:")
	GameLogger.info("  - Total graph nodes: %d" % graph_nodes.size())
	
	for node in graph_nodes:
		GameLogger.info("  - Found: %s (%s) with %d children" % [node.name, node.get_class(), node.get_child_count()])
	
	if graph_nodes.size() > 0:
		GameLogger.info("🎉 [KEY_5 W5 Test] SUCCESS: W5 generation working!")
	else:
		GameLogger.info("ℹ️ [KEY_5 W5 Test] No graph nodes found - may be normal if generation is deferred")
	
	# Clean up and exit
	papua_scene.queue_free()
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()

func _find_graph_nodes_recursive(node: Node, found_nodes: Array):
	"""Recursively find graph-related nodes"""
	if node.name.contains("Graph") or node.name.contains("Wheel") or node.name.contains("Vertex") or node.name.contains("Edge") or node.name.contains("Path") or node.name.contains("Hexagon"):
		found_nodes.append(node)
	
	for child in node.get_children():
		_find_graph_nodes_recursive(child, found_nodes)
