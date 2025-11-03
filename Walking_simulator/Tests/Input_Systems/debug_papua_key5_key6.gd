extends Node

## Comprehensive GameLogger debugging for KEY_5 and KEY_6 in PapuaScene_Terrain3D
## Tracks input flow, function calls, and hexagon/rock generation

var papua_scene: Node3D
var terrain_controller: Node

func _ready():
	GameLogger.info("🧪 [Papua KEY Debug] Starting comprehensive KEY_5/KEY_6 debugging...", "GraphSystem")
	
	# Enable all input processing
	set_process_input(true)
	set_process_unhandled_input(true)
	set_process_unhandled_key_input(true)
	
	# Load Papua scene
	load_papua_scene()

func load_papua_scene():
	"""Load Papua scene and analyze its structure"""
	GameLogger.info("🔬 [Papua KEY Debug] Loading PapuaScene_Terrain3D...", "GraphSystem")
	
	var scene_path = "res://Scenes/IndonesiaTimur/PapuaScene_Terrain3D.tscn"
	var scene_resource = load(scene_path)
	if not scene_resource:
		GameLogger.graph_error("❌ [Papua KEY Debug] Failed to load Papua scene")
		return
	
	papua_scene = scene_resource.instantiate()
	if not papua_scene:
		GameLogger.graph_error("❌ [Papua KEY Debug] Failed to instantiate Papua scene")
		return
	
	# Add to scene tree
	get_tree().current_scene.add_child.call_deferred(papua_scene)
	
	# Wait for initialization
	await get_tree().process_frame
	await get_tree().create_timer(1.0).timeout
	
	analyze_papua_scene()

func analyze_papua_scene():
	"""Analyze the Papua scene structure and input handling"""
	GameLogger.info("🔍 [Papua KEY Debug] Analyzing Papua scene structure...", "GraphSystem")
	
	# Find terrain controller
	terrain_controller = papua_scene.find_child("TerrainController", true, false)
	if terrain_controller:
		GameLogger.info("✅ [Papua KEY Debug] Found TerrainController: %s" % terrain_controller.name, "GraphSystem")
		GameLogger.info("📋 [Papua KEY Debug] TerrainController details:", "GraphSystem")
		GameLogger.info("  - Script: %s" % (terrain_controller.get_script().resource_path if terrain_controller.get_script() else "None"), "GraphSystem")
		GameLogger.info("  - Input processing: %s" % terrain_controller.is_processing_input(), "GraphSystem")
		GameLogger.info("  - Unhandled input: %s" % terrain_controller.is_processing_unhandled_input(), "GraphSystem")
		GameLogger.info("  - Key input: %s" % terrain_controller.is_processing_unhandled_key_input(), "GraphSystem")
		
		# Check if required methods exist
		var required_methods = [
			"_input", 
			"_unhandled_input", 
			"_unhandled_key_input",
			"_generate_modern_wheel_graph",
			"generate_hexagonal_path_system",
			"place_demo_rock_assets"
		]
		
		GameLogger.info("📋 [Papua KEY Debug] Method availability:", "GraphSystem")
		for method in required_methods:
			var has_method = terrain_controller.has_method(method)
			GameLogger.info("  - %s: %s" % [method, "✅" if has_method else "❌"], "GraphSystem")
	else:
		GameLogger.graph_error("❌ [Papua KEY Debug] TerrainController not found!", "GraphSystem")
	
	# Find player controller
	var player = papua_scene.find_child("Player", true, false)
	if player:
		GameLogger.info("✅ [Papua KEY Debug] Found Player: %s" % player.name, "GraphSystem")
		GameLogger.info("📋 [Papua KEY Debug] Player input processing:", "GraphSystem")
		GameLogger.info("  - Script: %s" % (player.get_script().resource_path if player.get_script() else "None"), "GraphSystem")
		GameLogger.info("  - Input processing: %s" % player.is_processing_input(), "GraphSystem")
		GameLogger.info("  - Unhandled input: %s" % player.is_processing_unhandled_input(), "GraphSystem")
	
	GameLogger.info("🎯 [Papua KEY Debug] Scene analysis complete. Press KEY_5 or KEY_6 to test...", "GraphSystem")

