extends RefCounted
class_name GraphFactory

## Factory class for creating different types of graph objects
## Follows Factory pattern and provides centralized graph creation

enum GraphType {
	CYCLE_TRIANGLE,    # C3
	CYCLE_SQUARE,      # C4 (Diamond)
	CYCLE_PENTAGON,    # C5
	CYCLE_HEXAGON,     # C6
	CYCLE_HEPTAGON,    # C7
	CYCLE_OCTAGON,     # C8
	CYCLE_ENNEAGON,    # C9
	
	WHEEL_TRIANGLE,    # W3
	WHEEL_SQUARE,      # W4
	WHEEL_PENTAGON,    # W5
	WHEEL_HEXAGON,     # W6
	WHEEL_HEPTAGON,    # W7
	WHEEL_OCTAGON,     # W8
	WHEEL_ENNEAGON     # W9
}

# Configuration file paths for different graph types
static var config_paths = {
	GraphType.CYCLE_TRIANGLE: "res://Resources/GraphSystem/TriangleCycleConfig.tres",
	GraphType.CYCLE_SQUARE: "res://Resources/GraphSystem/SquareCycleConfig.tres",
	GraphType.CYCLE_PENTAGON: "res://Resources/GraphSystem/PentagonCycleConfig.tres",
	GraphType.CYCLE_HEXAGON: "res://Resources/GraphSystem/HexagonCycleConfig.tres",
	GraphType.CYCLE_HEPTAGON: "res://Resources/GraphSystem/HeptagonCycleConfig.tres",
	GraphType.CYCLE_OCTAGON: "res://Resources/GraphSystem/OctagonCycleConfig.tres",
	GraphType.CYCLE_ENNEAGON: "res://Resources/GraphSystem/EnneagonCycleConfig.tres",
	
	GraphType.WHEEL_TRIANGLE: "res://Resources/GraphSystem/TriangleWheelConfig.tres",
	GraphType.WHEEL_SQUARE: "res://Resources/GraphSystem/SquareWheelConfig.tres",
	GraphType.WHEEL_PENTAGON: "res://Resources/GraphSystem/PentagonWheelConfig.tres",
	GraphType.WHEEL_HEXAGON: "res://Resources/GraphSystem/HexagonWheelConfig.tres",
	GraphType.WHEEL_HEPTAGON: "res://Resources/GraphSystem/HeptagonWheelConfig.tres",
	GraphType.WHEEL_OCTAGON: "res://Resources/GraphSystem/OctagonWheelConfig.tres",
	GraphType.WHEEL_ENNEAGON: "res://Resources/GraphSystem/EnneagonWheelConfig.tres"
}

