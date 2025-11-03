extends Node3D

## Main Terrain3D Controller - Uses the new SOLID-based system
## This is now a facade that uses the factory pattern to create appropriate controllers


var terrain_controller: Terrain3DBaseController
var terrain_type: Terrain3DControllerFactory.TerrainType = Terrain3DControllerFactory.TerrainType.PAPUA

func _ready():
	print("🚨 TERRAIN3D CONTROLLER _ready() CALLED AT TIME: %s" % Time.get_datetime_string_from_system())
	GameLogger.info("🏗️ [CONTROLLER DEBUG] Terrain3D Controller initialized at %s" % Time.get_datetime_string_from_system())
	GameLogger.info("📍 [CONTROLLER DEBUG] Controller node path: %s" % get_path())
	GameLogger.info("📍 [CONTROLLER DEBUG] Parent node: %s" % (get_parent().name if get_parent() else "None"))
	print("🚨 CONTROLLER DEBUG MESSAGES SENT TO LOG!")
	
	# Enable input processing
	set_process_input(true)
	set_process_unhandled_input(true)
	set_process_unhandled_key_input(true)
	GameLogger.info("✅ [TerrainController] All input processing enabled (input: %s, unhandled: %s, key: %s)" % [
		is_processing_input(), 
		is_processing_unhandled_input(),
		is_processing_unhandled_key_input()
	], "GraphSystem")
	
	# Debug scene structure
	GameLogger.info("🔍 Scene structure around controller:")
	_debug_scene_structure()
	
	# Add to terrain controller group for editor access
	add_to_group("terrain_controller")
	
	# Create appropriate terrain controller using factory
	GameLogger.info("🏭 Creating terrain controller using factory...")
	terrain_controller = Terrain3DControllerFactory.create_controller(terrain_type, self)
	if not terrain_controller:
		GameLogger.terrain_error("❌ Failed to create terrain controller")
		return
	
	GameLogger.info("✅ Terrain controller created: %s" % terrain_controller.get_class())
	
	# Initialize the terrain
	GameLogger.info("🚀 Initializing terrain...")
	terrain_controller.initialize_terrain()
	
	GameLogger.info("🔌 Setting up UI connections...")
	setup_ui_connections()
	
	GameLogger.info("✅ Terrain3D Controller setup complete")

func _debug_scene_structure():
	"""Debug the scene structure around this controller"""
	GameLogger.info("📁 Current directory children:")
	for child in get_parent().get_children():
		GameLogger.info("  - %s (%s)" % [child.name, child.get_class()])
	
	GameLogger.info("🔍 Looking for Terrain3DManager...")
	var terrain_manager = get_parent().get_node_or_null("Terrain3DManager")
	if terrain_manager:
		GameLogger.info("✅ Found Terrain3DManager")
		GameLogger.info("📁 Terrain3DManager children:")
		for child in terrain_manager.get_children():
			GameLogger.info("  - %s (%s)" % [child.name, child.get_class()])
	else:
		GameLogger.terrain_error("❌ Terrain3DManager not found!")

func is_terrain_debug_enabled() -> bool:
	"""Check if terrain debug is enabled"""
	if terrain_controller:
		return terrain_controller.is_debug_enabled("terrain")
	return false

func is_terrain_height_debug_enabled() -> bool:
	"""Check if terrain height debug is enabled"""
	if terrain_controller:
		return terrain_controller.is_debug_enabled("terrain_height")
	return false

func is_asset_placement_debug_enabled() -> bool:
	"""Check if asset placement debug is enabled"""
	if terrain_controller:
		return terrain_controller.is_debug_enabled("asset_placement")
	return false