func _input(event):
	"""Monitor all input at test level"""
	if event is InputEventKey and event.pressed:
		var key_name = OS.get_keycode_string(event.keycode)
		GameLogger.info("🔑 [Papua KEY Debug] INPUT DETECTED: %s (keycode: %d)" % [key_name, event.keycode], "GraphSystem")
		
		if event.keycode == KEY_5:
			GameLogger.info("🎯 [Papua KEY Debug] KEY_5 PRESSED! Testing hexagon generation...", "GraphSystem")
			test_hexagon_generation()
		elif event.keycode == KEY_6:
			GameLogger.info("🎯 [Papua KEY Debug] KEY_6 PRESSED! Testing W6 generation...", "GraphSystem")
			test_w6_generation()

func _unhandled_input(event):
	"""Monitor unhandled input"""
	if event is InputEventKey and event.pressed:
		var key_name = OS.get_keycode_string(event.keycode)
		GameLogger.info("🔑 [Papua KEY Debug] UNHANDLED INPUT: %s (keycode: %d)" % [key_name, event.keycode], "GraphSystem")

func _unhandled_key_input(event):
	"""Monitor unhandled key input"""
	if event is InputEventKey and event.pressed:
		var key_name = OS.get_keycode_string(event.keycode)
		GameLogger.info("🔑 [Papua KEY Debug] UNHANDLED KEY INPUT: %s (keycode: %d)" % [key_name, event.keycode], "GraphSystem")

func test_hexagon_generation():
	"""Test hexagon path generation function"""
	GameLogger.info("🔬 [Papua KEY Debug] Testing hexagon generation function...", "GraphSystem")
	
	if not terrain_controller:
		GameLogger.graph_error("❌ [Papua KEY Debug] No terrain controller for hexagon test")
		return
	
	# Test hexagon generation methods
	if terrain_controller.has_method("generate_hexagonal_path_system"):
		GameLogger.info("🚀 [Papua KEY Debug] Calling generate_hexagonal_path_system()...", "GraphSystem")
		terrain_controller.generate_hexagonal_path_system()
	elif terrain_controller.has_method("_generate_modern_wheel_graph"):
		GameLogger.info("🚀 [Papua KEY Debug] Calling _generate_modern_wheel_graph(5)...", "GraphSystem")
		terrain_controller._generate_modern_wheel_graph(5)
	else:
		GameLogger.graph_error("❌ [Papua KEY Debug] No hexagon generation methods found!", "GraphSystem")
	
	# Test rock placement
	if terrain_controller.has_method("place_demo_rock_assets"):
		GameLogger.info("🪨 [Papua KEY Debug] Calling place_demo_rock_assets()...", "GraphSystem")
		terrain_controller.place_demo_rock_assets()
	else:
		GameLogger.graph_error("❌ [Papua KEY Debug] No rock placement method found!", "GraphSystem")

func test_w6_generation():
	"""Test W6 generation function"""
	GameLogger.info("🔬 [Papua KEY Debug] Testing W6 generation function...", "GraphSystem")
	
	if not terrain_controller:
		GameLogger.graph_error("❌ [Papua KEY Debug] No terrain controller for W6 test")
		return
	
	if terrain_controller.has_method("_generate_modern_wheel_graph"):
		GameLogger.info("🚀 [Papua KEY Debug] Calling _generate_modern_wheel_graph(6)...", "GraphSystem")
		terrain_controller._generate_modern_wheel_graph(6)
	else:
		GameLogger.graph_error("❌ [Papua KEY Debug] No W6 generation method found!", "GraphSystem")