static func create_graph(graph_type: GraphType, custom_config: BaseGraphConfig = null) -> BaseGraph:
	"""
	Create a graph of the specified type
	
	Args:
		graph_type: The type of graph to create
		custom_config: Optional custom configuration (overrides default)
	
	Returns:
		BaseGraph: The created graph instance, or null if failed
	"""
	GameLogger.info("🏭 [Factory Debug] create_graph() called with type: %s" % GraphType.keys()[graph_type], "GraphSystem")
	
	var config = custom_config
	
	# Load default configuration if none provided
	if not config:
		GameLogger.info("📁 [Factory Debug] Loading default configuration..." % [], "GraphSystem")
		config = load_graph_config(graph_type)
		if not config:
			GameLogger.error("❌ [Factory Debug] Failed to load config for %s" % GraphType.keys()[graph_type])
			return null
		GameLogger.info("✅ [Factory Debug] Configuration loaded successfully" % [], "GraphSystem")
	else:
		GameLogger.info("📋 [Factory Debug] Using custom configuration" % [], "GraphSystem")
	
	# Create appropriate graph instance
	var graph: BaseGraph = null
	
	GameLogger.info("🔧 [Factory Debug] Creating graph instance..." % [], "GraphSystem")
	print("🚨 FACTORY: Graph type: %s" % GraphType.keys()[graph_type])
	print("🚨 FACTORY: Is cycle graph: %s" % _is_cycle_graph(graph_type))
	print("🚨 FACTORY: Is wheel graph: %s" % _is_wheel_graph(graph_type))
	
	if _is_cycle_graph(graph_type):
		GameLogger.info("🔄 [Factory Debug] Creating CycleGraph..." % [], "GraphSystem")
		print("🚨 FACTORY: Taking CycleGraph branch")
		var CycleGraphClass = preload("res://Systems/Terrain3D/GraphSystem/CycleGraph.gd")
		graph = CycleGraphClass.new()
	elif _is_wheel_graph(graph_type):
		GameLogger.info("🛞 [Factory Debug] Creating WheelGraph..." % [], "GraphSystem")
		print("🚨 FACTORY: Taking WheelGraph branch")
		var WheelGraphClass = preload("res://Systems/Terrain3D/GraphSystem/WheelGraph.gd")
		graph = WheelGraphClass.new()
		print("🚨 FACTORY: WheelGraph created: %s" % graph.get_class())
	else:
		GameLogger.error("❌ [Factory Debug] Unsupported graph type %s" % GraphType.keys()[graph_type])
		print("🚨 FACTORY: Taking ELSE branch - unsupported type")
		return null
	
	# Initialize graph with configuration
	if graph:
		GameLogger.info("✅ [Factory Debug] Graph instance created: %s" % graph.get_class(), "GraphSystem")
		GameLogger.info("🔧 [Factory Debug] Initializing graph with configuration..." % [], "GraphSystem")
		var success = graph.initialize(config)
		if success:
			GameLogger.info("🎉 [Factory Debug] Graph initialization successful!" % [], "GraphSystem")
			GameLogger.info("✅ GraphFactory: Created %s" % _get_graph_description(graph_type))
		else:
			GameLogger.graph_error("❌ GraphFactory: Failed to initialize %s" % _get_graph_description(graph_type))
			return null
	
	return graph

static func create_cycle_graph(vertex_count: int, center: Vector3 = Vector3.ZERO, radius: float = 25.0) -> CycleGraph:
	"""
	Create a cycle graph with specified parameters
	
	Args:
		vertex_count: Number of vertices in the cycle (3-9)
		center: Center position of the cycle
		radius: Radius of the cycle
	
	Returns:
		CycleGraph: The created cycle graph
	"""
	var graph_type = _get_cycle_type_from_count(vertex_count)
	if graph_type == -1:
		GameLogger.error("❌ GraphFactory: Unsupported vertex count %d for cycle graph" % vertex_count)
		return null
	
	var config = CycleGraphConfig.new()
	config.cycle_type = vertex_count
	config.center_position = center
	config.radius = radius
	
	return create_graph(graph_type, config) as CycleGraph

static func create_wheel_graph(vertex_count: int, center: Vector3 = Vector3.ZERO, radius: float = 25.0) -> WheelGraph:
	"""
	Create a wheel graph with specified parameters
	
	Args:
		vertex_count: Number of outer vertices (3-9)
		center: Center position of the wheel
		radius: Radius of the outer vertices
	
	Returns:
		WheelGraph: The created wheel graph
	"""
	GameLogger.info("🏭 [W%d Factory] create_wheel_graph() called with vertex_count=%d, center=%s, radius=%s" % [vertex_count, vertex_count, center, radius], "GraphSystem")
	
	var graph_type = _get_wheel_type_from_count(vertex_count)
	if graph_type == -1:
		GameLogger.error("❌ [W%d Factory] Unsupported vertex count %d for wheel graph" % [vertex_count, vertex_count])
		return null
	
	GameLogger.info("✅ [W%d Factory] Graph type determined: %s" % [vertex_count, GraphType.keys()[graph_type]], "GraphSystem")
	
	# Load configuration from .tres file instead of creating new
	GameLogger.info("📁 [W%d Factory] Loading configuration from .tres file..." % vertex_count, "GraphSystem")
	var config = load_graph_config(graph_type)
	if not config:
		GameLogger.error("❌ [W%d Factory] Failed to load configuration for graph type %s" % [vertex_count, GraphType.keys()[graph_type]])
		return null
	
	GameLogger.info("✅ [W%d Factory] Configuration loaded successfully" % vertex_count, "GraphSystem")
	
	# Override parameters if specified
	config.center_position = center
	config.radius = radius
	
	return create_graph(graph_type, config) as WheelGraph