func setup_ui_connections():
	"""Connect UI buttons to terrain functions"""
	GameLogger.info("🔍 Setting up terrain UI connections...")
	
	var terrain_controls = get_node_or_null("../../UI/TerrainControls")
	if not terrain_controls:
		GameLogger.terrain_warning("⚠️ TerrainControls UI not found")
		GameLogger.info("🔍 Available UI children:")
		var ui_node = get_node_or_null("../../UI")
		if ui_node:
			for child in ui_node.get_children():
				GameLogger.info("  - %s (%s)" % [child.name, child.get_class()])
		return
	
	GameLogger.info("✅ Found TerrainControls UI")
	GameLogger.info("📁 TerrainControls children:")
	for child in terrain_controls.get_children():
		GameLogger.info("  - %s (%s)" % [child.name, child.get_class()])
	
	# PENTAGON FOCUS MODE + WORKING TERRAIN FUNCTIONS
	GameLogger.info("🎯 PENTAGON FOCUS MODE - Available key bindings:")
	GameLogger.info("  5 = Generate W5 (Pentagon) Wheel Graph [PRIMARY TEST]")
	GameLogger.info("  6 = Place Demo Rock Assets")
	GameLogger.info("  7 = Show Terrain Statistics")
	GameLogger.info("  9 = Show Terrain3D Region Info")
	GameLogger.info("  C = Clear Assets [RESET SCENE]")
	GameLogger.info("ℹ️ Pentagon wheel graph is main focus for testing")
	
	GameLogger.info("✅ UI connections setup complete (keyboard shortcuts enabled)")

func _on_generate_forest():
	"""Generate forest assets near player position"""
	if terrain_controller:
		terrain_controller.place_assets_near_player(30.0)
	else:
		GameLogger.terrain_error("❌ No terrain controller available")

func _on_place_psx_assets():
	"""Place PSX assets near player position"""
	if terrain_controller:
		terrain_controller.place_assets_near_player(25.0)
	else:
		GameLogger.terrain_error("❌ No terrain controller available")

func _on_clear_assets():
	"""Clear all placed assets"""
	if terrain_controller:
		terrain_controller.clear_all_assets()
	else:
		GameLogger.terrain_error("❌ No terrain controller available")

func _show_terrain_info():
	"""Show terrain information and stats"""
	if terrain_controller:
		var stats = terrain_controller.get_terrain_stats()
		GameLogger.info("📊 ===== TERRAIN INFORMATION =====")
		GameLogger.info("🌲 Trees: %d" % stats.get("trees", 0))
		GameLogger.info("🌿 Vegetation: %d" % stats.get("vegetation", 0))
		GameLogger.info("🍄 Mushrooms: %d" % stats.get("mushrooms", 0))
		GameLogger.info("🪨 Stones: %d" % stats.get("stones", 0))
		GameLogger.info("🗑️ Debris: %d" % stats.get("debris", 0))
		GameLogger.info("📈 Total Assets: %d" % stats.get("total", 0))
		GameLogger.info("📊 ===== END TERRAIN INFO =====")
	else:
		GameLogger.terrain_error("❌ No terrain controller available")

func get_terrain_height_at_position(world_pos: Vector3) -> float:
	"""Get terrain height at world position"""
	if terrain_controller:
		return terrain_controller.get_terrain_height_at_position(world_pos)
	return 0.0

func _input(event):
	"""Handle input for terrain controls"""
	print("🚨 TERRAIN CONTROLLER _input() CALLED!")
	GameLogger.debug("🎮 [Input Debug] _input() called with event: %s" % event, "GraphSystem")
	_handle_input_event(event)

func _unhandled_input(event):
	"""Handle unhandled input for terrain controls"""
	GameLogger.debug("🎮 [Input Debug] _unhandled_input() called with event: %s" % event, "GraphSystem")
	_handle_input_event(event)

func _unhandled_key_input(event):
	"""Handle unhandled key input for terrain controls - highest priority for keys"""
	GameLogger.debug("🎮 [Input Debug] _unhandled_key_input() called with event: %s" % event, "GraphSystem")
	_handle_input_event(event)

