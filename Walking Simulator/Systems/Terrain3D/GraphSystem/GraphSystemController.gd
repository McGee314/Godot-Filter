extends Node
class_name GraphSystemController

## Controller for integrating the graph system with terrain controllers
## Provides high-level interface for generating different graph types

signal graph_generated(graph: BaseGraph)
signal graph_generation_failed(error: String)

var current_graph: BaseGraph
var terrain_controller: Node

func _ready():
	"""Initialize graph system controller"""
	print("🚨 GRAPHSYSTEMCONTROLLER _ready() CALLED AT TIME: %s" % Time.get_datetime_string_from_system())
	GameLogger.info("🔧 GraphSystemController initializing at %s..." % Time.get_datetime_string_from_system(), "GraphSystem")
	_find_terrain_controller()
	print("🚨 GRAPHSYSTEMCONTROLLER _ready() COMPLETED!")

func _exit_tree():
	"""Track when GraphSystemController is destroyed"""
	print("🚨 GRAPHSYSTEMCONTROLLER _exit_tree() CALLED - BEING DESTROYED!")
	GameLogger.info("🗑️ GraphSystemController being destroyed", "GraphSystem")

func _find_terrain_controller():
	"""Find the terrain controller in the scene"""
	# First, check if parent is a terrain controller
	var parent = get_parent()
	if parent and (parent.name.contains("TerrainController") or parent.name.contains("Terrain3D")):
		terrain_controller = parent
		GameLogger.info("✅ GraphSystemController: Found terrain controller as parent: %s" % parent.name)
		return
	
	# If not, search the scene tree
	var scene_tree = get_tree()
	if not scene_tree or not scene_tree.current_scene:
		GameLogger.warning("⚠️ GraphSystemController: No scene tree available")
		return
	
	terrain_controller = _find_terrain_controller_recursive(scene_tree.current_scene)
	if terrain_controller:
		GameLogger.info("✅ GraphSystemController: Found terrain controller in scene: %s" % terrain_controller.name)
	else:
		GameLogger.warning("⚠️ GraphSystemController: No terrain controller found")

func _find_terrain_controller_recursive(node: Node) -> Node:
	"""Recursively search for terrain controller"""
	# Look for terrain controller by name or class
	if node.name.contains("TerrainController") or node.name.contains("Terrain3D"):
		return node
	
	# Also check by script class name
	if node.get_script() and node.get_script().get_global_name() in ["Terrain3DController", "Terrain3DBaseController"]:
		return node
	
	for child in node.get_children():
		var result = _find_terrain_controller_recursive(child)
		if result:
			return result
	
	return null

func generate_cycle_graph(vertex_count: int, center: Vector3 = Vector3.ZERO, radius: float = 25.0) -> bool:
	"""Generate a cycle graph (C3, C4, C5, etc.)"""
	GameLogger.info("🔄 Generating cycle graph C%d at %s" % [vertex_count, center])
	
	var graph = GraphFactory.create_cycle_graph(vertex_count, center, radius)
	if not graph:
		var error = "Failed to create cycle graph C%d" % vertex_count
		GameLogger.graph_error("❌ " + error)
		graph_generation_failed.emit(error)
		return false
	
	return _generate_graph(graph)

func generate_wheel_graph(vertex_count: int, center: Vector3 = Vector3.ZERO, radius: float = 25.0) -> bool:
	"""Generate a wheel graph (W3, W4, W5, etc.)"""
	print("🚨 GRAPHSYSTEMCONTROLLER.generate_wheel_graph() CALLED WITH vertex_count=%d!" % vertex_count)
	GameLogger.info("🔄 [W%d Debug] GraphSystemController.generate_wheel_graph() called" % vertex_count, "GraphSystem")
	GameLogger.info("📊 [W%d Debug] Parameters: center=%s, radius=%s" % [vertex_count, center, radius], "GraphSystem")
	print("🚨 GraphSystemController debug messages sent to log!")
	
	GameLogger.info("🏭 [W%d Debug] Calling GraphFactory.create_wheel_graph()..." % vertex_count, "GraphSystem")
	var graph = GraphFactory.create_wheel_graph(vertex_count, center, radius)
	if not graph:
		var error = "Failed to create wheel graph W%d" % vertex_count
		GameLogger.graph_error("❌ [W%d Debug] " % vertex_count + error)
		graph_generation_failed.emit(error)
		return false
	
	GameLogger.info("✅ [W%d Debug] Graph created successfully: %s" % [vertex_count, graph.get_class()], "GraphSystem")
	GameLogger.info("🎯 [W%d Debug] Calling _generate_graph()..." % vertex_count, "GraphSystem")
	return _generate_graph(graph)