static func load_graph_config(graph_type: GraphType) -> BaseGraphConfig:
	"""Load configuration for a graph type"""
	if graph_type not in config_paths:
		GameLogger.warning("⚠️ GraphFactory: No config path for %s" % GraphType.keys()[graph_type])
		return null
	
	var config_path = config_paths[graph_type]
	if not ResourceLoader.exists(config_path):
		GameLogger.warning("⚠️ GraphFactory: Config file not found: %s" % config_path)
		return null
	
	var config = load(config_path)
	if not config:
		GameLogger.error("❌ GraphFactory: Failed to load config: %s" % config_path)
		return null
	
	return config

static func get_available_graph_types() -> Array[GraphType]:
	"""Get list of all available graph types"""
	var types: Array[GraphType] = []
	for type in GraphType.values():
		types.append(type)
	return types

static func get_cycle_graph_types() -> Array[GraphType]:
	"""Get list of cycle graph types only"""
	var types: Array[GraphType] = []
	for type in GraphType.values():
		if _is_cycle_graph(type):
			types.append(type)
	return types

static func get_wheel_graph_types() -> Array[GraphType]:
	"""Get list of wheel graph types only"""
	var types: Array[GraphType] = []
	for type in GraphType.values():
		if _is_wheel_graph(type):
			types.append(type)
	return types

# Private helper methods
static func _is_cycle_graph(graph_type: GraphType) -> bool:
	"""Check if graph type is a cycle graph"""
	return graph_type >= GraphType.CYCLE_TRIANGLE and graph_type <= GraphType.CYCLE_ENNEAGON

static func _is_wheel_graph(graph_type: GraphType) -> bool:
	"""Check if graph type is a wheel graph"""
	return graph_type >= GraphType.WHEEL_TRIANGLE and graph_type <= GraphType.WHEEL_ENNEAGON

static func _get_cycle_type_from_count(count: int) -> int:
	"""Get cycle graph type from vertex count, returns -1 if invalid"""
	match count:
		3: return GraphType.CYCLE_TRIANGLE
		4: return GraphType.CYCLE_SQUARE
		5: return GraphType.CYCLE_PENTAGON
		6: return GraphType.CYCLE_HEXAGON
		7: return GraphType.CYCLE_HEPTAGON
		8: return GraphType.CYCLE_OCTAGON
		9: return GraphType.CYCLE_ENNEAGON
		_: return -1

static func _get_wheel_type_from_count(count: int) -> int:
	"""Get wheel graph type from vertex count, returns -1 if invalid"""
	match count:
		3: return GraphType.WHEEL_TRIANGLE
		4: return GraphType.WHEEL_SQUARE
		5: return GraphType.WHEEL_PENTAGON
		6: return GraphType.WHEEL_HEXAGON
		7: return GraphType.WHEEL_HEPTAGON
		8: return GraphType.WHEEL_OCTAGON
		9: return GraphType.WHEEL_ENNEAGON
		_: return -1

static func _get_graph_description(graph_type: GraphType) -> String:
	"""Get human-readable description of graph type"""
	match graph_type:
		GraphType.CYCLE_TRIANGLE: return "Triangle Cycle (C3)"
		GraphType.CYCLE_SQUARE: return "Square Cycle (C4)"
		GraphType.CYCLE_PENTAGON: return "Pentagon Cycle (C5)"
		GraphType.CYCLE_HEXAGON: return "Hexagon Cycle (C6)"
		GraphType.CYCLE_HEPTAGON: return "Heptagon Cycle (C7)"
		GraphType.CYCLE_OCTAGON: return "Octagon Cycle (C8)"
		GraphType.CYCLE_ENNEAGON: return "Enneagon Cycle (C9)"
		
		GraphType.WHEEL_TRIANGLE: return "Triangle Wheel (W3)"
		GraphType.WHEEL_SQUARE: return "Square Wheel (W4)"
		GraphType.WHEEL_PENTAGON: return "Pentagon Wheel (W5)"
		GraphType.WHEEL_HEXAGON: return "Hexagon Wheel (W6)"
		GraphType.WHEEL_HEPTAGON: return "Heptagon Wheel (W7)"
		GraphType.WHEEL_OCTAGON: return "Octagon Wheel (W8)"
		GraphType.WHEEL_ENNEAGON: return "Enneagon Wheel (W9)"
		_: return "Unknown Graph"