func _handle_input_event(event):
	"""Common input handling for both _input and _unhandled_input"""
	# Debug KEY_5 specifically
	if event is InputEventKey and event.keycode == KEY_5:
		GameLogger.info("🔑 [KEY_5 Debug] KEY_5 detected! Pressed: %s" % event.pressed, "GraphSystem")
	
	if event is InputEventKey and event.pressed:
		GameLogger.info("🎮 [Input Debug] Key pressed: %s (keycode: %d)" % [OS.get_keycode_string(event.keycode), event.keycode], "GraphSystem")
		match event.keycode:
			KEY_5:
				# FOCUS TEST: Generate W5 (Pentagon) wheel graph ONLY
				print("🚨 KEY_5 DETECTED IN TERRAIN CONTROLLER!")
				GameLogger.info("🔑 [PENTAGON TEST] KEY_5 pressed - Generating Pentagon wheel graph...", "GraphSystem")
				print("🚨 TRYING DIRECT GRAPHFACTORY APPROACH...")
				_generate_pentagon_direct()
				print("🚨 DIRECT PENTAGON GENERATION COMPLETED!")
			KEY_6:
				# Place Demo Rock Assets (original function)
				GameLogger.info("🪨 KEY_6 pressed - Placing demo rock assets...")
				place_demo_rock_assets()
			KEY_7:
				# Show Terrain Statistics
				GameLogger.info("📊 KEY_7 pressed - Showing terrain statistics...")
				_show_terrain_info()
			KEY_9:
				# Show Terrain3D Region Info  
				GameLogger.info("📊 KEY_9 pressed - Showing Terrain3D region info...")
				show_terrain3d_regions()
			KEY_C:
				# Clear all Pentagon graphs and assets to reset scene
				print("🚨 KEY_C: Clearing all Pentagon graphs and assets...")
				GameLogger.info("🧹 KEY_C pressed - Clearing assets...")
				_clear_all_pentagon_graphs()
				_on_clear_assets()
			_:
				# Other keys - show available options
				GameLogger.info("🔑 Key %s pressed - Available: 5=Pentagon, 6=Rocks, 7=Stats, 9=Regions, C=Clear" % OS.get_keycode_string(event.keycode), "GraphSystem")

# Terrain generation methods moved to Research class

# All terrain functions now properly delegate to terrain_controller

func generate_hexagonal_path_system():
	"""Generate hexagonal path system with fixed artifact/NPC placement (Legacy - use W5)"""
	GameLogger.info("🔷 generate_hexagonal_path_system() called (legacy)")
	_generate_modern_wheel_graph(5)

func generate_wheel_graph_by_type(wheel_type: int):
	"""Generate wheel graph of specific type (W4, W5, W6, W7, W8, W9) - Legacy method"""
	GameLogger.info("🔷 generate_wheel_graph_by_type() called for %s (legacy - delegating to modern system)" % wheel_type)
	_generate_modern_wheel_graph(int(wheel_type))

# Signal handlers for wheel graph generation (legacy - kept for compatibility)
func _on_wheel_graph_generation_started(_config):
	"""Handle wheel graph generation started"""
	GameLogger.info("🚀 Wheel graph generation started")

func _on_wheel_graph_generation_completed(vertex_count: int, path_count: int):
	"""Handle wheel graph generation completed"""
	GameLogger.info("🎉 Wheel graph completed: %d vertices, %d paths" % [vertex_count, path_count])

func _on_wheel_graph_generation_failed(error_message: String):
	"""Handle wheel graph generation failed"""
	GameLogger.terrain_error("💥 Wheel graph generation failed: %s" % error_message)

func place_demo_rock_assets():
	"""Place demo rock assets near player position using improved height sampling"""
	GameLogger.info("🪨 place_demo_rock_assets() called")
	if terrain_controller:
		GameLogger.info("✅ Terrain controller found, delegating to base controller")
		terrain_controller.place_demo_rock_assets()
	else:
		GameLogger.terrain_error("❌ No terrain controller available")

# Mountain border function moved to Research folder
# See: Systems/Terrain3D/Research/Terrain3DResearch.gd

func show_terrain3d_regions():
	"""Show information about Terrain3D regions"""
	if terrain_controller:
		terrain_controller.show_terrain3d_regions()
	else:
		GameLogger.terrain_error("❌ No terrain controller available")

func test_terrain_height_sampling():
	"""Test terrain height sampling at various positions"""
	if terrain_controller:
		terrain_controller.test_terrain_height_sampling()
	else:
		GameLogger.terrain_error("❌ No terrain controller available")

