extends Node

## Direct test of hexagon generation functions in PapuaScene_Terrain3D
## Bypasses input handling to test the core functions directly

var papua_scene: Node3D
var terrain_controller: Node

func _ready():
	GameLogger.info("🧪 [Direct Hexagon Test] Starting direct hexagon generation test...", "GraphSystem")
	test_direct_functions()

func test_direct_functions():
	"""Test hexagon and rock functions directly"""
	GameLogger.info("🔬 [Direct Hexagon Test] Testing functions directly...", "GraphSystem")
	
	# Load Papua scene
	var scene_path = "res://Scenes/IndonesiaTimur/PapuaScene_Terrain3D.tscn"
	var scene_resource = load(scene_path)
	if not scene_resource:
		GameLogger.error("❌ [Direct Hexagon Test] Failed to load Papua scene", "GraphSystem")
		return
	
	papua_scene = scene_resource.instantiate()
	if not papua_scene:
		GameLogger.error("❌ [Direct Hexagon Test] Failed to instantiate Papua scene", "GraphSystem")
		return
	
	# Add to scene tree
	get_tree().current_scene.add_child.call_deferred(papua_scene)
	
	# Wait for initialization
	await get_tree().process_frame
	await get_tree().create_timer(1.0).timeout
	
	# Find terrain controller
	terrain_controller = papua_scene.find_child("TerrainController", true, false)
	if not terrain_controller:
		GameLogger.error("❌ [Direct Hexagon Test] TerrainController not found", "GraphSystem")
		return
	
	GameLogger.info("✅ [Direct Hexagon Test] Found TerrainController: %s" % terrain_controller.name, "GraphSystem")
	
	# Test 1: Direct hexagon generation
	GameLogger.info("🔬 [Direct Hexagon Test] Test 1: Direct hexagon generation...", "GraphSystem")
	if terrain_controller.has_method("generate_hexagonal_path_system"):
		GameLogger.info("🚀 [Direct Hexagon Test] Calling generate_hexagonal_path_system()...", "GraphSystem")
		terrain_controller.generate_hexagonal_path_system()
		await get_tree().process_frame
		GameLogger.info("✅ [Direct Hexagon Test] Hexagon generation call completed", "GraphSystem")
	else:
		GameLogger.error("❌ [Direct Hexagon Test] generate_hexagonal_path_system() method not found", "GraphSystem")
	
	# Test 2: Direct W5 generation
	GameLogger.info("🔬 [Direct Hexagon Test] Test 2: Direct W5 generation...", "GraphSystem")
	if terrain_controller.has_method("_generate_modern_wheel_graph"):
		GameLogger.info("🚀 [Direct Hexagon Test] Calling _generate_modern_wheel_graph(5)...", "GraphSystem")
		terrain_controller._generate_modern_wheel_graph(5)
		await get_tree().process_frame
		GameLogger.info("✅ [Direct Hexagon Test] W5 generation call completed", "GraphSystem")
	else:
		GameLogger.error("❌ [Direct Hexagon Test] _generate_modern_wheel_graph() method not found", "GraphSystem")
	
	# Test 3: Direct W6 generation
	GameLogger.info("🔬 [Direct Hexagon Test] Test 3: Direct W6 generation...", "GraphSystem")
	if terrain_controller.has_method("_generate_modern_wheel_graph"):
		GameLogger.info("🚀 [Direct Hexagon Test] Calling _generate_modern_wheel_graph(6)...", "GraphSystem")
		terrain_controller._generate_modern_wheel_graph(6)
		await get_tree().process_frame
		GameLogger.info("✅ [Direct Hexagon Test] W6 generation call completed", "GraphSystem")
	
	# Test 4: Direct rock placement
	GameLogger.info("🔬 [Direct Hexagon Test] Test 4: Direct rock placement...", "GraphSystem")
	if terrain_controller.has_method("place_demo_rock_assets"):
		GameLogger.info("🪨 [Direct Hexagon Test] Calling place_demo_rock_assets()...", "GraphSystem")
		terrain_controller.place_demo_rock_assets()
		await get_tree().process_frame
		GameLogger.info("✅ [Direct Hexagon Test] Rock placement call completed", "GraphSystem")
	else:
		GameLogger.error("❌ [Direct Hexagon Test] place_demo_rock_assets() method not found", "GraphSystem")
	
	# Analyze scene after generation
	analyze_generated_content()
	
	# Clean up
	await get_tree().create_timer(2.0).timeout
	papua_scene.queue_free()
	get_tree().quit()

func analyze_generated_content():
	"""Analyze what was generated in the scene"""
	GameLogger.info("📊 [Direct Hexagon Test] Analyzing generated content...", "GraphSystem")
	
	if not papua_scene:
		return
	
	var generated_nodes = []
	_find_generated_content(papua_scene, generated_nodes)
	
	GameLogger.info("📋 [Direct Hexagon Test] Generated content analysis:", "GraphSystem")
	GameLogger.info("  - Total generated nodes: %d" % generated_nodes.size(), "GraphSystem")
	
	for node in generated_nodes:
		GameLogger.info("  - %s (%s) - %d children" % [node.name, node.get_class(), node.get_child_count()], "GraphSystem")
	
	if generated_nodes.size() == 0:
		GameLogger.warning("⚠️ [Direct Hexagon Test] No generated content found - functions may not be working", "GraphSystem")
	else:
		GameLogger.info("🎉 [Direct Hexagon Test] Generated content found - functions are working!", "GraphSystem")

func _find_generated_content(node: Node, found_nodes: Array):
	"""Find generated content in the scene"""
	var generated_names = ["Graph", "Wheel", "Hexagon", "Path", "Rock", "Demo", "Vertex", "Edge"]
	
	for name_part in generated_names:
		if node.name.contains(name_part):
			found_nodes.append(node)
			break
	
	for child in node.get_children():
		_find_generated_content(child, found_nodes)

func _input(event):
	"""Monitor input at test level"""
	if event is InputEventKey and event.pressed:
		var key_name = OS.get_keycode_string(event.keycode)
		GameLogger.info("🔑 [Papua KEY Debug] TEST LEVEL INPUT: %s (keycode: %d)" % [key_name, event.keycode], "GraphSystem")

func _unhandled_input(event):
	"""Monitor unhandled input at test level"""
	if event is InputEventKey and event.pressed:
		var key_name = OS.get_keycode_string(event.keycode)
		GameLogger.info("🔑 [Papua KEY Debug] TEST LEVEL UNHANDLED: %s (keycode: %d)" % [key_name, event.keycode], "GraphSystem")