func generate_graph_from_factory(graph_type: GraphFactory.GraphType, center: Vector3 = Vector3.ZERO) -> bool:
	"""Generate graph using factory with default configuration"""
	GameLogger.info("🔄 Generating graph from factory: %s" % GraphFactory.GraphType.keys()[graph_type])
	
	var graph = GraphFactory.create_graph(graph_type)
	if not graph:
		var error = "Failed to create graph from factory: %s" % GraphFactory.GraphType.keys()[graph_type]
		GameLogger.graph_error("❌ " + error)
		graph_generation_failed.emit(error)
		return false
	
	# Override center position if specified
	if center != Vector3.ZERO and graph.graph_config:
		graph.graph_config.center_position = center
	
	return _generate_graph(graph)

func _generate_graph(graph: BaseGraph) -> bool:
	"""Internal method to generate and place a graph in the scene"""
	GameLogger.info("🎯 [Graph Debug] _generate_graph() called with graph: %s" % (graph.get_class() if graph else "null"), "GraphSystem")
	
	if not terrain_controller:
		GameLogger.graph_error("❌ [Graph Debug] No terrain controller available for graph generation")
		return false
	
	GameLogger.info("✅ [Graph Debug] Terrain controller found: %s" % terrain_controller.name, "GraphSystem")
	
	# Clear previous graph if exists
	if current_graph:
		GameLogger.info("🧹 [Graph Debug] Clearing previous graph..." % [], "GraphSystem")
		_clear_current_graph()
	
	# Initialize the graph first
	GameLogger.info("🔧 [Graph Debug] Initializing graph..." % [], "GraphSystem")
	var init_success = graph.initialize(graph.graph_config)
	if not init_success:
		GameLogger.graph_error("❌ [Graph Debug] Graph initialization failed")
		return false
	
	GameLogger.info("✅ [Graph Debug] Graph initialized successfully", "GraphSystem")
	
	# Generate the graph (SOLID: Dependency Inversion - depends on abstraction)
	GameLogger.info("🚀 [Graph Debug] Calling graph.generate_graph()..." % [], "GraphSystem")
	var success = graph.generate_graph(terrain_controller)
	if not success:
		GameLogger.graph_error("❌ [Graph Debug] Graph generation failed")
		return false
	
	current_graph = graph
	graph_generated.emit(graph)
	GameLogger.info("🎉 [Graph Debug] Graph generated successfully!" % [], "GraphSystem")
	return true

func _clear_current_graph():
	"""Clear the currently generated graph"""
	if current_graph and terrain_controller:
		# Remove graph nodes from scene
		var graph_nodes = terrain_controller.get_children().filter(
			func(node): return node.name.begins_with("Graph_") or node.name.begins_with("Cycle_") or node.name.begins_with("Wheel_")
		)
		
		for node in graph_nodes:
			node.queue_free()
		
		current_graph = null
		GameLogger.info("🧹 Cleared previous graph")

func get_current_graph() -> BaseGraph:
	"""Get the currently generated graph"""
	return current_graph

func get_available_graph_types() -> Array:
	"""Get list of available graph types from factory"""
	return GraphFactory.get_available_graph_types()

func get_player_position() -> Vector3:
	"""Get player position for centering graphs"""
	if terrain_controller:
		return terrain_controller.get_player_position()
	return Vector3.ZERO

# Convenience methods for specific graph types
func generate_triangle_cycle(center: Vector3 = Vector3.ZERO) -> bool:
	return generate_cycle_graph(3, center)

func generate_square_cycle(center: Vector3 = Vector3.ZERO) -> bool:
	return generate_cycle_graph(4, center)

func generate_pentagon_cycle(center: Vector3 = Vector3.ZERO) -> bool:
	return generate_cycle_graph(5, center)

func generate_hexagon_cycle(center: Vector3 = Vector3.ZERO) -> bool:
	return generate_cycle_graph(6, center)

func generate_triangle_wheel(center: Vector3 = Vector3.ZERO) -> bool:
	return generate_wheel_graph(3, center)

func generate_square_wheel(center: Vector3 = Vector3.ZERO) -> bool:
	return generate_wheel_graph(4, center)

func generate_pentagon_wheel(center: Vector3 = Vector3.ZERO) -> bool:
	return generate_wheel_graph(5, center)

func generate_hexagon_wheel(center: Vector3 = Vector3.ZERO) -> bool:
	return generate_wheel_graph(6, center)

func generate_heptagon_wheel(center: Vector3 = Vector3.ZERO) -> bool:
	return generate_wheel_graph(7, center)

func generate_octagon_wheel(center: Vector3 = Vector3.ZERO) -> bool:
	return generate_wheel_graph(8, center)

func generate_enneagon_wheel(center: Vector3 = Vector3.ZERO) -> bool:
	return generate_wheel_graph(9, center)