func get_player_position() -> Vector3:
	"""Get the current player position"""
	var player = get_node_or_null("../../Player")
	if player:
		return player.global_position
	
	# Try alternative paths
	var alternative_paths = ["../Player", "Player", "../../../Player"]
	for path in alternative_paths:
		player = get_node_or_null(path)
		if player:
			return player.global_position
	
	GameLogger.terrain_warning("⚠️ Player not found - using default position")
	return Vector3.ZERO

func _generate_modern_wheel_graph(vertex_count: int) -> void:
	"""Generate wheel graph using the new graph system - PENTAGON FOCUS"""
	print("🚨 _generate_modern_wheel_graph called with vertex_count: %d" % vertex_count)
	
	if vertex_count != 5:
		print("🚨 REJECTED: vertex_count is %d, not 5!" % vertex_count)
		GameLogger.info("🚫 [PENTAGON TEST] Only Pentagon (W5) generation enabled for focused testing. Requested: W%d" % vertex_count, "GraphSystem")
		return
	
	print("🚨 PENTAGON CHECK PASSED! Starting generation...")
	GameLogger.info("🔷 [PENTAGON] Starting Pentagon wheel graph generation..." % [], "GraphSystem")
	GameLogger.info("📊 [PENTAGON] Expected structure: 6 vertices (5 outer + 1 center), 10 edges (5 spokes + 5 ring)" % [], "GraphSystem")
	
	# Get or create graph system controller
	print("🚨 Getting graph system controller...")
	GameLogger.info("🔧 [PENTAGON] Getting graph system controller..." % [], "GraphSystem")
	var graph_controller = await _get_or_create_graph_controller()
	if not graph_controller:
		print("🚨 FAILED to get graph controller!")
		GameLogger.terrain_error("❌ [PENTAGON] Failed to get graph system controller")
		return
	print("🚨 Graph controller ready: %s" % graph_controller.get_class())
	GameLogger.info("✅ [PENTAGON] Graph controller ready" % [], "GraphSystem")
	
	# Get player position for centering
	print("🚨 Getting player position...")
	GameLogger.info("📍 [PENTAGON] Getting player position for center..." % [], "GraphSystem")
	var player_pos = get_player_position()
	if player_pos == Vector3.ZERO:
		player_pos = Vector3(0, 0, 0)
		print("🚨 Using default center position: %s" % player_pos)
		GameLogger.terrain_warning("⚠️ [PENTAGON] Using default center position")
	else:
		print("🚨 Player position found: %s" % player_pos)
		GameLogger.info("✅ [PENTAGON] Player position: %s" % player_pos, "GraphSystem")
	
	# Generate Pentagon wheel graph
	print("🚨 Testing if GraphSystemController methods work...")
	var method_names = []
	for method in graph_controller.get_method_list().slice(0, 10):
		method_names.append(method.name)
	print("🚨 Available methods: " + str(method_names))
	
	print("🚨 Calling graph_controller.generate_wheel_graph(5, " + str(player_pos) + ", 25.0)...")
	GameLogger.info("🚀 [PENTAGON] Generating Pentagon wheel graph at %s with radius 25.0..." % player_pos, "GraphSystem")
	
	# Test if GraphSystemController is actually working
	print("🚨 Testing GraphSystemController functionality...")
	if graph_controller.has_method("get_available_graph_types"):
		print("🚨 Calling get_available_graph_types()...")
		var types = graph_controller.get_available_graph_types()
		print("🚨 Available graph types: " + str(types))
	else:
		print("🚨 get_available_graph_types method not found!")
	
	# Add explicit debug message to see if we're calling the right method
	var success = false
	if graph_controller.has_method("generate_wheel_graph"):
		print("🚨 Method exists - trying both direct call and call() method...")
		print("🚨 BEFORE DIRECT CALL: About to call generate_wheel_graph directly")
		success = graph_controller.generate_wheel_graph(5, player_pos, 25.0)
		print("🚨 AFTER DIRECT CALL: generate_wheel_graph returned: %s" % success)
		
		print("🚨 BEFORE CALL() METHOD: About to use call() method")
		var success2 = graph_controller.call("generate_wheel_graph", 5, player_pos, 25.0)
		print("🚨 AFTER CALL() METHOD: call('generate_wheel_graph') returned: %s" % success2)
		
		# Use the call() result as it bypasses method resolution issues
		success = success2
	else:
		print("🚨 ERROR: generate_wheel_graph method not found!")
		success = false
	
	if success:
		print("🚨 SUCCESS: Pentagon wheel graph generated!")
		GameLogger.info("🎉 [PENTAGON] Pentagon wheel graph generated successfully!" % [], "GraphSystem")
	else:
		print("🚨 FAILED: Pentagon wheel graph generation failed!")
		GameLogger.terrain_error("💥 [PENTAGON] Failed to generate Pentagon wheel graph")

func _move_npcs_and_artifacts_to_pentagon_vertices(pentagon_graph):
	"""Move existing NPCs and artifacts to Pentagon vertex positions"""
	print("🎯 REPOSITIONING: Starting NPC and artifact repositioning...")
	
	# Get Pentagon vertex positions
	var vertex_positions = []
	if pentagon_graph and pentagon_graph.vertices:
		vertex_positions = pentagon_graph.vertices.duplicate()
		print("🎯 REPOSITIONING: Found %d Pentagon vertices" % vertex_positions.size())
		for i in range(vertex_positions.size()):
			print("🎯   Vertex %d: %s" % [i, vertex_positions[i]])
	else:
		print("❌ REPOSITIONING: No Pentagon vertices found")
		return
	
	# Find and move NPCs
	print("🎯 REPOSITIONING: Looking for NPCs to move...")
	var scene_root = get_tree().current_scene
	var npcs = []
	_find_npcs_recursive(scene_root, npcs)
	
	print("🎯 REPOSITIONING: Found %d NPCs to reposition" % npcs.size())
	for i in range(min(npcs.size(), vertex_positions.size())):
		var npc = npcs[i]
		var new_pos = vertex_positions[i]
		var old_pos = npc.global_position
		npc.global_position = new_pos
		print("🎯 REPOSITIONING: Moved NPC %s from %s to %s" % [npc.name, old_pos, new_pos])
	
	# Find and move artifacts
	print("🎯 REPOSITIONING: Looking for artifacts to move...")
	var artifacts = []
	_find_artifacts_recursive(scene_root, artifacts)
	
	print("🎯 REPOSITIONING: Found %d artifacts to reposition" % artifacts.size())
	var remaining_vertices = vertex_positions.slice(npcs.size())  # Use remaining vertices for artifacts
	for i in range(min(artifacts.size(), remaining_vertices.size())):
		var artifact = artifacts[i]
		var new_pos = remaining_vertices[i]
		var old_pos = artifact.global_position
		artifact.global_position = new_pos
		print("🎯 REPOSITIONING: Moved artifact %s from %s to %s" % [artifact.name, old_pos, new_pos])
	
	print("🎉 REPOSITIONING: Completed! NPCs and artifacts moved to Pentagon vertices")

func _find_npcs_recursive(node: Node, npc_list: Array):
	"""Recursively find all NPC nodes in the scene"""
	# Only add nodes that are Node3D or CharacterBody3D (have global_position)
	if node is Node3D or node is CharacterBody3D:
		if node.has_method("get_script") and node.get_script():
			var script_path = node.get_script().resource_path
			if script_path.contains("CulturalNPC.gd") or script_path.contains("NPC.gd"):
				npc_list.append(node)
				print("🎯 FOUND NPC: %s (%s)" % [node.name, node.get_class()])
		
		# Also check by group membership
		if node.is_in_group("npc") or node.is_in_group("npcs"):
			if node not in npc_list:
				npc_list.append(node)
				print("🎯 FOUND NPC (group): %s (%s)" % [node.name, node.get_class()])
	
	for child in node.get_children():
		_find_npcs_recursive(child, npc_list)

func _find_artifacts_recursive(node: Node, artifact_list: Array):
	"""Recursively find all artifact/item nodes in the scene"""
	# Only add nodes that are Node3D (have global_position)
	if node is Node3D:
		# Check by script path
		if node.has_method("get_script") and node.get_script():
			var script_path = node.get_script().resource_path
			if script_path.contains("WorldCulturalItem.gd") or script_path.contains("Item.gd"):
				# Skip NPCs and managers (they're handled separately)
				if not script_path.contains("NPC") and not script_path.contains("Manager"):
					artifact_list.append(node)
					print("🎯 FOUND ARTIFACT (script): %s (%s)" % [node.name, node.get_class()])
		
		# Check by group membership
		if node.is_in_group("artifacts") or node.is_in_group("items"):
			if node not in artifact_list:
				artifact_list.append(node)
				print("🎯 FOUND ARTIFACT (group): %s (%s)" % [node.name, node.get_class()])
		
		# Check by name patterns for Papua artifacts (from scene file analysis)
		var artifact_names = ["KapakPerunggu", "TraditionalMask", "AncientTool", "SacredStone", "BatuDootomo"]
		if node.name in artifact_names:
			if node not in artifact_list:
				artifact_list.append(node)
				print("🎯 FOUND ARTIFACT (name): %s (%s)" % [node.name, node.get_class()])
		
		# Check if node has cultural item properties (item_name, cultural_region)
		if node.has_method("get") and (node.get("item_name") != null or node.get("cultural_region") != null):
			if node not in artifact_list:
				artifact_list.append(node)
				print("🎯 FOUND ARTIFACT (properties): %s (%s)" % [node.name, node.get_class()])
	
	for child in node.get_children():
		_find_artifacts_recursive(child, artifact_list)

func _clear_all_pentagon_graphs():
	"""Clear all Pentagon wheel graph nodes from the scene"""
	print("🧹 CLEARING: Removing all Pentagon graph nodes...")
	var removed_count = 0
	
	for child in get_children():
		if child.name.begins_with("WHEEL") or child.name.begins_with("@Node3D"):
			print("🧹 CLEARING: Removing %s" % child.name)
			child.queue_free()
			removed_count += 1
	
	print("🧹 CLEARING: Removed %d Pentagon graph nodes" % removed_count)

func _generate_pentagon_direct():
	"""Generate Pentagon wheel graph directly using GraphFactory to bypass controller issues"""
	print("🚨 DIRECT PENTAGON: Starting direct generation...")
	
	# Use fixed region center instead of player position for better layout
	var region_center = Vector3(0, 0, 0)  # Center of Papua region
	print("🚨 DIRECT PENTAGON: Using region center: %s" % region_center)
	
	# Load GraphFactory directly
	var GraphFactory = preload("res://Systems/Terrain3D/GraphSystem/GraphFactory.gd")
	print("🚨 DIRECT PENTAGON: GraphFactory loaded")
	
	# Create Pentagon wheel graph with proper terrain height alignment
	print("🚨 DIRECT PENTAGON: Getting terrain height at region center...")
	var terrain_height = get_terrain_height_at_position(region_center)
	print("🚨 DIRECT PENTAGON: Terrain height at %s: %f" % [region_center, terrain_height])
	
	var terrain_aligned_pos = Vector3(region_center.x, terrain_height + 0.5, region_center.z)  # 0.5m above terrain
	print("🚨 DIRECT PENTAGON: Terrain-aligned position: %s" % terrain_aligned_pos)
	
	# Use smaller radius for better wheel visibility and testing
	var wheel_radius = 25.0  # Smaller radius to see wheel structure clearly
	print("🚨 DIRECT PENTAGON: Using wheel radius: %f for clear wheel structure" % wheel_radius)
	print("🚨 DIRECT PENTAGON: Calling GraphFactory.create_wheel_graph(5, %s, %f)..." % [terrain_aligned_pos, wheel_radius])
	var pentagon_graph = GraphFactory.create_wheel_graph(5, terrain_aligned_pos, wheel_radius)
	
	# Modify the config to make paths more visible with road texture
	if pentagon_graph and pentagon_graph.graph_config:
		pentagon_graph.graph_config.path_width = 5.0    # Much wider paths
		pentagon_graph.graph_config.path_height = 1.0   # Much taller paths  
		
		# Create road material with dirt texture
		var road_material = StandardMaterial3D.new()
		var dirt_texture = preload("res://Assets/PSX/PSX Textures/Color/dirt_3.png")
		road_material.albedo_texture = dirt_texture
		road_material.roughness = 0.9
		road_material.metallic = 0.0
		road_material.uv1_scale = Vector3(2.0, 1.0, 2.0)  # Scale texture for better tiling
		pentagon_graph.graph_config.path_material = road_material
		pentagon_graph.graph_config.path_color = Color.BROWN  # Fallback color
		print("🚨 DIRECT PENTAGON: Modified config - width: 5.0, height: 1.0, road texture applied")
	
	if pentagon_graph:
		print("🚨 DIRECT PENTAGON: Graph created successfully: %s" % pentagon_graph.get_class())
		
		# Generate the graph in the scene
		print("🚨 DIRECT PENTAGON: Calling pentagon_graph.generate_graph(self)...")
		print("🚨 DIRECT PENTAGON: Current children count: %d" % get_child_count())
		var success = pentagon_graph.generate_graph(self)
		print("🚨 DIRECT PENTAGON: Graph generation returned: %s" % success)
		print("🚨 DIRECT PENTAGON: Children count after generation: %d" % get_child_count())
		
		# List new children with detailed info
		print("🚨 DIRECT PENTAGON: Current children:")
		for child in get_children():
			print("🚨   - %s (%s)" % [child.name, child.get_class()])
			if child.name.begins_with("WHEEL") or child.name.begins_with("@Node3D"):
				print("🚨     Position: %s" % child.global_position)
				print("🚨     Visible: %s" % child.visible)
				print("🚨     Children: %d" % child.get_child_count())
				# Show first few children with detailed info
				for i in range(min(3, child.get_child_count())):
					var grandchild = child.get_child(i)
					print("🚨       - %s (%s) at %s" % [grandchild.name, grandchild.get_class(), grandchild.global_position])
					
					# If it's Edges or Vertices, show their children (the actual paths/objects)
					if grandchild.name == "Edges" or grandchild.name == "Vertices":
						print("🚨         %s has %d children:" % [grandchild.name, grandchild.get_child_count()])
						for j in range(min(3, grandchild.get_child_count())):
							var path_node = grandchild.get_child(j)
							print("🚨           - %s (%s) at %s, visible: %s" % [path_node.name, path_node.get_class(), path_node.global_position, path_node.visible])
		
		if success:
			print("🎉 DIRECT PENTAGON: Pentagon wheel graph generated and placed in scene!")
			
			# Debug wheel structure
			_debug_wheel_structure(pentagon_graph)
			
			# Move existing NPCs and artifacts to Pentagon vertices
			print("🚨 DIRECT PENTAGON: Moving NPCs and artifacts to Pentagon vertices...")
			_move_npcs_and_artifacts_to_pentagon_vertices(pentagon_graph)
		else:
			print("💥 DIRECT PENTAGON: Graph generation failed")
	else:
		print("💥 DIRECT PENTAGON: Failed to create Pentagon graph")

func _get_or_create_graph_controller() -> GraphSystemController:
	"""Get or create the graph system controller"""
	print("🚨 Looking for existing GraphSystemController...")
	# Look for existing graph controller
	var graph_controller = get_node_or_null("GraphSystemController")
	if graph_controller and graph_controller is GraphSystemController:
		print("🚨 Found existing GraphSystemController: %s" % graph_controller.get_class())
		return graph_controller
	
	print("🚨 Creating new GraphSystemController...")
	# Create new graph controller using preload to ensure correct class
	var GraphSystemControllerClass = preload("res://Systems/Terrain3D/GraphSystem/GraphSystemController.gd")
	graph_controller = GraphSystemControllerClass.new()
	graph_controller.name = "GraphSystemController"
	add_child(graph_controller)
	
	# Wait for the controller to be ready
	await get_tree().process_frame
	
	print("🚨 Created GraphSystemController: %s" % graph_controller.get_class())
	print("🚨 GraphSystemController script: %s" % (graph_controller.get_script().resource_path if graph_controller.get_script() else "None"))
	print("🚨 GraphSystemController has generate_wheel_graph method: %s" % graph_controller.has_method("generate_wheel_graph"))
	GameLogger.info("✅ Created new GraphSystemController")
	return graph_controller
